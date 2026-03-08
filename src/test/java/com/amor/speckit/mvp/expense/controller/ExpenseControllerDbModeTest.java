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

@SpringBootTest(
        classes = MhrBuildPlannerApplication.class,
        properties = {
                "app.expense.repository-mode=db",
                "spring.datasource.url=jdbc:h2:mem:expense_db;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
                "spring.datasource.driver-class-name=org.h2.Driver",
                "spring.datasource.username=sa",
                "spring.datasource.password="
        }
)
@AutoConfigureMockMvc
class ExpenseControllerDbModeTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldKeepContractStableInDbMode() throws Exception {
        String createBody = "{\"amount\":12.30,\"category\":\"FOOD\",\"occurredAt\":\"2026-03-08\",\"note\":\"db\"}";

        mockMvc.perform(post("/api/v1/transactions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(Matchers.greaterThan(0)))
                .andExpect(jsonPath("$.category").value("FOOD"));

        mockMvc.perform(get("/api/v1/summaries/by-category")
                        .param("fromDate", "2026-03-01")
                        .param("toDate", "2026-03-31"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.categoryTotals.FOOD").value(12.30));
    }
}
