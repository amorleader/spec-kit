package com.amor.speckit.mvp.expense.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

public class ExpenseTransaction {
    private final long id;
    private final BigDecimal amount;
    private final ExpenseCategory category;
    private final LocalDate occurredAt;
    private final String note;

    public ExpenseTransaction(long id, BigDecimal amount, ExpenseCategory category, LocalDate occurredAt, String note) {
        this.id = id;
        this.amount = amount;
        this.category = category;
        this.occurredAt = occurredAt;
        this.note = note;
    }

    public long getId() {
        return id;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public ExpenseCategory getCategory() {
        return category;
    }

    public LocalDate getOccurredAt() {
        return occurredAt;
    }

    public String getNote() {
        return note;
    }
}
