package com.amor.speckit.mvp.mhr.dto;

import java.util.List;
import java.util.Map;

public class BuildResultResponse {
    private String id;
    private Map<String, EquipmentResponse> equipmentSet;
    private Map<String, Integer> totalSkills;
    private Map<Integer, Integer> slotSummary;
    private int score;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Map<String, EquipmentResponse> getEquipmentSet() {
        return equipmentSet;
    }

    public void setEquipmentSet(Map<String, EquipmentResponse> equipmentSet) {
        this.equipmentSet = equipmentSet;
    }

    public Map<String, Integer> getTotalSkills() {
        return totalSkills;
    }

    public void setTotalSkills(Map<String, Integer> totalSkills) {
        this.totalSkills = totalSkills;
    }

    public Map<Integer, Integer> getSlotSummary() {
        return slotSummary;
    }

    public void setSlotSummary(Map<Integer, Integer> slotSummary) {
        this.slotSummary = slotSummary;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }
}
