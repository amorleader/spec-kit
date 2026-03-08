package com.amor.speckit.mvp.expense.dto;

import java.math.BigDecimal;
import java.util.Map;

public class CategorySummaryResponse {
    private Map<String, BigDecimal> categoryTotals;
    private BigDecimal totalAmount;
    private long transactionCount;

    public Map<String, BigDecimal> getCategoryTotals() {
        return categoryTotals;
    }

    public void setCategoryTotals(Map<String, BigDecimal> categoryTotals) {
        this.categoryTotals = categoryTotals;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public long getTransactionCount() {
        return transactionCount;
    }

    public void setTransactionCount(long transactionCount) {
        this.transactionCount = transactionCount;
    }
}
