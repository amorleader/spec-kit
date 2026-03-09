package com.amor.speckit.mvp.ai.service;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(prefix = "app.ai", name = "mode", havingValue = "mock", matchIfMissing = true)
public class MockAiClient implements AiClient {
    @Override
    public String generateReply(String systemPrompt, String conversationContext, String userMessage) {
        return "已收到你的需求。\n"
                + "我会继续在后台自动推进需求分析、方案和任务，并同步更新文档。\n"
                + "你刚刚提到的是: " + userMessage;
    }
}
