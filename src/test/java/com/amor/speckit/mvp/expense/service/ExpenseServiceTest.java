package com.amor.speckit.mvp.expense.service;

import com.amor.speckit.mvp.expense.domain.ExpenseCategory;
import com.amor.speckit.mvp.expense.dto.CategorySummaryResponse;
import com.amor.speckit.mvp.expense.dto.CreateExpenseTransactionRequest;
import com.amor.speckit.mvp.expense.repository.InMemoryExpenseTransactionRepository;
import com.amor.speckit.mvp.mhr.exception.ValidationException;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class ExpenseServiceTest {

    private final ExpenseService expenseService = new ExpenseService(new InMemoryExpenseTransactionRepository());

    @Test
    void shouldAggregateByCategory() {
        expenseService.create(request(new BigDecimal("30.00"), ExpenseCategory.FOOD, LocalDate.of(2026, 3, 8)));
        expenseService.create(request(new BigDecimal("20.00"), ExpenseCategory.FOOD, LocalDate.of(2026, 3, 9)));
        expenseService.create(request(new BigDecimal("50.00"), ExpenseCategory.TRANSPORT, LocalDate.of(2026, 3, 9)));

        CategorySummaryResponse summary = expenseService.summaryByCategory(
                LocalDate.of(2026, 3, 1),
                LocalDate.of(2026, 3, 31)
        );

        assertEquals(new BigDecimal("50.00"), summary.getCategoryTotals().get("TRANSPORT"));
        assertEquals(new BigDecimal("50.00"), summary.getCategoryTotals().get("FOOD"));
        assertEquals(new BigDecimal("100.00"), summary.getTotalAmount());
        assertEquals(3, summary.getTransactionCount());
    }

    @Test
    void shouldRejectInvalidDateRange() {
        assertThrows(ValidationException.class, () -> expenseService.summaryByCategory(
                LocalDate.of(2026, 3, 31),
                LocalDate.of(2026, 3, 1)
        ));
    }

    private CreateExpenseTransactionRequest request(BigDecimal amount, ExpenseCategory category, LocalDate date) {
        CreateExpenseTransactionRequest request = new CreateExpenseTransactionRequest();
        request.setAmount(amount);
        request.setCategory(category);
        request.setOccurredAt(date);
        request.setNote("test");
        return request;
    }
}
