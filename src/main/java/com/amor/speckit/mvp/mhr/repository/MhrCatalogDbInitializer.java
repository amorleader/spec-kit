package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.Skill;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "db")
public class MhrCatalogDbInitializer {
    private final JdbcTemplate jdbcTemplate;

    public MhrCatalogDbInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        createTables();
        seedIfEmpty();
        normalizeSkillCatalog();
    }

    private void createTables() {
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS mhr_skills (id BIGINT PRIMARY KEY, code VARCHAR(64) UNIQUE NOT NULL, name VARCHAR(128) NOT NULL, name_zh VARCHAR(128) NOT NULL, max_level INT NOT NULL)");
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS mhr_skill_effects (skill_code VARCHAR(64) PRIMARY KEY, effect TEXT NOT NULL DEFAULT '')");
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS mhr_equipments (id BIGINT PRIMARY KEY, name VARCHAR(128) NOT NULL, name_zh VARCHAR(128) NOT NULL, part VARCHAR(32) NOT NULL, rarity INT NOT NULL, slots_csv VARCHAR(64) NOT NULL)");
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS mhr_equipment_skill_points (equipment_id BIGINT NOT NULL, skill_code VARCHAR(64) NOT NULL, points INT NOT NULL, PRIMARY KEY (equipment_id, skill_code), CONSTRAINT fk_mhr_equipment_skill_equipment FOREIGN KEY (equipment_id) REFERENCES mhr_equipments(id), CONSTRAINT fk_mhr_equipment_skill_skill FOREIGN KEY (skill_code) REFERENCES mhr_skills(code))");
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS mhr_equipment_weapon_types (equipment_id BIGINT NOT NULL, weapon_type VARCHAR(32) NOT NULL, PRIMARY KEY (equipment_id, weapon_type), CONSTRAINT fk_mhr_equipment_weapon_equipment FOREIGN KEY (equipment_id) REFERENCES mhr_equipments(id))");
    }

    private void seedIfEmpty() {
        Integer skillCount = jdbcTemplate.queryForObject("SELECT COUNT(1) FROM mhr_skills", Integer.class);
        if (skillCount != null && skillCount == 0) {
            List<Skill> skills = new SkillCatalogRepository().findAll();
            for (Skill skill : skills) {
                jdbcTemplate.update(
                    "INSERT INTO mhr_skills (id, code, name, name_zh, max_level) VALUES (?, ?, ?, ?, ?)",
                        skill.getId(),
                        skill.getCode(),
                        skill.getName(),
                        skill.getNameZh(),
                    skill.getMaxLevel()
                );
                jdbcTemplate.update(
                    "INSERT INTO mhr_skill_effects (skill_code, effect) VALUES (?, ?) ON CONFLICT (skill_code) DO UPDATE SET effect = EXCLUDED.effect",
                    skill.getCode(),
                    skill.getEffect()
                );
            }
        }

        Integer equipmentCount = jdbcTemplate.queryForObject("SELECT COUNT(1) FROM mhr_equipments", Integer.class);
        if (equipmentCount != null && equipmentCount == 0) {
            List<Equipment> equipments = new EquipmentCatalogRepository().findAll();
            for (Equipment equipment : equipments) {
                jdbcTemplate.update(
                        "INSERT INTO mhr_equipments (id, name, name_zh, part, rarity, slots_csv) VALUES (?, ?, ?, ?, ?, ?)",
                        equipment.getId(),
                        equipment.getName(),
                        equipment.getNameZh(),
                        equipment.getPart().name(),
                        equipment.getRarity(),
                        equipment.getSlots().stream().map(String::valueOf).collect(Collectors.joining(","))
                );

                equipment.getSkillPoints().forEach((skillCode, points) -> jdbcTemplate.update(
                        "INSERT INTO mhr_equipment_skill_points (equipment_id, skill_code, points) VALUES (?, ?, ?)",
                        equipment.getId(),
                        skillCode,
                        points
                ));

                for (WeaponType weaponType : equipment.getSupportedWeaponTypes()) {
                    jdbcTemplate.update(
                            "INSERT INTO mhr_equipment_weapon_types (equipment_id, weapon_type) VALUES (?, ?)",
                            equipment.getId(),
                            weaponType.name()
                    );
                }
            }
        }
    }

    private void normalizeSkillCatalog() {
        mergeDuplicateSkillsByZhName();
        applySkillMaxLevelOverrides();
    }

    private void mergeDuplicateSkillsByZhName() {
        List<String> duplicateNames = jdbcTemplate.queryForList(
                "SELECT name_zh FROM mhr_skills GROUP BY LOWER(TRIM(name_zh)), name_zh HAVING COUNT(*) > 1",
                String.class
        );

        for (String nameZh : duplicateNames) {
            List<SkillRow> rows = jdbcTemplate.query(
                    "SELECT id, code, max_level FROM mhr_skills WHERE LOWER(TRIM(name_zh)) = LOWER(TRIM(?)) ORDER BY max_level DESC, id ASC",
                    (rs, rowNum) -> new SkillRow(rs.getLong("id"), rs.getString("code"), rs.getInt("max_level")),
                    nameZh
            );

            if (rows.size() <= 1) {
                continue;
            }

            SkillRow canonical = rows.get(0);
            for (int i = 1; i < rows.size(); i++) {
                SkillRow duplicate = rows.get(i);

                jdbcTemplate.update(
                        "INSERT INTO mhr_equipment_skill_points (equipment_id, skill_code, points) " +
                                "SELECT equipment_id, ?, points FROM mhr_equipment_skill_points WHERE skill_code = ? " +
                                "ON CONFLICT (equipment_id, skill_code) DO UPDATE SET points = GREATEST(mhr_equipment_skill_points.points, EXCLUDED.points)",
                        canonical.code,
                        duplicate.code
                );
                jdbcTemplate.update("DELETE FROM mhr_equipment_skill_points WHERE skill_code = ?", duplicate.code);
                jdbcTemplate.update("DELETE FROM mhr_skills WHERE code = ?", duplicate.code);
            }

            Integer mergedMaxLevel = jdbcTemplate.queryForObject(
                    "SELECT MAX(max_level) FROM mhr_skills WHERE LOWER(TRIM(name_zh)) = LOWER(TRIM(?))",
                    Integer.class,
                    nameZh
            );
            jdbcTemplate.update(
                    "UPDATE mhr_skills SET max_level = ? WHERE code = ?",
                    mergedMaxLevel == null ? canonical.maxLevel : mergedMaxLevel,
                    canonical.code
            );
        }
    }

    private void applySkillMaxLevelOverrides() {
        Map<String, Integer> overrides = new LinkedHashMap<>();
        overrides.put("攻击强化", 7);
        overrides.put("看破", 7);
        overrides.put("弱点特效", 3);
        overrides.put("雷属性攻击强化", 5);
        overrides.put("火属性攻击强化", 5);
        overrides.put("水属性攻击强化", 5);
        overrides.put("冰属性攻击强化", 5);
        overrides.put("龙属性攻击强化", 5);

        overrides.forEach((nameZh, maxLevel) -> jdbcTemplate.update(
                "UPDATE mhr_skills SET max_level = GREATEST(max_level, ?) WHERE LOWER(TRIM(name_zh)) = LOWER(TRIM(?))",
                maxLevel,
                nameZh
        ));
    }

    private static class SkillRow {
        private final long id;
        private final String code;
        private final int maxLevel;

        private SkillRow(long id, String code, int maxLevel) {
            this.id = id;
            this.code = code;
            this.maxLevel = maxLevel;
        }
    }
}
