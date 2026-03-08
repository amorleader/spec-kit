package com.amor.speckit.mvp.mhr.domain;

public class Decoration {
    private final long id;
    private final String name;
    private final String nameZh;
    private final int slotLevel;
    private final String skillCode;
    private final String skillNameZh;
    private final int skillLevel;
    private final int price;
    private final String materials;

    public Decoration(long id,
                      String name,
                      String nameZh,
                      int slotLevel,
                      String skillCode,
                      String skillNameZh,
                      int skillLevel,
                      int price,
                      String materials) {
        this.id = id;
        this.name = name;
        this.nameZh = nameZh;
        this.slotLevel = slotLevel;
        this.skillCode = skillCode;
        this.skillNameZh = skillNameZh;
        this.skillLevel = skillLevel;
        this.price = price;
        this.materials = materials;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getNameZh() {
        return nameZh;
    }

    public int getSlotLevel() {
        return slotLevel;
    }

    public String getSkillCode() {
        return skillCode;
    }

    public String getSkillNameZh() {
        return skillNameZh;
    }

    public int getSkillLevel() {
        return skillLevel;
    }

    public int getPrice() {
        return price;
    }

    public String getMaterials() {
        return materials;
    }
}
