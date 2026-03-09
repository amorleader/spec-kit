package com.amor.speckit.mvp.session.dto;

import com.amor.speckit.mvp.session.domain.SessionStatus;

public class CreateSessionResponse {
    private final String sessionId;
    private final SessionStatus status;
    private final String workspacePath;

    public CreateSessionResponse(String sessionId, SessionStatus status, String workspacePath) {
        this.sessionId = sessionId;
        this.status = status;
        this.workspacePath = workspacePath;
    }

    public String getSessionId() {
        return sessionId;
    }

    public SessionStatus getStatus() {
        return status;
    }

    public String getWorkspacePath() {
        return workspacePath;
    }
}
