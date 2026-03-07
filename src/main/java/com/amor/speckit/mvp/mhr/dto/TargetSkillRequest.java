package com.amor.speckit.mvp.mhr.dto;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;

public class TargetSkillRequest {
    @NotBlank
    private String skillCode;

    @Min(1)
    private int minLevel;

    public String getSkillCode() {
        return skillCode;
    }

    public void setSkillCode(String skillCode) {
        this.skillCode = skillCode;
    }

    public int getMinLevel() {
        return minLevel;
    }

    public void setMinLevel(int minLevel) {
        this.minLevel = minLevel;
    }
}
