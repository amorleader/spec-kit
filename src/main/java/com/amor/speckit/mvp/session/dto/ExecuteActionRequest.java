package com.amor.speckit.mvp.session.dto;

import javax.validation.constraints.NotBlank;

public class ExecuteActionRequest {
    @NotBlank
    private String action;
    private boolean approved;

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public boolean isApproved() {
        return approved;
    }

    public void setApproved(boolean approved) {
        this.approved = approved;
    }
}
