package com.amor.speckit.mvp.ai.service;

import com.amor.speckit.mvp.ai.config.AiProperties;
import com.amor.speckit.mvp.session.service.SessionPathIsolationException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertThrows;

class HttpAiClientTest {

    private HttpServer server;

    @AfterEach
    void tearDown() {
        if (server != null) {
            server.stop(0);
        }
    }

    @Test
    void shouldReturnReplyWhenApiRespondsWithContent() throws IOException {
        server = HttpServer.create(new InetSocketAddress(0), 0);
        server.createContext("/chat/completions", new JsonHandler(200,
                "{\"choices\":[{\"message\":{\"content\":\"ok-reply\"}}]}"));
        server.start();

        AiProperties properties = new AiProperties();
        properties.setMode("http");
        properties.setBaseUrl("http://127.0.0.1:" + server.getAddress().getPort() + "/");
        properties.setApiKey("test-key");
        properties.setModel("gpt-4o-mini");
        properties.setTimeoutSeconds(5);

        HttpAiClient client = new HttpAiClient(properties, new ObjectMapper());

        String reply = client.generateReply("sys", "ctx", "msg");
        assertEquals("ok-reply", reply);
    }

    @Test
    void shouldThrowWhenBaseUrlIsMissing() {
        AiProperties properties = new AiProperties();
        properties.setMode("http");
        properties.setBaseUrl("");
        properties.setApiKey("test-key");

        HttpAiClient client = new HttpAiClient(properties, new ObjectMapper());

        SessionPathIsolationException ex = assertThrows(SessionPathIsolationException.class,
                () -> client.generateReply("sys", "ctx", "msg"));
        assertEquals("AI base url is not configured", ex.getMessage());
    }

    @Test
    void shouldThrowWhenApiReturnsNon2xx() throws IOException {
        server = HttpServer.create(new InetSocketAddress(0), 0);
        server.createContext("/chat/completions", new JsonHandler(500,
                "{\"error\":\"internal\"}"));
        server.start();

        AiProperties properties = new AiProperties();
        properties.setMode("http");
        properties.setBaseUrl("http://127.0.0.1:" + server.getAddress().getPort());
        properties.setApiKey("test-key");
        properties.setModel("gpt-4o-mini");
        properties.setTimeoutSeconds(5);

        HttpAiClient client = new HttpAiClient(properties, new ObjectMapper());

        SessionPathIsolationException ex = assertThrows(SessionPathIsolationException.class,
                () -> client.generateReply("sys", "ctx", "msg"));
        assertTrue(ex.getMessage().startsWith("AI request failed with status 500 body="));
    }

    @Test
    void shouldParseSseStyleResponse() throws IOException {
        server = HttpServer.create(new InetSocketAddress(0), 0);
        server.createContext("/chat/completions", new JsonHandler(200,
                "data: {\"choices\":[{\"delta\":{\"content\":\"hello \"}}]}\n"
                        + "data: {\"choices\":[{\"delta\":{\"content\":\"world\"}}]}\n"
                        + "data: [DONE]\n"));
        server.start();

        AiProperties properties = new AiProperties();
        properties.setMode("http");
        properties.setBaseUrl("http://127.0.0.1:" + server.getAddress().getPort());
        properties.setApiKey("test-key");
        properties.setModel("gpt-4o-mini");
        properties.setTimeoutSeconds(5);

        HttpAiClient client = new HttpAiClient(properties, new ObjectMapper());

        String reply = client.generateReply("sys", "ctx", "msg");
        assertEquals("hello world", reply);
    }

    private static class JsonHandler implements HttpHandler {
        private final int status;
        private final String body;

        private JsonHandler(int status, String body) {
            this.status = status;
            this.body = body;
        }

        @Override
        public void handle(HttpExchange exchange) throws IOException {
            byte[] response = body.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().add("Content-Type", "application/json");
            exchange.sendResponseHeaders(status, response.length);
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(response);
            }
        }
    }
}
