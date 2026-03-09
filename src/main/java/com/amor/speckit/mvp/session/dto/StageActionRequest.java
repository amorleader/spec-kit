package com.amor.speckit.mvp.session.dto;

import javax.validation.constraints.NotBlank;

public class StageActionRequest {
    @NotBlank
    private String input;

    public String getInput() {
        return input;
    }

    public void setInput(String input) {
        this.input = input;
    }
}
