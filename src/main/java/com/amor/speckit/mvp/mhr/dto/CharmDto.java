package com.amor.speckit.mvp.mhr.dto;

import java.util.List;
import java.util.Map;

public class CharmDto {
    private Map<String, Integer> skillPoints;
    private List<Integer> slots;

    public Map<String, Integer> getSkillPoints() {
        return skillPoints;
    }

    public void setSkillPoints(Map<String, Integer> skillPoints) {
        this.skillPoints = skillPoints;
    }

    public List<Integer> getSlots() {
        return slots;
    }

    public void setSlots(List<Integer> slots) {
        this.slots = slots;
    }
}
