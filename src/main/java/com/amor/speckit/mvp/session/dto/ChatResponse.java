package com.amor.speckit.mvp.session.dto;

import com.amor.speckit.mvp.session.domain.SessionStatus;

public class ChatResponse {
    private final String sessionId;
    private final SessionStatus status;
    private final String assistantMessage;

    public ChatResponse(String sessionId, SessionStatus status, String assistantMessage) {
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
