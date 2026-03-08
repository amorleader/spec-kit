package com.amor.speckit.mvp.expense.controller;

import com.amor.speckit.mvp.mhr.MhrBuildPlannerApplication;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(classes = MhrBuildPlannerApplication.class)
@AutoConfigureMockMvc
class ExpenseControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldReturnValidationErrorWhenAmountIsOutOfRange() throws Exception {
        String body = "{\"amount\":0,\"category\":\"FOOD\",\"occurredAt\":\"2026-03-08\",\"note\":\"bad\"}";

        mockMvc.perform(post("/api/v1/transactions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.message").value("amount must be greater than 0"))
                .andExpect(jsonPath("$.details[0].field").value("amount"))
                .andExpect(jsonPath("$.details[0].reason").value("out_of_range"));
    }

    @Test
    void shouldCreateListAndSummarizeTransactions() throws Exception {
        String body = "{\"amount\":48.50,\"category\":\"FOOD\",\"occurredAt\":\"2026-03-08\",\"note\":\"Dinner\"}";

        mockMvc.perform(post("/api/v1/transactions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(Matchers.greaterThan(0)))
                .andExpect(jsonPath("$.category").value("FOOD"));

        mockMvc.perform(get("/api/v1/transactions")
                        .param("fromDate", "2026-03-01")
                        .param("toDate", "2026-03-31"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].category").value("FOOD"));

        mockMvc.perform(get("/api/v1/summaries/by-category")
                        .param("fromDate", "2026-03-01")
                        .param("toDate", "2026-03-31"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.categoryTotals.FOOD").value(48.50))
                .andExpect(jsonPath("$.transactionCount").value(Matchers.greaterThan(0)));
    }
}
