package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.Skill;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.List;
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
    }

    private void createTables() {
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS mhr_skills (id BIGINT PRIMARY KEY, code VARCHAR(64) UNIQUE NOT NULL, name VARCHAR(128) NOT NULL, name_zh VARCHAR(128) NOT NULL, max_level INT NOT NULL)");
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
}
