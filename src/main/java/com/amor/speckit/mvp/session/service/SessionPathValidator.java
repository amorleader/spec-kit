package com.amor.speckit.mvp.session.service;

import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;

@Component
public class SessionPathValidator {

    public Path ensureWorkspaceRoot(Path workspaceRoot) {
        try {
            Files.createDirectories(workspaceRoot);
            return workspaceRoot.toRealPath();
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to initialize workspace root", ex);
        }
    }

    public Path resolveSessionWorkspace(Path workspaceRoot, String sessionId) {
        Path normalizedRoot = ensureWorkspaceRoot(workspaceRoot);
        Path candidate = normalizedRoot.resolve(sessionId).normalize();
        validateInsideRoot(normalizedRoot, candidate);

        try {
            Files.createDirectories(candidate);
            Path realWorkspace = candidate.toRealPath();
            validateInsideRoot(normalizedRoot, realWorkspace);
            return realWorkspace;
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to create session workspace", ex);
        }
    }

    public Path resolvePathInsideWorkspace(Path sessionWorkspace, String relativePath) {
        if (relativePath == null || relativePath.trim().isEmpty()) {
            throw new SessionPathIsolationException("Relative path must not be empty");
        }

        Path inputPath = Path.of(relativePath);
        if (inputPath.isAbsolute()) {
            throw new SessionPathIsolationException("Absolute path is not allowed");
        }

        Path normalizedWorkspace = resolveExistingDirectory(sessionWorkspace);
        Path candidate = normalizedWorkspace.resolve(inputPath).normalize();
        validateInsideRoot(normalizedWorkspace, candidate);

        if (Files.exists(candidate, LinkOption.NOFOLLOW_LINKS)) {
            if (Files.isSymbolicLink(candidate)) {
                throw new SessionPathIsolationException("Symbolic link target is not allowed");
            }
            try {
                Path realCandidate = candidate.toRealPath();
                validateInsideRoot(normalizedWorkspace, realCandidate);
                return realCandidate;
            } catch (IOException ex) {
                throw new SessionPathIsolationException("Failed to resolve path", ex);
            }
        }

        Path parent = candidate.getParent();
        if (parent != null) {
            Path realParent = resolveExistingDirectory(parent);
            validateInsideRoot(normalizedWorkspace, realParent);
        }
        return candidate;
    }

    private Path resolveExistingDirectory(Path path) {
        try {
            Path realPath = path.toRealPath(LinkOption.NOFOLLOW_LINKS);
            if (!Files.isDirectory(realPath, LinkOption.NOFOLLOW_LINKS)) {
                throw new SessionPathIsolationException("Path is not a directory: " + path);
            }
            return realPath;
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to resolve directory: " + path, ex);
        }
    }

    private void validateInsideRoot(Path root, Path candidate) {
        if (!candidate.startsWith(root)) {
            throw new SessionPathIsolationException("Path escapes workspace isolation");
        }
    }
}
