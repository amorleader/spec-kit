package com.amor.speckit.mvp.ai.service;

import com.amor.speckit.mvp.ai.config.AiProperties;
import com.amor.speckit.mvp.session.service.SessionPathIsolationException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ProxySelector;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

@Component
@ConditionalOnProperty(prefix = "app.ai", name = "mode", havingValue = "http")
public class HttpAiClient implements AiClient {
    private final AiProperties aiProperties;
    private final ObjectMapper objectMapper;

    public HttpAiClient(AiProperties aiProperties, ObjectMapper objectMapper) {
        this.aiProperties = aiProperties;
        this.objectMapper = objectMapper;
    }

    @Override
    public String generateReply(String systemPrompt, String conversationContext, String userMessage) {
        if (aiProperties.getBaseUrl() == null || aiProperties.getBaseUrl().isBlank()) {
            throw new SessionPathIsolationException("AI base url is not configured");
        }
        if (aiProperties.getApiKey() == null || aiProperties.getApiKey().isBlank()) {
            throw new SessionPathIsolationException("AI api key is not configured");
        }

        try {
            HttpClient.Builder builder = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(aiProperties.getTimeoutSeconds()));
            if (aiProperties.isProxyEnabled() && aiProperties.getProxyHost() != null && !aiProperties.getProxyHost().isBlank()) {
                builder.proxy(ProxySelector.of(new InetSocketAddress(aiProperties.getProxyHost(), aiProperties.getProxyPort())));
            }
            HttpClient client = builder.build();

            String endpoint = aiProperties.getBaseUrl();
            if (endpoint.endsWith("/")) {
                endpoint = endpoint.substring(0, endpoint.length() - 1);
            }
            endpoint += "/chat/completions";

            String payload = objectMapper.createObjectNode()
                    .put("model", aiProperties.getModel())
                    .put("stream", false)
                    .set("messages", objectMapper.createArrayNode()
                            .add(objectMapper.createObjectNode().put("role", "system").put("content", systemPrompt))
                            .add(objectMapper.createObjectNode().put("role", "user").put("content", conversationContext + "\n\n用户最新输入:\n" + userMessage)))
                    .toString();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .timeout(Duration.ofSeconds(aiProperties.getTimeoutSeconds()))
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .header("Authorization", "Bearer " + aiProperties.getApiKey())
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                String body = response.body();
                String shortBody = body == null ? "" : body.replaceAll("\\s+", " ").trim();
                if (shortBody.length() > 240) {
                    shortBody = shortBody.substring(0, 240) + "...";
                }
                throw new SessionPathIsolationException("AI request failed with status "
                        + response.statusCode() + " body=" + shortBody);
            }

            String responseBody = response.body();
            String parsedContent = tryParseContent(responseBody);
            if (parsedContent == null || parsedContent.isBlank()) {
                throw new SessionPathIsolationException("AI response does not contain message content body="
                        + abbreviate(responseBody));
            }
            return parsedContent;
        } catch (IOException ex) {
            throw new SessionPathIsolationException("Failed to parse AI response body="
                    + abbreviate(ex.getMessage()), ex);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new SessionPathIsolationException("AI request interrupted", ex);
        }
    }

    private String tryParseContent(String responseBody) throws IOException {
        if (responseBody == null || responseBody.isBlank()) {
            return "";
        }

        try {
            JsonNode root = objectMapper.readTree(responseBody);
            String content = extractMessageContent(root);
            if (!content.isBlank()) {
                return content;
            }
        } catch (IOException ignored) {
            // Fallback for providers that sometimes return SSE-like chunks.
        }

        return parseSseLikeBody(responseBody);
    }

    private String extractMessageContent(JsonNode root) {
        JsonNode content = root.path("choices").path(0).path("message").path("content");
        if (!content.isMissingNode() && !content.asText().isBlank()) {
            return content.asText();
        }

        JsonNode wrappedContent = root.path("data").path("choices").path(0).path("message").path("content");
        if (!wrappedContent.isMissingNode() && !wrappedContent.asText().isBlank()) {
            return wrappedContent.asText();
        }
        return "";
    }

    private String parseSseLikeBody(String responseBody) {
        List<String> chunks = new ArrayList<>();
        String[] lines = responseBody.split("\\r?\\n");
        for (String line : lines) {
            String trimmed = line.trim();
            if (!trimmed.startsWith("data:")) {
                continue;
            }
            String data = trimmed.substring(5).trim();
            if (data.isBlank() || "[DONE]".equals(data)) {
                continue;
            }
            try {
                JsonNode node = objectMapper.readTree(data);
                String messageContent = extractMessageContent(node);
                if (!messageContent.isBlank()) {
                    return messageContent;
                }
                JsonNode delta = node.path("choices").path(0).path("delta").path("content");
                if (!delta.isMissingNode() && !delta.asText().isBlank()) {
                    chunks.add(delta.asText());
                }
            } catch (IOException ignored) {
                // Keep scanning other SSE lines.
            }
        }
        return String.join("", chunks);
    }

    private String abbreviate(String text) {
        if (text == null) {
            return "";
        }
        String normalized = text.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= 280) {
            return normalized;
        }
        return normalized.substring(0, 280) + "...";
    }
}
