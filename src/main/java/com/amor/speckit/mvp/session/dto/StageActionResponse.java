package com.amor.speckit.mvp.session.dto;

import com.amor.speckit.mvp.session.domain.SessionStatus;

public class StageActionResponse {
    private final String sessionId;
    private final SessionStatus status;

    public StageActionResponse(String sessionId, SessionStatus status) {
        this.sessionId = sessionId;
        this.status = status;
    }

    public String getSessionId() {
        return sessionId;
    }

    public SessionStatus getStatus() {
        return status;
    }
}
