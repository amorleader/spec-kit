package com.amor.speckit.mvp.session.domain;

import java.time.Instant;

public class SpecKitSession {
    private final String sessionId;
    private final String projectName;
    private final String objective;
    private final SessionStatus status;
    private final String workspacePath;
    private final String featureBranch;
    private final Instant createdAt;

    public SpecKitSession(String sessionId,
                          String projectName,
                          String objective,
                          SessionStatus status,
                          String workspacePath,
                          Instant createdAt) {
        this(sessionId, projectName, objective, status, workspacePath, null, createdAt);
    }

    public SpecKitSession(String sessionId,
                          String projectName,
                          String objective,
                          SessionStatus status,
                          String workspacePath,
                          String featureBranch,
                          Instant createdAt) {
        this.sessionId = sessionId;
        this.projectName = projectName;
        this.objective = objective;
        this.status = status;
        this.workspacePath = workspacePath;
        this.featureBranch = featureBranch;
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

    public String getFeatureBranch() {
        return featureBranch;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
