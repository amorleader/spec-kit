package com.amor.speckit.mvp.mhr.repository;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@ConditionalOnProperty(name = "app.mhr.catalog.import-on-startup", havingValue = "true")
public class MhrCatalogJsonImporter {
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;
    private final String repositoryMode;
    private final String importJsonPath;

    public MhrCatalogJsonImporter(JdbcTemplate jdbcTemplate,
                                  ObjectMapper objectMapper,
                                  Environment environment) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
        this.repositoryMode = environment.getProperty("app.mhr.catalog.repository-mode", "in-memory");
        this.importJsonPath = environment.getProperty("app.mhr.catalog.import-json-path", "");
    }

    @PostConstruct
    public void importFromJsonIfConfigured() throws IOException {
        if (!"db".equalsIgnoreCase(repositoryMode)) {
            return;
        }

        if (importJsonPath == null || importJsonPath.isBlank()) {
            return;
        }

        FileSystemResource resource = new FileSystemResource(importJsonPath);
        if (!resource.exists()) {
            return;
        }

        Path path = resource.getFile().toPath();
        if (!Files.isRegularFile(path)) {
            return;
        }

        ImportPayload payload = objectMapper.readValue(path.toFile(), ImportPayload.class);
        if (payload == null) {
            return;
        }

        importSkills(payload.skills == null ? Collections.emptyList() : payload.skills);
        importEquipments(payload.equipments == null ? Collections.emptyList() : payload.equipments);
    }

    private void importSkills(List<SkillImport> skills) {
        for (SkillImport skill : skills) {
            jdbcTemplate.update(
                    "INSERT INTO mhr_skills (id, code, name, name_zh, max_level) VALUES (?, ?, ?, ?, ?) " +
                        "ON CONFLICT (id) DO UPDATE SET code = EXCLUDED.code, name = EXCLUDED.name, name_zh = EXCLUDED.name_zh, max_level = EXCLUDED.max_level",
                    skill.id,
                    safe(skill.code),
                    safe(skill.name),
                    safe(skill.nameZh),
                    skill.maxLevel
            );
                jdbcTemplate.update(
                    "INSERT INTO mhr_skill_effects (skill_code, effect) VALUES (?, ?) ON CONFLICT (skill_code) DO UPDATE SET effect = EXCLUDED.effect",
                    safe(skill.code),
                    safe(skill.effect)
                );
        }
    }

    private void importEquipments(List<EquipmentImport> equipments) {
        for (EquipmentImport equipment : equipments) {
            String slotsCsv = (equipment.slots == null ? Collections.<Integer>emptyList() : equipment.slots)
                    .stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining(","));

            jdbcTemplate.update(
                    "INSERT INTO mhr_equipments (id, name, name_zh, part, rarity, slots_csv) VALUES (?, ?, ?, ?, ?, ?) " +
                            "ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, name_zh = EXCLUDED.name_zh, part = EXCLUDED.part, rarity = EXCLUDED.rarity, slots_csv = EXCLUDED.slots_csv",
                    equipment.id,
                    safe(equipment.name),
                    safe(equipment.nameZh),
                    safe(equipment.part),
                    equipment.rarity,
                    slotsCsv
            );

            jdbcTemplate.update("DELETE FROM mhr_equipment_skill_points WHERE equipment_id = ?", equipment.id);
            jdbcTemplate.update("DELETE FROM mhr_equipment_weapon_types WHERE equipment_id = ?", equipment.id);

            Map<String, Integer> skillPoints = equipment.skillPoints == null ? Collections.emptyMap() : equipment.skillPoints;
            for (Map.Entry<String, Integer> entry : skillPoints.entrySet()) {
                jdbcTemplate.update(
                        "INSERT INTO mhr_equipment_skill_points (equipment_id, skill_code, points) VALUES (?, ?, ?)",
                        equipment.id,
                        safe(entry.getKey()),
                        entry.getValue()
                );
            }

            Set<String> weaponTypes = equipment.supportedWeaponTypes == null ? Collections.emptySet() : equipment.supportedWeaponTypes;
            for (String weaponType : weaponTypes) {
                jdbcTemplate.update(
                        "INSERT INTO mhr_equipment_weapon_types (equipment_id, weapon_type) VALUES (?, ?)",
                        equipment.id,
                        safe(weaponType)
                );
            }
        }
    }

    private static String safe(String value) {
        return value == null ? "" : value;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class ImportPayload {
        public List<SkillImport> skills;
        public List<EquipmentImport> equipments;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class SkillImport {
        public long id;
        public String code;
        public String name;
        public String nameZh;
        public int maxLevel;
        public String effect;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class EquipmentImport {
        public long id;
        public String name;
        public String nameZh;
        public String part;
        public int rarity;
        public List<Integer> slots;
        public Map<String, Integer> skillPoints;
        public Set<String> supportedWeaponTypes;
    }
}
