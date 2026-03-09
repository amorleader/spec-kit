package com.amor.speckit.mvp.session.service;

import com.amor.speckit.mvp.session.domain.SessionStatus;
import com.amor.speckit.mvp.session.domain.SpecKitSession;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class SessionService {
    private final SessionWorkspaceManager sessionWorkspaceManager;
    private final Map<String, SpecKitSession> sessions = new ConcurrentHashMap<>();

    public SessionService(SessionWorkspaceManager sessionWorkspaceManager) {
        this.sessionWorkspaceManager = sessionWorkspaceManager;
    }

    public SpecKitSession createSession(String projectName, String objective) {
        String normalizedProjectName = normalize(projectName);
        String normalizedObjective = normalize(objective);
        if (normalizedProjectName.isEmpty()) {
            throw new IllegalArgumentException("projectName must not be blank");
        }
        if (normalizedObjective.isEmpty()) {
            throw new IllegalArgumentException("objective must not be blank");
        }

        String sessionId = UUID.randomUUID().toString();
        String workspacePath = sessionWorkspaceManager.createWorkspace(sessionId).toString();
        SpecKitSession session = new SpecKitSession(
                sessionId,
                normalizedProjectName,
                normalizedObjective,
                SessionStatus.CREATED,
                workspacePath,
                Instant.now()
        );
        sessions.put(sessionId, session);
        return session;
    }

    public Optional<SpecKitSession> getSession(String sessionId) {
        return Optional.ofNullable(sessions.get(sessionId));
    }

    private String normalize(String input) {
        return input == null ? "" : input.trim();
    }
}
