package com.amor.speckit.mvp.session.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import com.amor.speckit.mvp.mhr.MhrBuildPlannerApplication;

import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.emptyOrNullString;
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

    @Test
    void shouldCreateSession() throws Exception {
        String body = "{\"projectName\":\"spec-kit-poc\",\"objective\":\"build mvp\"}";

        mockMvc.perform(post("/api/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId", not(emptyOrNullString())))
                .andExpect(jsonPath("$.status").value("CREATED"))
                .andExpect(jsonPath("$.workspacePath").value(org.hamcrest.Matchers.startsWith("***/")));
    }

    @Test
    void shouldRunSpecifyPlanTasksAndReadArtifacts() throws Exception {
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
}
