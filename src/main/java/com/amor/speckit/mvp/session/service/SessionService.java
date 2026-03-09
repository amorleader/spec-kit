package com.amor.speckit.mvp.session.service;

import com.amor.speckit.mvp.mhr.exception.NotFoundException;
import com.amor.speckit.mvp.session.domain.SessionStatus;
import com.amor.speckit.mvp.session.domain.SpecKitSession;
import com.amor.speckit.mvp.session.domain.TimelineEvent;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
public class SessionService {
    private static final String SCRIPT_ROOT = ".specify/scripts/powershell";
    private static final String TEMPLATE_ROOT = ".specify/templates";

    private final SessionWorkspaceManager sessionWorkspaceManager;
    private final ObjectMapper objectMapper;
    private final Map<String, SpecKitSession> sessions = new ConcurrentHashMap<>();
    private final Map<String, List<TimelineEvent>> timelines = new ConcurrentHashMap<>();

    public SessionService(SessionWorkspaceManager sessionWorkspaceManager,
                          ObjectMapper objectMapper) {
        this.sessionWorkspaceManager = sessionWorkspaceManager;
        this.objectMapper = objectMapper;
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
        String normalizedInput = normalize(input);
        if (normalizedInput.isEmpty()) {
            throw new IllegalArgumentException("input must not be blank");
        }

        SpecKitSession currentSession = requireSession(sessionId);
        try {
            Path workspace = Path.of(currentSession.getWorkspacePath());
            ensureWorkspaceScaffold(workspace);

            String shortName = toShortName(currentSession.getProjectName());
            ProcessExecutionResult result = runPowerShell(
                    workspace,
                    null,
                    "create-new-feature.ps1",
                    "-Json",
                    "-ShortName",
                    shortName,
                    normalizedInput
            );

            JsonNode json = parseJsonResult(result.stdout);
            String branchName = readRequiredText(json, "BRANCH_NAME", "Missing BRANCH_NAME from create-new-feature");
            Path specPath = resolveStageArtifact(workspace, branchName, "spec.md");
            appendSessionInput(specPath, "specify", normalizedInput);

            SpecKitSession updated = new SpecKitSession(
                    currentSession.getSessionId(),
                    currentSession.getProjectName(),
                    currentSession.getObjective(),
                    SessionStatus.SPECIFIED,
                    currentSession.getWorkspacePath(),
                    branchName,
                    currentSession.getCreatedAt()
            );
            sessions.put(sessionId, updated);
            addTimeline(sessionId, "specify", "success", "exit=0");
            return updated;
        } catch (RuntimeException ex) {
            addTimeline(sessionId, "specify", "failed", ex.getMessage());
            throw ex;
        }
    }

    public SpecKitSession runPlan(String sessionId, String input) {
        String normalizedInput = normalize(input);
        if (normalizedInput.isEmpty()) {
            throw new IllegalArgumentException("input must not be blank");
        }

        SpecKitSession session = requireSession(sessionId);
        if (session.getStatus() == SessionStatus.CREATED) {
            throw new IllegalStateException("specify must run before plan");
        }

        if (session.getFeatureBranch() == null || session.getFeatureBranch().isBlank()) {
            throw new IllegalStateException("feature branch is missing, run specify first");
        }

        try {
            Path workspace = Path.of(session.getWorkspacePath());
            ensureWorkspaceScaffold(workspace);
            runPowerShell(
                    workspace,
                    session.getFeatureBranch(),
                    "setup-plan.ps1",
                    "-Json"
            );

            Path planPath = resolveStageArtifact(workspace, session.getFeatureBranch(), "plan.md");
            appendSessionInput(planPath, "plan", normalizedInput);

            SpecKitSession updated = new SpecKitSession(
                    session.getSessionId(),
                    session.getProjectName(),
                    session.getObjective(),
                    SessionStatus.PLANNED,
                    session.getWorkspacePath(),
                    session.getFeatureBranch(),
                    session.getCreatedAt()
            );
            sessions.put(sessionId, updated);
            addTimeline(sessionId, "plan", "success", "exit=0");
            return updated;
        } catch (RuntimeException ex) {
            addTimeline(sessionId, "plan", "failed", ex.getMessage());
            throw ex;
        }
    }

