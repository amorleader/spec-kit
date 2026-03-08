package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Decoration;
import com.amor.speckit.mvp.mhr.domain.Equipment;
import com.amor.speckit.mvp.mhr.domain.EquipmentPart;
import com.amor.speckit.mvp.mhr.domain.Skill;
import com.amor.speckit.mvp.mhr.domain.WeaponType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.EnumSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "embedded-json")
public class EmbeddedMhrCatalogStore {
    private final ObjectMapper objectMapper;
    private final ResourceLoader resourceLoader;
    private final String embeddedJsonPath;

    private List<Skill> skills = Collections.emptyList();
    private List<Equipment> equipments = Collections.emptyList();
    private List<Decoration> decorations = Collections.emptyList();

    public EmbeddedMhrCatalogStore(ObjectMapper objectMapper,
                                   ResourceLoader resourceLoader,
                                   Environment environment) {
        this.objectMapper = objectMapper;
        this.resourceLoader = resourceLoader;
        this.embeddedJsonPath = environment.getProperty("app.mhr.catalog.embedded-json-path", "catalog/mhr-catalog.json");
    }

    @PostConstruct
    public void init() throws IOException {
        String normalized = embeddedJsonPath.startsWith("classpath:") ? embeddedJsonPath : "classpath:" + embeddedJsonPath;
        Resource resource = resourceLoader.getResource(normalized);
        if (!resource.exists()) {
            throw new IllegalStateException("Embedded catalog JSON not found: " + normalized);
        }

        try (InputStream in = resource.getInputStream()) {
            CatalogPayload payload = objectMapper.readValue(in, CatalogPayload.class);
            this.skills = Collections.unmodifiableList(toSkills(payload == null ? null : payload.skills));
            this.equipments = Collections.unmodifiableList(toEquipments(payload == null ? null : payload.equipments));
            this.decorations = Collections.unmodifiableList(toDecorations(payload == null ? null : payload.decorations));
        }
    }

    public List<Skill> getSkills() {
        return skills;
    }

    public List<Equipment> getEquipments() {
        return equipments;
    }

    public List<Decoration> getDecorations() {
        return decorations;
    }

    private List<Skill> toSkills(List<SkillJson> rows) {
        if (rows == null) {
            return Collections.emptyList();
        }
        List<Skill> result = new ArrayList<>();
        for (SkillJson row : rows) {
            result.add(new Skill(
                    row.id,
                    safe(row.code),
                    safe(row.name),
                    safe(row.nameZh),
                    Math.max(1, row.maxLevel),
                    safe(row.effect)
            ));
        }
        return result;
    }

    private List<Equipment> toEquipments(List<EquipmentJson> rows) {
        if (rows == null) {
            return Collections.emptyList();
        }
        List<Equipment> result = new ArrayList<>();
        for (EquipmentJson row : rows) {
            EquipmentPart part = EquipmentPart.valueOf(safe(row.part));
            List<Integer> slots = row.slots == null ? Collections.emptyList() : row.slots;
            Map<String, Integer> skillPoints = row.skillPoints == null ? Collections.emptyMap() : row.skillPoints;

            Set<WeaponType> supported = EnumSet.noneOf(WeaponType.class);
            if (row.supportedWeaponTypes != null) {
                supported = row.supportedWeaponTypes.stream()
                        .map(WeaponType::valueOf)
                        .collect(Collectors.toCollection(() -> EnumSet.noneOf(WeaponType.class)));
            }

            result.add(new Equipment(
                    row.id,
                    safe(row.name),
                    safe(row.nameZh),
                    part,
                    row.rarity,
                    slots,
                    new LinkedHashMap<>(skillPoints),
                    supported
            ));
        }
        return result;
    }

    private List<Decoration> toDecorations(List<DecorationJson> rows) {
        if (rows == null) {
            return Collections.emptyList();
        }
        List<Decoration> result = new ArrayList<>();
        for (DecorationJson row : rows) {
            result.add(new Decoration(
                    row.id,
                    safe(row.name),
                    safe(row.nameZh),
                    row.slotLevel,
                    safe(row.skillCode),
                    safe(row.skillNameZh),
                    row.skillLevel,
                    row.price,
                    safe(row.materials)
            ));
        }
        return result;
    }

    private static String safe(String value) {
        return value == null ? "" : value;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class CatalogPayload {
        public List<SkillJson> skills;
        public List<EquipmentJson> equipments;
        public List<DecorationJson> decorations;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class SkillJson {
        public long id;
        public String code;
        public String name;
        public String nameZh;
        public int maxLevel;
        public String effect;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class EquipmentJson {
        public long id;
        public String name;
        public String nameZh;
        public String part;
        public int rarity;
        public List<Integer> slots;
        public Map<String, Integer> skillPoints;
        public List<String> supportedWeaponTypes;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class DecorationJson {
        public long id;
        public String name;
        public String nameZh;
        public int slotLevel;
        public String skillCode;
        public String skillNameZh;
        public int skillLevel;
        public int price;
        public String materials;
    }
}
