package com.amor.speckit.mvp.session.dto;

import javax.validation.constraints.NotBlank;

public class CreateSessionRequest {
    @NotBlank
    private String projectName;

    @NotBlank
    private String objective;

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getObjective() {
        return objective;
    }

    public void setObjective(String objective) {
        this.objective = objective;
    }
}