    public SpecKitSession runTasks(String sessionId, String input) {
        String normalizedInput = normalize(input);
        if (normalizedInput.isEmpty()) {
            throw new IllegalArgumentException("input must not be blank");
        }

        SpecKitSession session = requireSession(sessionId);
        if (session.getStatus() != SessionStatus.PLANNED && session.getStatus() != SessionStatus.TASKS_GENERATED) {
            throw new IllegalStateException("plan must run before tasks");
        }

        if (session.getFeatureBranch() == null || session.getFeatureBranch().isBlank()) {
            throw new IllegalStateException("feature branch is missing, run specify first");
        }

        try {
            Path workspace = Path.of(session.getWorkspacePath());
            ensureWorkspaceScaffold(workspace);
            Path tasksPath = resolveStageArtifact(workspace, session.getFeatureBranch(), "tasks.md");
            ensureTasksTemplate(tasksPath, workspace);
            appendSessionInput(tasksPath, "tasks", normalizedInput);

            SpecKitSession updated = new SpecKitSession(
                    session.getSessionId(),
                    session.getProjectName(),
                    session.getObjective(),
                    SessionStatus.TASKS_GENERATED,
                    session.getWorkspacePath(),
                    session.getFeatureBranch(),
                    session.getCreatedAt()
            );
            sessions.put(sessionId, updated);
            addTimeline(sessionId, "tasks", "success", "template-generated");
            return updated;
        } catch (RuntimeException ex) {
            addTimeline(sessionId, "tasks", "failed", ex.getMessage());
            throw ex;
        }
    }

    public SessionArtifacts getArtifacts(String sessionId) {
        SpecKitSession session = requireSession(sessionId);
        String spec = readArtifact(session, "spec.md");
        String plan = readArtifact(session, "plan.md");
        String tasks = readArtifact(session, "tasks.md");
        List<TimelineEvent> timeline = new ArrayList<>(timelines.getOrDefault(sessionId, List.of()));
        return new SessionArtifacts(spec, plan, tasks, timeline);
    }

    private void ensureWorkspaceScaffold(Path workspace) {
        Path repoRoot = Path.of("").toAbsolutePath().normalize();
        Path sourceSpecify = repoRoot.resolve(".specify");
        if (!Files.exists(sourceSpecify)) {
            throw new SessionPathIsolationException(".specify directory not found in server working directory");
        }

        Path targetSpecify = workspace.resolve(".specify");
        if (!Files.exists(targetSpecify)) {
            copyDirectory(sourceSpecify, targetSpecify);
        }

        Path specsDir = workspace.resolve("specs");
        Path gitSentinel = workspace.resolve(".git");
        try {
            Files.createDirectories(specsDir);
            // Prevent script repo discovery from climbing to parent git repository.
            Files.createDirectories(gitSentinel);
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to initialize workspace specs directory", ex);
        }
    }

    private void copyDirectory(Path source, Path target) {
        try (Stream<Path> stream = Files.walk(source)) {
            for (Path sourcePath : stream.collect(Collectors.toList())) {
                Path relative = source.relativize(sourcePath);
                Path targetPath = target.resolve(relative).normalize();
                if (Files.isDirectory(sourcePath)) {
                    Files.createDirectories(targetPath);
                } else {
                    Files.createDirectories(targetPath.getParent());
                    Files.copy(sourcePath, targetPath, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.COPY_ATTRIBUTES);
                }
            }
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to copy workspace scaffold", ex);
        }
    }

    private ProcessExecutionResult runPowerShell(Path workingDirectory,
                                                 String featureBranch,
                                                 String scriptName,
                                                 String... args) {
        Path scriptPath = workingDirectory.resolve(SCRIPT_ROOT).resolve(scriptName).normalize();
        if (!Files.exists(scriptPath)) {
            throw new SessionPathIsolationException("Script not found: " + scriptName);
        }

        List<String> command = new ArrayList<>();
        command.add("pwsh");
        command.add("-NoLogo");
        command.add("-NoProfile");
        command.add("-ExecutionPolicy");
        command.add("Bypass");
        command.add("-File");
        command.add(scriptPath.toString());
        for (String arg : args) {
            command.add(arg);
        }

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        processBuilder.directory(workingDirectory.toFile());
        processBuilder.environment().put("GIT_CEILING_DIRECTORIES", workingDirectory.toAbsolutePath().toString());
        processBuilder.environment().put("SPECIFY_DISABLE_GIT", "1");
        if (featureBranch != null && !featureBranch.isBlank()) {
            processBuilder.environment().put("SPECIFY_FEATURE", featureBranch);
        }

        try {
            Process process = processBuilder.start();
            String stdout = readStream(process.getInputStream());
            String stderr = readStream(process.getErrorStream());
            int exitCode = process.waitFor();
            if (exitCode != 0) {
                throw new SessionPathIsolationException(
                        "Script failed: " + scriptName + " exit=" + exitCode + " stderr=" + trimLog(stderr)
                );
            }
            return new ProcessExecutionResult(exitCode, stdout, stderr);
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to start PowerShell command", ex);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new SessionPathIsolationException("PowerShell execution interrupted", ex);
        }
    }

