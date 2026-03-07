package com.amor.speckit.mvp.mhr.domain;

public class Skill {
    private final long id;
    private final String code;
    private final String name;
    private final int maxLevel;

    public Skill(long id, String code, String name, int maxLevel) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.maxLevel = maxLevel;
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

    public int getMaxLevel() {
        return maxLevel;
    }
}
