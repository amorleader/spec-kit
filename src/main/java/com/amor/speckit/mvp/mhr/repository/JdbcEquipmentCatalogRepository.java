package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "db")
public class JdbcEquipmentCatalogRepository implements EquipmentCatalogPort {
    private final JdbcTemplate jdbcTemplate;

    public JdbcEquipmentCatalogRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Equipment> findAll() {
        List<EquipmentBaseRow> baseRows = jdbcTemplate.query(
                "SELECT id, name, name_zh, part, rarity, slots_csv FROM mhr_equipments ORDER BY part ASC, id ASC",
                (rs, rowNum) -> new EquipmentBaseRow(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                        EquipmentPart.valueOf(rs.getString("part")),
                        rs.getInt("rarity"),
                        parseSlots(rs.getString("slots_csv"))
                )
        );
        return enrich(baseRows);
    }

    @Override
    public List<Equipment> findByPartAndWeapon(EquipmentPart part, WeaponType weaponType) {
        List<EquipmentBaseRow> baseRows = jdbcTemplate.query(
                "SELECT e.id, e.name, e.name_zh, e.part, e.rarity, e.slots_csv " +
                        "FROM mhr_equipments e " +
                        "WHERE e.part = ? AND EXISTS (" +
                        "SELECT 1 FROM mhr_equipment_weapon_types w WHERE w.equipment_id = e.id AND w.weapon_type = ?) " +
                        "ORDER BY e.id ASC",
                (rs, rowNum) -> new EquipmentBaseRow(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                        EquipmentPart.valueOf(rs.getString("part")),
                        rs.getInt("rarity"),
                        parseSlots(rs.getString("slots_csv"))
                ),
                part.name(),
                weaponType.name()
        );
        return enrich(baseRows);
    }

    @Override
    public List<Equipment> findByWeapon(WeaponType weaponType) {
        List<EquipmentBaseRow> baseRows = jdbcTemplate.query(
                "SELECT e.id, e.name, e.name_zh, e.part, e.rarity, e.slots_csv " +
                        "FROM mhr_equipments e " +
                        "WHERE EXISTS (" +
                        "SELECT 1 FROM mhr_equipment_weapon_types w WHERE w.equipment_id = e.id AND w.weapon_type = ?) " +
                        "ORDER BY e.part ASC, e.id ASC",
                (rs, rowNum) -> new EquipmentBaseRow(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                        EquipmentPart.valueOf(rs.getString("part")),
                        rs.getInt("rarity"),
                        parseSlots(rs.getString("slots_csv"))
                ),
                weaponType.name()
        );
        return enrich(baseRows);
    }

    @Override
    public List<Equipment> findCandidatesByPart(WeaponType weaponType, int topPerPart) {
        List<Equipment> all = findByWeapon(weaponType);
        List<Equipment> result = new ArrayList<>();
        for (EquipmentPart part : EquipmentPart.values()) {
            all.stream()
                    .filter(equipment -> equipment.getPart() == part)
                    .limit(topPerPart)
                    .forEach(result::add);
        }
        return result;
    }

    private List<Equipment> enrich(List<EquipmentBaseRow> baseRows) {
        if (baseRows.isEmpty()) {
            return Collections.emptyList();
        }

        List<Long> equipmentIds = baseRows.stream().map(row -> row.id).collect(Collectors.toList());
        Map<Long, Map<String, Integer>> skillPointsMap = loadSkillPoints(equipmentIds);
        Map<Long, Set<WeaponType>> weaponTypesMap = loadWeaponTypes(equipmentIds);

        List<Equipment> result = new ArrayList<>();
        for (EquipmentBaseRow row : baseRows) {
            result.add(new Equipment(
                    row.id,
                    row.name,
                    row.nameZh,
                    row.part,
                    row.rarity,
                    row.slots,
                    skillPointsMap.getOrDefault(row.id, Collections.emptyMap()),
                    weaponTypesMap.getOrDefault(row.id, EnumSet.noneOf(WeaponType.class))
            ));
        }
        return result;
    }

    private Map<Long, Map<String, Integer>> loadSkillPoints(List<Long> equipmentIds) {
        String inClause = equipmentIds.stream().map(id -> "?").collect(Collectors.joining(","));
        String sql = "SELECT equipment_id, skill_code, points FROM mhr_equipment_skill_points WHERE equipment_id IN (" + inClause + ")";

        Map<Long, Map<String, Integer>> result = new HashMap<>();
        jdbcTemplate.query(sql, rs -> {
            long equipmentId = rs.getLong("equipment_id");
            result.computeIfAbsent(equipmentId, ignored -> new LinkedHashMap<>())
                    .put(rs.getString("skill_code"), rs.getInt("points"));
        }, equipmentIds.toArray());
        return result;
    }

    private Map<Long, Set<WeaponType>> loadWeaponTypes(List<Long> equipmentIds) {
        String inClause = equipmentIds.stream().map(id -> "?").collect(Collectors.joining(","));
        String sql = "SELECT equipment_id, weapon_type FROM mhr_equipment_weapon_types WHERE equipment_id IN (" + inClause + ")";

        Map<Long, Set<WeaponType>> result = new HashMap<>();
        jdbcTemplate.query(sql, rs -> {
            long equipmentId = rs.getLong("equipment_id");
            result.computeIfAbsent(equipmentId, ignored -> EnumSet.noneOf(WeaponType.class))
                    .add(WeaponType.valueOf(rs.getString("weapon_type")));
        }, equipmentIds.toArray());
        return result;
    }

    private static List<Integer> parseSlots(String csv) {
        if (csv == null || csv.isBlank()) {
            return Collections.emptyList();
        }
        return Arrays.stream(csv.split(","))
                .map(String::trim)
                .filter(token -> !token.isEmpty())
                .map(Integer::parseInt)
                .collect(Collectors.toList());
    }

    private static class EquipmentBaseRow {
        private final long id;
        private final String name;
        private final String nameZh;
        private final EquipmentPart part;
        private final int rarity;
        private final List<Integer> slots;

        private EquipmentBaseRow(long id, String name, String nameZh, EquipmentPart part, int rarity, List<Integer> slots) {
            this.id = id;
            this.name = name;
            this.nameZh = nameZh;
            this.part = part;
            this.rarity = rarity;
            this.slots = slots;
        }
    }
}
