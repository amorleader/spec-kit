package com.amor.speckit.mvp.mhr.domain;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Equipment {
    private final long id;
    private final String name;
    private final EquipmentPart part;
    private final int rarity;
    private final List<Integer> slots;
    private final Map<String, Integer> skillPoints;
    private final Set<WeaponType> supportedWeaponTypes;

    public Equipment(long id,
                     String name,
                     EquipmentPart part,
                     int rarity,
                     List<Integer> slots,
                     Map<String, Integer> skillPoints,
                     Set<WeaponType> supportedWeaponTypes) {
        this.id = id;
        this.name = name;
        this.part = part;
        this.rarity = rarity;
        this.slots = Collections.unmodifiableList(slots);
        this.skillPoints = Collections.unmodifiableMap(skillPoints);
        this.supportedWeaponTypes = Collections.unmodifiableSet(supportedWeaponTypes);
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public EquipmentPart getPart() {
        return part;
    }

    public int getRarity() {
        return rarity;
    }

    public List<Integer> getSlots() {
        return slots;
    }

    public Map<String, Integer> getSkillPoints() {
        return skillPoints;
    }

    public Set<WeaponType> getSupportedWeaponTypes() {
        return supportedWeaponTypes;
    }
}
