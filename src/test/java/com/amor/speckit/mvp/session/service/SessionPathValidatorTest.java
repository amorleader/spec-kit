package com.amor.speckit.mvp.session.service;

import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SessionPathValidatorTest {

    @TempDir
    Path tempDir;

    private final SessionPathValidator validator = new SessionPathValidator();

    @Test
    void shouldRejectPathTraversalOutsideWorkspace() {
        Path workspace = validator.resolveSessionWorkspace(tempDir, "session-a");

        assertThrows(SessionPathIsolationException.class,
                () -> validator.resolvePathInsideWorkspace(workspace, "..\\outside.txt"));
    }

    @Test
    void shouldRejectSymbolicLinkEscape() {
        Path workspace = validator.resolveSessionWorkspace(tempDir, "session-b");
        Path outside = tempDir.resolve("outside.txt");

        try {
            Files.writeString(outside, "secret");
            Path symlink = workspace.resolve("escape-link.txt");
            Files.createSymbolicLink(symlink, outside);

            assertThrows(SessionPathIsolationException.class,
                    () -> validator.resolvePathInsideWorkspace(workspace, "escape-link.txt"));
        } catch (UnsupportedOperationException | IOException ex) {
            Assumptions.assumeTrue(false,
                    "Skipping symbolic link test on this environment: " + ex.getMessage());
        }
    }

    @Test
    void shouldCreateSessionWorkspaceUnderRoot() {
        Path workspace = validator.resolveSessionWorkspace(tempDir, "session-c");
        assertTrue(workspace.startsWith(tempDir));
        assertTrue(Files.exists(workspace));
    }
}
