package com.amor.speckit.mvp.mhr.dto;

import com.amor.speckit.mvp.mhr.domain.EquipmentPart;

import java.util.List;
import java.util.Map;

public class EquipmentResponse {
    private long id;
    private String name;
    private String nameZh;
    private EquipmentPart part;
    private int rarity;
    private List<Integer> slots;
    private Map<String, Integer> skillPoints;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getNameZh() {
        return nameZh;
    }

    public void setNameZh(String nameZh) {
        this.nameZh = nameZh;
    }

    public EquipmentPart getPart() {
        return part;
    }

    public void setPart(EquipmentPart part) {
        this.part = part;
    }

    public int getRarity() {
        return rarity;
    }

    public void setRarity(int rarity) {
        this.rarity = rarity;
    }

    public List<Integer> getSlots() {
        return slots;
    }

    public void setSlots(List<Integer> slots) {
        this.slots = slots;
    }

    public Map<String, Integer> getSkillPoints() {
        return skillPoints;
    }

    public void setSkillPoints(Map<String, Integer> skillPoints) {
        this.skillPoints = skillPoints;
    }
}
