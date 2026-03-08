package com.amor.speckit.mvp.expense.controller;

import com.amor.speckit.mvp.expense.dto.CategoryResponse;
import com.amor.speckit.mvp.expense.dto.CategorySummaryResponse;
import com.amor.speckit.mvp.expense.dto.CreateExpenseTransactionRequest;
import com.amor.speckit.mvp.expense.dto.ExpenseTransactionResponse;
import com.amor.speckit.mvp.expense.service.ExpenseService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.time.LocalDate;
import java.util.List;

@RestController
@Validated
@RequestMapping("/api/v1")
public class ExpenseController {
    private final ExpenseService expenseService;

    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @GetMapping("/categories")
    public List<CategoryResponse> categories() {
        return expenseService.categories();
    }

    @PostMapping("/transactions")
    public ExpenseTransactionResponse create(@Valid @RequestBody CreateExpenseTransactionRequest request) {
        return expenseService.create(request);
    }

    @GetMapping("/transactions")
    public List<ExpenseTransactionResponse> list(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate) {
        return expenseService.list(fromDate, toDate);
    }

    @GetMapping("/summaries/by-category")
    public CategorySummaryResponse summary(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate) {
        return expenseService.summaryByCategory(fromDate, toDate);
    }
}
