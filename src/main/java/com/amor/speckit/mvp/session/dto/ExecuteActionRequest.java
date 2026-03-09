package com.amor.speckit.mvp.session.dto;

import javax.validation.constraints.NotBlank;

public class ExecuteActionRequest {
    @NotBlank
    private String action;

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }
}
