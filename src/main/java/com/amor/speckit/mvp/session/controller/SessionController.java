package com.amor.speckit.mvp.session.controller;

import com.amor.speckit.mvp.session.domain.SpecKitSession;
import com.amor.speckit.mvp.session.dto.ChatRequest;
import com.amor.speckit.mvp.session.dto.ChatResponse;
import com.amor.speckit.mvp.session.dto.CreateSessionRequest;
import com.amor.speckit.mvp.session.dto.CreateSessionResponse;
import com.amor.speckit.mvp.session.dto.ExecuteActionRequest;
import com.amor.speckit.mvp.session.dto.ExecuteActionResponse;
import com.amor.speckit.mvp.session.dto.MilestoneResponse;
import com.amor.speckit.mvp.session.dto.SessionArtifactsResponse;
import com.amor.speckit.mvp.session.dto.SessionSummaryResponse;
import com.amor.speckit.mvp.session.dto.StageActionRequest;
import com.amor.speckit.mvp.session.dto.StageActionResponse;
import com.amor.speckit.mvp.session.dto.TimelineEntryResponse;
import com.amor.speckit.mvp.session.dto.WorkspaceEntryResponse;
import com.amor.speckit.mvp.session.dto.WorkspaceTreeResponse;
import com.amor.speckit.mvp.session.service.SessionService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@Validated
@RequestMapping("/api/sessions")
public class SessionController {
    private final SessionService sessionService;

    public SessionController(SessionService sessionService) {
        this.sessionService = sessionService;
    }

    @PostMapping
    public CreateSessionResponse createSession(@Valid @RequestBody CreateSessionRequest request) {
        SpecKitSession session = sessionService.createSession(request.getProjectName(), request.getObjective());
        return new CreateSessionResponse(
                session.getSessionId(),
                session.getStatus(),
                maskWorkspacePath(session.getWorkspacePath(), session.getSessionId())
        );
    }

    @GetMapping("/latest")
    public SessionSummaryResponse latest() {
        Optional<SessionService.SessionSummary> latest = sessionService.getLatestSessionSummary();
        if (latest.isEmpty()) {
            return null;
        }
        return toSummary(latest.get());
    }

    @GetMapping("/{id}")
    public SessionSummaryResponse summary(@PathVariable("id") String sessionId) {
        return toSummary(sessionService.getSessionSummary(sessionId));
    }

    @PostMapping("/{id}/specify")
    public StageActionResponse specify(@PathVariable("id") String sessionId,
                                       @Valid @RequestBody StageActionRequest request) {
        SpecKitSession session = sessionService.runSpecify(sessionId, request.getInput());
        return new StageActionResponse(session.getSessionId(), session.getStatus());
    }

    @PostMapping("/{id}/plan")
    public StageActionResponse plan(@PathVariable("id") String sessionId,
                                    @Valid @RequestBody StageActionRequest request) {
        SpecKitSession session = sessionService.runPlan(sessionId, request.getInput());
        return new StageActionResponse(session.getSessionId(), session.getStatus());
    }

    @PostMapping("/{id}/tasks")
    public StageActionResponse tasks(@PathVariable("id") String sessionId,
                                     @Valid @RequestBody StageActionRequest request) {
        SpecKitSession session = sessionService.runTasks(sessionId, request.getInput());
        return new StageActionResponse(session.getSessionId(), session.getStatus());
    }

    @PostMapping("/{id}/chat")
    public ChatResponse chat(@PathVariable("id") String sessionId,
                             @Valid @RequestBody ChatRequest request) {
        SessionService.ChatResult result = sessionService.runChat(sessionId, request.getMessage());
        return new ChatResponse(result.getSessionId(), result.getStatus(), result.getAssistantMessage());
    }

    @PostMapping("/{id}/execute")
    public ExecuteActionResponse execute(@PathVariable("id") String sessionId,
                                         @Valid @RequestBody ExecuteActionRequest request) {
        SessionService.ExecutionResult result = sessionService.runControlledAction(sessionId, request.getAction());
        return new ExecuteActionResponse(
                result.getSessionId(),
                result.getAction(),
                result.getExitCode(),
                result.getStdout(),
                result.getStderr()
        );
    }

    @GetMapping("/{id}/artifacts")
    public SessionArtifactsResponse artifacts(@PathVariable("id") String sessionId) {
        SessionService.SessionArtifacts artifacts = sessionService.getArtifacts(sessionId);
        List<TimelineEntryResponse> timeline = artifacts.getTimeline().stream()
                .map(event -> new TimelineEntryResponse(
                        event.getTime(),
                        event.getAction(),
                        event.getResult(),
                        event.getError()
                ))
                .collect(Collectors.toList());

        return new SessionArtifactsResponse(
                artifacts.getSpecMd(),
                artifacts.getPlanMd(),
                artifacts.getTasksMd(),
                timeline
        );
    }

    @GetMapping("/{id}/workspace-tree")
    public WorkspaceTreeResponse workspaceTree(@PathVariable("id") String sessionId) {
        List<WorkspaceEntryResponse> entries = sessionService.listWorkspaceEntries(sessionId).stream()
                .map(entry -> new WorkspaceEntryResponse(entry.getPath(), entry.isDirectory(), entry.getDepth()))
                .collect(Collectors.toList());
        return new WorkspaceTreeResponse(entries);
    }

    @GetMapping("/{id}/milestone")
    public MilestoneResponse milestone(@PathVariable("id") String sessionId) {
        return new MilestoneResponse(sessionService.readMilestone(sessionId));
    }

    private SessionSummaryResponse toSummary(SessionService.SessionSummary summary) {
        return new SessionSummaryResponse(
                summary.getSessionId(),
                summary.getProjectName(),
                summary.getObjective(),
                summary.getStatus(),
                maskWorkspacePath(summary.getWorkspacePath(), summary.getSessionId()),
                summary.getCreatedAt()
        );
    }

    private String maskWorkspacePath(String workspacePath, String sessionId) {
        String normalized = workspacePath.replace('\\', '/');
        int idx = normalized.lastIndexOf('/');
        if (idx < 0) {
            return "***/" + sessionId;
        }
        return "***" + normalized.substring(idx);
    }
}
