package com.amor.speckit.mvp.expense.dto;

import com.amor.speckit.mvp.expense.domain.ExpenseCategory;

import java.math.BigDecimal;
import java.time.LocalDate;

public class ExpenseTransactionResponse {
    private long id;
    private BigDecimal amount;
    private ExpenseCategory category;
    private LocalDate occurredAt;
    private String note;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

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
