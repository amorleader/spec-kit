package com.amor.speckit.mvp.session.service;

import com.amor.speckit.mvp.ai.service.AiClient;
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
    private static final String MILESTONE_PATH = ".spec-kit/milestone.md";

    private final SessionWorkspaceManager sessionWorkspaceManager;
    private final ObjectMapper objectMapper;
    private final AiClient aiClient;
    private final Map<String, SpecKitSession> sessions = new ConcurrentHashMap<>();
    private final Map<String, List<TimelineEvent>> timelines = new ConcurrentHashMap<>();

    public SessionService(SessionWorkspaceManager sessionWorkspaceManager,
                          ObjectMapper objectMapper,
                          AiClient aiClient) {
        this.sessionWorkspaceManager = sessionWorkspaceManager;
        this.objectMapper = objectMapper;
        this.aiClient = aiClient;
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
        appendMilestoneSnapshot(session, "create_session", "会话已创建，等待用户输入需求。", true);
        return session;
    }

    public Optional<SpecKitSession> getSession(String sessionId) {
        return Optional.ofNullable(sessions.get(sessionId));
    }

    public Optional<SessionSummary> getLatestSessionSummary() {
        return sessions.values().stream()
                .sorted((left, right) -> right.getCreatedAt().compareTo(left.getCreatedAt()))
                .map(this::toSummary)
                .findFirst();
    }

    public SessionSummary getSessionSummary(String sessionId) {
        return toSummary(requireSession(sessionId));
    }

    public List<WorkspaceEntry> listWorkspaceEntries(String sessionId) {
        SpecKitSession session = requireSession(sessionId);
        Path workspace = Path.of(session.getWorkspacePath()).normalize();
        try (Stream<Path> stream = Files.walk(workspace, 8)) {
            return stream
                    .filter(path -> !path.equals(workspace))
                    .filter(path -> !path.toString().contains(".git"))
                    .map(path -> toWorkspaceEntry(workspace, path))
                    .sorted((a, b) -> a.getPath().compareToIgnoreCase(b.getPath()))
                    .collect(Collectors.toList());
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to list workspace entries", ex);
        }
    }

    public String readMilestone(String sessionId) {
        SpecKitSession session = requireSession(sessionId);
        Path milestone = Path.of(session.getWorkspacePath()).resolve(MILESTONE_PATH).normalize();
        if (!Files.exists(milestone)) {
            return "";
        }
        try {
            return Files.readString(milestone);
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to read milestone", ex);
        }
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

    public ChatResult runChat(String sessionId, String userMessage) {
        String normalizedMessage = normalize(userMessage);
        if (normalizedMessage.isEmpty()) {
            throw new IllegalArgumentException("message must not be blank");
        }

        SpecKitSession before = requireSession(sessionId);
        SpecKitSession after;
        String internalAction;

        if (before.getStatus() == SessionStatus.CREATED) {
            internalAction = "specify";
            after = runSpecify(sessionId, normalizedMessage);
        } else if (before.getStatus() == SessionStatus.SPECIFIED) {
            internalAction = "plan";
            after = runPlan(sessionId, normalizedMessage);
        } else {
            internalAction = "tasks";
            after = runTasks(sessionId, normalizedMessage);
        }

        String assistantMessage;
        try {
            String systemPrompt = "你是企业内部的 AI 编程助手。"
                    + "你需要用中文给出清晰、可执行、面向产品落地的回复。"
                    + "不要要求用户理解 specify/plan/tasks 等内部步骤，只给业务可理解表达。";
            String context = buildConversationContext(after, internalAction);
            assistantMessage = aiClient.generateReply(systemPrompt, context, normalizedMessage);
            addTimeline(sessionId, "chat", "success", "orchestrated=" + internalAction);
            appendMilestoneSnapshot(after, "chat", "AI回复成功，继续推进。", false);
        } catch (RuntimeException ex) {
            String reason = trimLog(ex.getMessage());
            assistantMessage = "已收到你的输入，并完成内部推进。\n"
                    + "当前内部状态: " + after.getStatus() + "\n"
                + "AI 回复生成暂时失败，请重试一次。\n"
                + "失败原因: " + reason;
            addTimeline(sessionId, "chat_ai_failed", "failed", reason);
            appendMilestoneSnapshot(after, "chat_ai_failed", "AI回复失败: " + reason, false);
        }
        return new ChatResult(after.getSessionId(), after.getStatus(), assistantMessage);
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

    private String buildAssistantMessage(SpecKitSession session, String internalAction) {
        String statusText;
        String nextHint;
        switch (session.getStatus()) {
            case SPECIFIED:
                statusText = "我已经完成需求梳理并更新了规格草案。";
                nextHint = "继续描述你希望的实现细节，我会自动补充方案设计。";
                break;
            case PLANNED:
                statusText = "我已经把方案设计落到计划文档中。";
                nextHint = "继续补充约束或偏好，我会自动细化任务清单。";
                break;
            case TASKS_GENERATED:
                statusText = "我已经更新了可执行任务清单。";
                nextHint = "你可以继续对话提出修改，我会持续调整文档与任务。";
                break;
            default:
                statusText = "我已收到你的输入并完成内部处理。";
                nextHint = "请继续告诉我你的需求变化。";
                break;
        }

        return "收到，你的需求已同步。"
                + "\n"
                + statusText
                + "\n"
                + "当前内部动作: " + internalAction
                + "\n"
                + "当前状态: " + session.getStatus()
                + "\n"
                + nextHint;
    }

    private String buildConversationContext(SpecKitSession session, String internalAction) {
        SessionArtifacts artifacts = getArtifacts(session.getSessionId());
        return "项目名: " + session.getProjectName() + "\n"
                + "目标: " + session.getObjective() + "\n"
                + "内部动作: " + internalAction + "\n"
                + "当前状态: " + session.getStatus() + "\n"
                + "里程碑摘要:\n" + summarize(readMilestoneTail(session)) + "\n"
                + "spec.md 摘要:\n" + summarize(artifacts.getSpecMd()) + "\n"
                + "plan.md 摘要:\n" + summarize(artifacts.getPlanMd()) + "\n"
                + "tasks.md 摘要:\n" + summarize(artifacts.getTasksMd());
    }

    private String readMilestoneTail(SpecKitSession session) {
        String text = readMilestone(session.getSessionId());
        if (text.isBlank()) {
            return "(空)";
        }
        if (text.length() <= 1200) {
            return text;
        }
        return text.substring(text.length() - 1200);
    }

    private void appendMilestoneSnapshot(SpecKitSession session, String trigger, String note, boolean resetFile) {
        Path milestone = Path.of(session.getWorkspacePath()).resolve(MILESTONE_PATH).normalize();
        try {
            Files.createDirectories(milestone.getParent());
            String rank = stageCheckbox(session.getStatus());
            String snapshot = "\n## " + Instant.now() + " | " + trigger + "\n"
                    + "- sessionId: " + session.getSessionId() + "\n"
                    + "- project: " + session.getProjectName() + "\n"
                    + "- objective: " + session.getObjective() + "\n"
                    + "- status: " + session.getStatus() + "\n"
                    + "- featureBranch: " + (session.getFeatureBranch() == null ? "" : session.getFeatureBranch()) + "\n"
                    + "- note: " + note + "\n"
                    + "- progress: " + rank + "\n";
            if (resetFile || !Files.exists(milestone)) {
                Files.writeString(milestone,
                        "# Session Milestones\n\n用于关联 sessionId 的里程碑记录，给 AI 作为历史上下文。\n" + snapshot,
                        StandardOpenOption.CREATE,
                        StandardOpenOption.TRUNCATE_EXISTING);
            } else {
                Files.writeString(milestone, snapshot, StandardOpenOption.APPEND);
            }
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to write milestone snapshot", ex);
        }
    }

    private String stageCheckbox(SessionStatus status) {
        boolean specified = status == SessionStatus.SPECIFIED || status == SessionStatus.PLANNED || status == SessionStatus.TASKS_GENERATED;
        boolean planned = status == SessionStatus.PLANNED || status == SessionStatus.TASKS_GENERATED;
        boolean tasks = status == SessionStatus.TASKS_GENERATED;
        return "[" + (specified ? "x" : " ") + "] SPECIFIED "
                + "[" + (planned ? "x" : " ") + "] PLANNED "
                + "[" + (tasks ? "x" : " ") + "] TASKS_GENERATED";
    }

    private SessionSummary toSummary(SpecKitSession session) {
        return new SessionSummary(
                session.getSessionId(),
                session.getProjectName(),
                session.getObjective(),
                session.getStatus(),
                session.getWorkspacePath(),
                session.getCreatedAt()
        );
    }

    private WorkspaceEntry toWorkspaceEntry(Path workspace, Path path) {
        Path relative = workspace.relativize(path);
        int depth = relative.getNameCount();
        String normalized = relative.toString().replace('\\', '/');
        return new WorkspaceEntry(normalized, Files.isDirectory(path), depth);
    }

    private String summarize(String text) {
        if (text == null || text.isBlank()) {
            return "(空)";
        }
        String normalized = text.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= 500) {
            return normalized;
        }
        return normalized.substring(0, 500) + "...";
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

    public static class ChatResult {
        private final String sessionId;
        private final SessionStatus status;
        private final String assistantMessage;

        public ChatResult(String sessionId, SessionStatus status, String assistantMessage) {
            this.sessionId = sessionId;
            this.status = status;
            this.assistantMessage = assistantMessage;
        }

        public String getSessionId() {
            return sessionId;
        }

        public SessionStatus getStatus() {
            return status;
        }

        public String getAssistantMessage() {
            return assistantMessage;
        }
    }

    public static class SessionSummary {
        private final String sessionId;
        private final String projectName;
        private final String objective;
        private final SessionStatus status;
        private final String workspacePath;
        private final Instant createdAt;

        public SessionSummary(String sessionId,
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

    public static class WorkspaceEntry {
        private final String path;
        private final boolean directory;
        private final int depth;

        public WorkspaceEntry(String path, boolean directory, int depth) {
            this.path = path;
            this.directory = directory;
            this.depth = depth;
        }

        public String getPath() {
            return path;
        }

        public boolean isDirectory() {
            return directory;
        }

        public int getDepth() {
            return depth;
        }
    }
}
