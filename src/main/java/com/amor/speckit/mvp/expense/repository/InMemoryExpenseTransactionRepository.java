package com.amor.speckit.mvp.expense.repository;

import com.amor.speckit.mvp.expense.domain.ExpenseTransaction;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

@Repository
@ConditionalOnProperty(name = "app.expense.repository-mode", havingValue = "in-memory", matchIfMissing = true)
public class InMemoryExpenseTransactionRepository implements ExpenseTransactionPort {
    private final AtomicLong idGenerator = new AtomicLong(1L);
    private final CopyOnWriteArrayList<ExpenseTransaction> store = new CopyOnWriteArrayList<>();

    @Override
    public ExpenseTransaction save(ExpenseTransaction transaction) {
        ExpenseTransaction saved = new ExpenseTransaction(
                idGenerator.getAndIncrement(),
                transaction.getAmount(),
                transaction.getCategory(),
                transaction.getOccurredAt(),
                transaction.getNote()
        );
        store.add(saved);
        return saved;
    }

    @Override
    public List<ExpenseTransaction> findAll(LocalDate fromDate, LocalDate toDate) {
        List<ExpenseTransaction> result = new ArrayList<>();
        for (ExpenseTransaction transaction : store) {
            if (fromDate != null && transaction.getOccurredAt().isBefore(fromDate)) {
                continue;
            }
            if (toDate != null && transaction.getOccurredAt().isAfter(toDate)) {
                continue;
            }
            result.add(transaction);
        }
        return result;
    }
}
