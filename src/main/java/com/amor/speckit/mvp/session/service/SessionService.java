package com.amor.speckit.mvp.session.service;

import com.amor.speckit.mvp.mhr.exception.NotFoundException;
import com.amor.speckit.mvp.session.domain.SessionStatus;
import com.amor.speckit.mvp.session.domain.SpecKitSession;
import com.amor.speckit.mvp.session.domain.TimelineEvent;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class SessionService {
    private final SessionWorkspaceManager sessionWorkspaceManager;
    private final Map<String, SpecKitSession> sessions = new ConcurrentHashMap<>();
    private final Map<String, List<TimelineEvent>> timelines = new ConcurrentHashMap<>();

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
        timelines.put(sessionId, new CopyOnWriteArrayList<>());
        addTimeline(sessionId, "create_session", "success", null);
        return session;
    }

    public Optional<SpecKitSession> getSession(String sessionId) {
        return Optional.ofNullable(sessions.get(sessionId));
    }

    public SpecKitSession runSpecify(String sessionId, String input) {
        return runStage(sessionId, normalize(input), "specify", "spec.md", SessionStatus.SPECIFIED);
    }

    public SpecKitSession runPlan(String sessionId, String input) {
        SpecKitSession session = requireSession(sessionId);
        if (session.getStatus() == SessionStatus.CREATED) {
            throw new IllegalStateException("specify must run before plan");
        }
        return runStage(sessionId, normalize(input), "plan", "plan.md", SessionStatus.PLANNED);
    }

    public SpecKitSession runTasks(String sessionId, String input) {
        SpecKitSession session = requireSession(sessionId);
        if (session.getStatus() != SessionStatus.PLANNED && session.getStatus() != SessionStatus.TASKS_GENERATED) {
            throw new IllegalStateException("plan must run before tasks");
        }
        return runStage(sessionId, normalize(input), "tasks", "tasks.md", SessionStatus.TASKS_GENERATED);
    }

    public SessionArtifacts getArtifacts(String sessionId) {
        SpecKitSession session = requireSession(sessionId);
        String spec = readArtifact(session, "spec.md");
        String plan = readArtifact(session, "plan.md");
        String tasks = readArtifact(session, "tasks.md");
        List<TimelineEvent> timeline = new ArrayList<>(timelines.getOrDefault(sessionId, List.of()));
        return new SessionArtifacts(spec, plan, tasks, timeline);
    }

    private SpecKitSession runStage(String sessionId,
                                    String input,
                                    String stageName,
                                    String artifactName,
                                    SessionStatus nextStatus) {
        if (input.isEmpty()) {
            throw new IllegalArgumentException("input must not be blank");
        }

        SpecKitSession currentSession = requireSession(sessionId);
        try {
            Path artifactPath = sessionWorkspaceManager.resolvePath(currentSession.getWorkspacePath(), artifactName);
            upsertArtifact(currentSession, stageName, input, artifactPath);

            SpecKitSession updated = new SpecKitSession(
                    currentSession.getSessionId(),
                    currentSession.getProjectName(),
                    currentSession.getObjective(),
                    nextStatus,
                    currentSession.getWorkspacePath(),
                    currentSession.getCreatedAt()
            );
            sessions.put(sessionId, updated);
            addTimeline(sessionId, stageName, "success", null);
            return updated;
        } catch (RuntimeException ex) {
            addTimeline(sessionId, stageName, "failed", ex.getMessage());
            throw ex;
        }
    }

    private void upsertArtifact(SpecKitSession session,
                                String stageName,
                                String input,
                                Path artifactPath) {
        boolean exists = Files.exists(artifactPath);
        String content;
        if (!exists) {
            content = "# " + stageName.toUpperCase() + "\n\n"
                    + "## Project\n" + session.getProjectName() + "\n\n"
                    + "## Objective\n" + session.getObjective() + "\n\n"
                    + "## Input\n" + input + "\n";
            writeFile(artifactPath, content, false);
            return;
        }

        content = "\n\n## Update " + Instant.now() + "\n" + input + "\n";
        writeFile(artifactPath, content, true);
    }

    private void writeFile(Path artifactPath, String content, boolean append) {
        try {
            if (append) {
                Files.writeString(artifactPath, content, StandardOpenOption.APPEND);
            } else {
                Files.writeString(artifactPath, content, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            }
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to write artifact: " + artifactPath.getFileName(), ex);
        }
    }

    private String readArtifact(SpecKitSession session, String artifactName) {
        Path artifactPath = sessionWorkspaceManager.resolvePath(session.getWorkspacePath(), artifactName);
        if (!Files.exists(artifactPath)) {
            return "";
        }
        try {
            return Files.readString(artifactPath);
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to read artifact: " + artifactName, ex);
        }
    }

    private SpecKitSession requireSession(String sessionId) {
        return getSession(sessionId)
                .orElseThrow(() -> new NotFoundException("Session not found: " + sessionId));
    }

    private void addTimeline(String sessionId, String action, String result, String error) {
        timelines.computeIfAbsent(sessionId, key -> new CopyOnWriteArrayList<>())
                .add(new TimelineEvent(Instant.now(), action, result, error));
    }

    private String normalize(String input) {
        return input == null ? "" : input.trim();
    }

    public static class SessionArtifacts {
        private final String specMd;
        private final String planMd;
        private final String tasksMd;
        private final List<TimelineEvent> timeline;

        public SessionArtifacts(String specMd,
                                String planMd,
                                String tasksMd,
                                List<TimelineEvent> timeline) {
            this.specMd = specMd;
            this.planMd = planMd;
            this.tasksMd = tasksMd;
            this.timeline = timeline;
        }

        public String getSpecMd() {
            return specMd;
        }

        public String getPlanMd() {
            return planMd;
        }

        public String getTasksMd() {
            return tasksMd;
        }

        public List<TimelineEvent> getTimeline() {
            return timeline;
        }
    }
}
