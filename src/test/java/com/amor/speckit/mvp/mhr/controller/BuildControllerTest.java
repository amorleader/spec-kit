package com.amor.speckit.mvp.mhr.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class BuildControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldReturnValidationErrorForOutOfRangeMaxResults() throws Exception {
        String requestBody = "{\"weaponType\":\"LONG_SWORD\",\"targetSkills\":[{\"skillCode\":\"ATTACK_BOOST\",\"minLevel\":4}],\"maxResults\":21}";

        mockMvc.perform(post("/api/v1/builds/generate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.message").value("maxResults must be between 1 and 20"));
    }

    @Test
    void shouldGenerateAtLeastOneBuildForValidRequest() throws Exception {
        String requestBody = "{\"weaponType\":\"LONG_SWORD\",\"targetSkills\":[{\"skillCode\":\"ATTACK_BOOST\",\"minLevel\":4},{\"skillCode\":\"WEAKNESS_EXPLOIT\",\"minLevel\":3}],\"maxResults\":5}";

        mockMvc.perform(post("/api/v1/builds/generate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.results").isArray())
                .andExpect(jsonPath("$.results.length()").value(org.hamcrest.Matchers.greaterThan(0)))
                .andExpect(jsonPath("$.results[0].totalSkills.ATTACK_BOOST").value(org.hamcrest.Matchers.greaterThanOrEqualTo(4)))
                .andExpect(jsonPath("$.results[0].totalSkills.WEAKNESS_EXPLOIT").value(org.hamcrest.Matchers.greaterThanOrEqualTo(3)));
    }
}
