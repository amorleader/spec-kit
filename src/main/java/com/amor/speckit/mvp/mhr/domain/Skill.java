package com.amor.speckit.mvp.mhr.domain;

public class Skill {
    private final long id;
    private final String code;
    private final String name;
    private final String nameZh;
    private final int maxLevel;
    private final String effect;

    public Skill(long id, String code, String name, String nameZh, int maxLevel) {
        this(id, code, name, nameZh, maxLevel, "");
    }

    public Skill(long id, String code, String name, String nameZh, int maxLevel, String effect) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.nameZh = nameZh;
        this.maxLevel = maxLevel;
        this.effect = effect == null ? "" : effect;
    }

    public long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getNameZh() {
        return nameZh;
    }

    public int getMaxLevel() {
        return maxLevel;
    }

    public String getEffect() {
        return effect;
    }
}