    private String readStream(java.io.InputStream inputStream) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line).append(System.lineSeparator());
            }
            return sb.toString().trim();
        }
    }

    private JsonNode parseJsonResult(String output) {
        try {
            return objectMapper.readTree(output);
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to parse script json output: " + trimLog(output), ex);
        }
    }

    private String readRequiredText(JsonNode node, String fieldName, String message) {
        JsonNode value = node.get(fieldName);
        if (value == null || value.asText().isBlank()) {
            throw new SessionPathIsolationException(message);
        }
        return value.asText();
    }

    private Path resolveStageArtifact(Path workspace, String featureBranch, String artifactName) {
        Path path = workspace.resolve("specs").resolve(featureBranch).resolve(artifactName);
        Path normalized = path.normalize();
        if (!normalized.startsWith(workspace.normalize())) {
            throw new SessionPathIsolationException("Artifact path escapes workspace");
        }
        return normalized;
    }

    private void ensureTasksTemplate(Path tasksPath, Path workspace) {
        if (Files.exists(tasksPath)) {
            return;
        }

        Path templatePath = workspace.resolve(TEMPLATE_ROOT).resolve("tasks-template.md").normalize();
        try {
            Files.createDirectories(tasksPath.getParent());
            if (Files.exists(templatePath)) {
                Files.copy(templatePath, tasksPath, StandardCopyOption.REPLACE_EXISTING);
            } else {
                Files.writeString(tasksPath, "# Tasks\n\n", StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            }
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to create tasks.md", ex);
        }
    }

    private void appendSessionInput(Path artifactPath, String stageName, String input) {
        try {
            Files.createDirectories(artifactPath.getParent());
            if (!Files.exists(artifactPath)) {
                Files.writeString(
                        artifactPath,
                        "# " + stageName.toUpperCase() + System.lineSeparator() + System.lineSeparator(),
                        StandardOpenOption.CREATE,
                        StandardOpenOption.TRUNCATE_EXISTING
                );
            }
            String update = System.lineSeparator()
                    + "## Session Input " + Instant.now() + System.lineSeparator()
                    + input + System.lineSeparator();
            Files.writeString(artifactPath, update, StandardOpenOption.APPEND);
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to update artifact: " + artifactPath.getFileName(), ex);
        }
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
        Path workspace = Path.of(session.getWorkspacePath());
        Path artifactPath;
        if (session.getFeatureBranch() != null && !session.getFeatureBranch().isBlank()) {
            artifactPath = resolveStageArtifact(workspace, session.getFeatureBranch(), artifactName);
        } else {
            artifactPath = sessionWorkspaceManager.resolvePath(session.getWorkspacePath(), artifactName);
        }
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

    private String trimLog(String log) {
        if (log == null) {
            return "";
        }
        String normalized = log.trim().replaceAll("\\s+", " ");
        if (normalized.length() <= 280) {
            return normalized;
        }
        return normalized.substring(0, 280) + "...";
    }

    private String toShortName(String projectName) {
        String normalized = projectName.toLowerCase().replaceAll("[^a-z0-9]+", "-");
        normalized = normalized.replaceAll("^-+", "").replaceAll("-+$", "");
        if (normalized.isBlank()) {
            return "feature";
        }
        if (normalized.length() <= 40) {
            return normalized;
        }
        return normalized.substring(0, 40).replaceAll("-+$", "");
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

    private static class ProcessExecutionResult {
        private final int exitCode;
        private final String stdout;
        private final String stderr;

        private ProcessExecutionResult(int exitCode, String stdout, String stderr) {
            this.exitCode = exitCode;
            this.stdout = stdout;
            this.stderr = stderr;
        }
    }
}
