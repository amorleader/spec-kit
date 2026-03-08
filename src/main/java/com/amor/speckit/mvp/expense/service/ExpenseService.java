package com.amor.speckit.mvp.expense.service;

import com.amor.speckit.mvp.expense.domain.ExpenseCategory;
import com.amor.speckit.mvp.expense.domain.ExpenseTransaction;
import com.amor.speckit.mvp.expense.dto.CategoryResponse;
import com.amor.speckit.mvp.expense.dto.CategorySummaryResponse;
import com.amor.speckit.mvp.expense.dto.CreateExpenseTransactionRequest;
import com.amor.speckit.mvp.expense.dto.ExpenseTransactionResponse;
import com.amor.speckit.mvp.expense.repository.ExpenseTransactionPort;
import com.amor.speckit.mvp.mhr.dto.ErrorDetail;
import com.amor.speckit.mvp.mhr.exception.ValidationException;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ExpenseService {
    private final ExpenseTransactionPort expenseTransactionRepository;

    public ExpenseService(ExpenseTransactionPort expenseTransactionRepository) {
        this.expenseTransactionRepository = expenseTransactionRepository;
    }

    public List<CategoryResponse> categories() {
        return List.of(ExpenseCategory.values()).stream()
                .map(c -> new CategoryResponse(c.name(), c.getLabel()))
                .collect(Collectors.toList());
    }

    public ExpenseTransactionResponse create(CreateExpenseTransactionRequest request) {
        ExpenseTransaction entity = new ExpenseTransaction(0L, request.getAmount(), request.getCategory(), request.getOccurredAt(), request.getNote());
        ExpenseTransaction saved = expenseTransactionRepository.save(entity);
        return toResponse(saved);
    }

    public List<ExpenseTransactionResponse> list(LocalDate fromDate, LocalDate toDate) {
        validateDateRange(fromDate, toDate);
        return expenseTransactionRepository.findAll(fromDate, toDate).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public CategorySummaryResponse summaryByCategory(LocalDate fromDate, LocalDate toDate) {
        validateDateRange(fromDate, toDate);
        List<ExpenseTransaction> filtered = expenseTransactionRepository.findAll(fromDate, toDate);

        Map<String, BigDecimal> totals = new HashMap<>();
        for (ExpenseCategory category : ExpenseCategory.values()) {
            totals.put(category.name(), BigDecimal.ZERO);
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        for (ExpenseTransaction transaction : filtered) {
            totals.merge(transaction.getCategory().name(), transaction.getAmount(), BigDecimal::add);
            totalAmount = totalAmount.add(transaction.getAmount());
        }

        CategorySummaryResponse response = new CategorySummaryResponse();
        response.setCategoryTotals(totals);
        response.setTotalAmount(totalAmount);
        response.setTransactionCount(filtered.size());
        return response;
    }

    private void validateDateRange(LocalDate fromDate, LocalDate toDate) {
        if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
            throw new ValidationException(
                    "fromDate must be before or equal to toDate",
                    List.of(new ErrorDetail("fromDate", "invalid_range"))
            );
        }
    }

    private ExpenseTransactionResponse toResponse(ExpenseTransaction transaction) {
        ExpenseTransactionResponse response = new ExpenseTransactionResponse();
        response.setId(transaction.getId());
        response.setAmount(transaction.getAmount());
        response.setCategory(transaction.getCategory());
        response.setOccurredAt(transaction.getOccurredAt());
        response.setNote(transaction.getNote());
        return response;
    }
}
