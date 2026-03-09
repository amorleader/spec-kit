package com.amor.speckit.mvp.session.domain;

import java.time.Instant;

public class SpecKitSession {
    private final String sessionId;
    private final String projectName;
    private final String objective;
    private final SessionStatus status;
    private final String workspacePath;
    private final Instant createdAt;

    public SpecKitSession(String sessionId,
                          String projectName,
                          String objective,
                          SessionStatus status,
                          String workspacePath,
                          Instant createdAt) {
        this.sessionId = sessionId;
        this.projectName = projectName;
        this.objective = objective;
        this.status = status;
        this.workspacePath = workspacePath;
        this.createdAt = createdAt;
    }

    public String getSessionId() {
        return sessionId;
    }

    public String getProjectName() {
        return projectName;
    }

    public String getObjective() {
        return objective;
    }

    public SessionStatus getStatus() {
        return status;
    }

    public String getWorkspacePath() {
        return workspacePath;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
