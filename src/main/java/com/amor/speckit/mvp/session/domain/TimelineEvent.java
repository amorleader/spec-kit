package com.amor.speckit.mvp.session.domain;

import java.time.Instant;

public class TimelineEvent {
    private final Instant time;
    private final String action;
    private final String result;
    private final String error;

    public TimelineEvent(Instant time, String action, String result, String error) {
        this.time = time;
        this.action = action;
        this.result = result;
        this.error = error;
    }

    public Instant getTime() {
        return time;
    }

    public String getAction() {
        return action;
    }

    public String getResult() {
        return result;
    }

    public String getError() {
        return error;
    }
}
