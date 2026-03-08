package com.amor.speckit.mvp.expense.repository;

import com.amor.speckit.mvp.expense.domain.ExpenseTransaction;

import java.time.LocalDate;
import java.util.List;

public interface ExpenseTransactionPort {
    ExpenseTransaction save(ExpenseTransaction transaction);

    List<ExpenseTransaction> findAll(LocalDate fromDate, LocalDate toDate);
}
