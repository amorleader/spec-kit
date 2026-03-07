package com.amor.speckit.mvp.mhr.domain;

import java.util.Collections;
import java.util.List;
import java.util.Map;

public class Charm {
    private final Map<String, Integer> skillPoints;
    private final List<Integer> slots;

    public Charm(Map<String, Integer> skillPoints, List<Integer> slots) {
        this.skillPoints = Collections.unmodifiableMap(skillPoints);
        this.slots = Collections.unmodifiableList(slots);
    }

    public Map<String, Integer> getSkillPoints() {
        return skillPoints;
    }

    public List<Integer> getSlots() {
        return slots;
    }
}
