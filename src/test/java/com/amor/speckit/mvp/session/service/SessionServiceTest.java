package com.amor.speckit.mvp.session.service;

import com.amor.speckit.mvp.session.config.SessionProperties;
import com.amor.speckit.mvp.session.domain.SessionStatus;
import com.amor.speckit.mvp.session.domain.SpecKitSession;
import com.amor.speckit.mvp.ai.service.MockAiClient;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SessionServiceTest {

    @TempDir
    Path tempDir;

    @Test
    void shouldCreateSessionWithIsolatedWorkspace() {
        SessionProperties properties = new SessionProperties();
        properties.setWorkspaceRoot(tempDir.toString());

        SessionWorkspaceManager workspaceManager = new SessionWorkspaceManager(
                properties,
                new SessionPathValidator()
        );
        SessionService sessionService = new SessionService(workspaceManager, new ObjectMapper(), new MockAiClient());

        SpecKitSession session = sessionService.createSession("spec-kit-poc", "deliver mvp");

        assertNotNull(session.getSessionId());
        assertEquals("spec-kit-poc", session.getProjectName());
        assertEquals("deliver mvp", session.getObjective());
        assertEquals(SessionStatus.CREATED, session.getStatus());
        assertNotNull(session.getCreatedAt());

        Path workspacePath = Path.of(session.getWorkspacePath());
        assertTrue(Files.exists(workspacePath));
        assertTrue(workspacePath.startsWith(tempDir));
        assertFalse(sessionService.getSession(session.getSessionId()).isEmpty());
    }
}
