package com.amor.speckit.mvp.session.service;

import com.amor.speckit.mvp.session.config.SessionProperties;
import org.springframework.stereotype.Component;

import java.nio.file.Path;

@Component
public class SessionWorkspaceManager {
    private final SessionProperties sessionProperties;
    private final SessionPathValidator sessionPathValidator;

    public SessionWorkspaceManager(SessionProperties sessionProperties,
                                   SessionPathValidator sessionPathValidator) {
        this.sessionProperties = sessionProperties;
        this.sessionPathValidator = sessionPathValidator;
    }

    public Path createWorkspace(String sessionId) {
        Path workspaceRoot = Path.of(sessionProperties.getWorkspaceRoot());
        return sessionPathValidator.resolveSessionWorkspace(workspaceRoot, sessionId);
    }

    public Path resolvePath(String workspacePath, String relativePath) {
        Path sessionWorkspace = Path.of(workspacePath);
        return sessionPathValidator.resolvePathInsideWorkspace(sessionWorkspace, relativePath);
    }
}
