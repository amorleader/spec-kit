package com.amor.speckit.mvp.mhr.dto;

import com.amor.speckit.mvp.mhr.domain.WeaponType;

import javax.validation.Valid;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import java.util.List;

public class BuildGenerateRequest {
    @NotNull
    private WeaponType weaponType;

    @Valid
    @NotEmpty
    private List<TargetSkillRequest> targetSkills;

    @Valid
    private CharmDto optionalCharm;

    @Min(1)
    @Max(20)
    private int maxResults = 5;

    public WeaponType getWeaponType() {
        return weaponType;
    }

    public void setWeaponType(WeaponType weaponType) {
        this.weaponType = weaponType;
    }

    public List<TargetSkillRequest> getTargetSkills() {
        return targetSkills;
    }

    public void setTargetSkills(List<TargetSkillRequest> targetSkills) {
        this.targetSkills = targetSkills;
    }

    public CharmDto getOptionalCharm() {
        return optionalCharm;
    }

    public void setOptionalCharm(CharmDto optionalCharm) {
        this.optionalCharm = optionalCharm;
    }

    public int getMaxResults() {
        return maxResults;
    }

    public void setMaxResults(int maxResults) {
        this.maxResults = maxResults;
    }
}
