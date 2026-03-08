package com.amor.speckit.mvp.expense.domain;

public enum ExpenseCategory {
    FOOD("Food"),
    TRANSPORT("Transport"),
    UTILITIES("Utilities"),
    ENTERTAINMENT("Entertainment"),
    OTHER("Other");

    private final String label;

    ExpenseCategory(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
