package com.amor.speckit.mvp.session.dto;

public class MilestoneResponse {
    private final String text;

    public MilestoneResponse(String text) {
        this.text = text;
    }

    public String getText() {
        return text;
    }
}
