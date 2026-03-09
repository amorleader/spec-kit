package com.amor.speckit.mvp.ai.service;

public interface AiClient {
    String generateReply(String systemPrompt, String conversationContext, String userMessage);
}
