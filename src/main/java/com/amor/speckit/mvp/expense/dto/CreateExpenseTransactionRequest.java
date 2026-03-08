package com.amor.speckit.mvp.expense.dto;

import com.amor.speckit.mvp.expense.domain.ExpenseCategory;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.PastOrPresent;
import java.math.BigDecimal;
import java.time.LocalDate;

public class CreateExpenseTransactionRequest {
    @NotNull
    @DecimalMin(value = "0.01")
    private BigDecimal amount;

    @NotNull
    private ExpenseCategory category;

    @NotNull
    @PastOrPresent
    private LocalDate occurredAt;

    private String note;

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public ExpenseCategory getCategory() {
        return category;
    }

    public void setCategory(ExpenseCategory category) {
        this.category = category;
    }

    public LocalDate getOccurredAt() {
        return occurredAt;
    }

    public void setOccurredAt(LocalDate occurredAt) {
        this.occurredAt = occurredAt;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
