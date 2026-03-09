package com.amor.speckit.mvp.session.controller;

import com.amor.speckit.mvp.ai.service.AiClient;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import com.amor.speckit.mvp.mhr.MhrBuildPlannerApplication;

import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.emptyOrNullString;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(
        classes = MhrBuildPlannerApplication.class,
        properties = "app.spec-kit.session.workspace-root=target/test-workspaces"
)
@AutoConfigureMockMvc
class SessionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

        @MockBean
        private AiClient aiClient;

    @Test
    void shouldCreateSession() throws Exception {
        when(aiClient.generateReply(anyString(), anyString(), anyString()))
                .thenReturn("mock assistant reply");
        String body = "{\"projectName\":\"spec-kit-poc\",\"objective\":\"build mvp\"}";

        mockMvc.perform(post("/api/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId", not(emptyOrNullString())))
                .andExpect(jsonPath("$.status").value("CREATED"))
                .andExpect(jsonPath("$.workspacePath").value(org.hamcrest.Matchers.startsWith("***/")));

        mockMvc.perform(get("/api/sessions/latest"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId", not(emptyOrNullString())))
                .andExpect(jsonPath("$.projectName").value("spec-kit-poc"));
    }

    @Test
    void shouldRunSpecifyPlanTasksAndReadArtifacts() throws Exception {
        when(aiClient.generateReply(anyString(), anyString(), anyString()))
                .thenReturn("mock assistant reply");
        String createBody = "{\"projectName\":\"spec-kit-poc\",\"objective\":\"build mvp\"}";

        MvcResult createResult = mockMvc.perform(post("/api/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode createJson = objectMapper.readTree(createResult.getResponse().getContentAsString());
        String sessionId = createJson.get("sessionId").asText();

        mockMvc.perform(post("/api/sessions/{id}/specify", sessionId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"input\":\"用户需要可视化 spec 流程\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SPECIFIED"));

        mockMvc.perform(post("/api/sessions/{id}/plan", sessionId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"input\":\"拆解技术方案和接口\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PLANNED"));

        mockMvc.perform(post("/api/sessions/{id}/tasks", sessionId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"input\":\"输出依赖顺序任务\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("TASKS_GENERATED"));

        mockMvc.perform(get("/api/sessions/{id}/artifacts", sessionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.specMd", not(emptyOrNullString())))
                .andExpect(jsonPath("$.planMd", not(emptyOrNullString())))
                .andExpect(jsonPath("$.tasksMd", not(emptyOrNullString())))
                .andExpect(jsonPath("$.timeline.length()").value(greaterThanOrEqualTo(4)));
    }

    @Test
    void shouldAutoOrchestrateStagesViaChatApi() throws Exception {
        when(aiClient.generateReply(anyString(), anyString(), anyString()))
                .thenReturn("mock assistant reply");
        String createBody = "{\"projectName\":\"chat-poc\",\"objective\":\"chat first workflow\"}";

        MvcResult createResult = mockMvc.perform(post("/api/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode createJson = objectMapper.readTree(createResult.getResponse().getContentAsString());
        String sessionId = createJson.get("sessionId").asText();

        mockMvc.perform(post("/api/sessions/{id}/chat", sessionId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"我要做一个报销审批平台\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SPECIFIED"))
                .andExpect(jsonPath("$.assistantMessage", not(emptyOrNullString())));

        mockMvc.perform(post("/api/sessions/{id}/chat", sessionId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"优先考虑内网部署和可观测性\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PLANNED"));

        mockMvc.perform(post("/api/sessions/{id}/chat", sessionId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"请继续细化交付任务和验收标准\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("TASKS_GENERATED"));

        mockMvc.perform(get("/api/sessions/{id}/artifacts", sessionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.specMd", not(emptyOrNullString())))
                .andExpect(jsonPath("$.planMd", not(emptyOrNullString())))
                .andExpect(jsonPath("$.tasksMd", not(emptyOrNullString())));

        mockMvc.perform(get("/api/sessions/{id}", sessionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId").value(sessionId))
                .andExpect(jsonPath("$.status").value("TASKS_GENERATED"));

        mockMvc.perform(get("/api/sessions/{id}/workspace-tree", sessionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.entries").isArray());

        mockMvc.perform(get("/api/sessions/{id}/milestone", sessionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.text", not(emptyOrNullString())));
    }

    @Test
    void shouldFallbackWhenAiClientFails() throws Exception {
        reset(aiClient);
        doThrow(new RuntimeException("ai timeout")).when(aiClient)
                .generateReply(anyString(), anyString(), anyString());

        MvcResult createResult = mockMvc.perform(post("/api/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"projectName\":\"fallback-poc\",\"objective\":\"verify fallback\"}"))
                .andExpect(status().isOk())
                .andReturn();

        String sessionId = objectMapper.readTree(createResult.getResponse().getContentAsString()).get("sessionId").asText();

        mockMvc.perform(post("/api/sessions/{id}/chat", sessionId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"请生成方案\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.assistantMessage", not(emptyOrNullString())))
                .andExpect(jsonPath("$.assistantMessage").value(org.hamcrest.Matchers.containsString("AI 回复生成暂时失败")));
    }

        @Test
        void shouldExecuteControlledAction() throws Exception {
                MvcResult createResult = mockMvc.perform(post("/api/sessions")
                                                .contentType(MediaType.APPLICATION_JSON)
                                                .content("{\"projectName\":\"exec-poc\",\"objective\":\"verify controlled action\"}"))
                                .andExpect(status().isOk())
                                .andReturn();

                String sessionId = objectMapper.readTree(createResult.getResponse().getContentAsString()).get("sessionId").asText();

                mockMvc.perform(post("/api/sessions/{id}/execute", sessionId)
                                                .contentType(MediaType.APPLICATION_JSON)
                                                .content("{\"action\":\"git_version\"}"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.sessionId").value(sessionId))
                                .andExpect(jsonPath("$.action").value("git_version"))
                                .andExpect(jsonPath("$.stdout", not(emptyOrNullString())));

                        mockMvc.perform(post("/api/sessions/{id}/execute", sessionId)
                                        .contentType(MediaType.APPLICATION_JSON)
                                        .content("{\"action\":\"git_push_origin\",\"approved\":false}"))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.message", org.hamcrest.Matchers.containsString("requires approval")));

                        mockMvc.perform(post("/api/sessions/{id}/execute", sessionId)
                                        .contentType(MediaType.APPLICATION_JSON)
                                        .content("{\"action\":\"git_push_origin\",\"approved\":true}"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.action").value("git_push_origin"));
        }
}
