package com.amor.speckit.mvp.session.controller;

import com.amor.speckit.mvp.session.domain.SpecKitSession;
import com.amor.speckit.mvp.session.dto.ChatRequest;
import com.amor.speckit.mvp.session.dto.ChatResponse;
import com.amor.speckit.mvp.session.dto.CreateSessionRequest;
import com.amor.speckit.mvp.session.dto.CreateSessionResponse;
import com.amor.speckit.mvp.session.dto.SessionArtifactsResponse;
import com.amor.speckit.mvp.session.dto.StageActionRequest;
import com.amor.speckit.mvp.session.dto.StageActionResponse;
import com.amor.speckit.mvp.session.dto.TimelineEntryResponse;
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

    private String maskWorkspacePath(String workspacePath, String sessionId) {
        String normalized = workspacePath.replace('\\', '/');
        int idx = normalized.lastIndexOf('/');
        if (idx < 0) {
            return "***/" + sessionId;
        }
        return "***" + normalized.substring(idx);
    }
}
