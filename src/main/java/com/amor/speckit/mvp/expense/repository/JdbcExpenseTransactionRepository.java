package com.amor.speckit.mvp.expense.repository;

import com.amor.speckit.mvp.expense.domain.ExpenseCategory;
import com.amor.speckit.mvp.expense.domain.ExpenseTransaction;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
@ConditionalOnProperty(name = "app.expense.repository-mode", havingValue = "db")
public class JdbcExpenseTransactionRepository implements ExpenseTransactionPort {
    private final JdbcTemplate jdbcTemplate;

    public JdbcExpenseTransactionRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ExpenseTransaction save(ExpenseTransaction transaction) {
        long nextId = jdbcTemplate.queryForObject("SELECT COALESCE(MAX(id), 0) + 1 FROM expense_transactions", Long.class);
        jdbcTemplate.update(
                "INSERT INTO expense_transactions (id, amount, category_code, occurred_at, note) VALUES (?, ?, ?, ?, ?)",
                nextId,
                transaction.getAmount(),
                transaction.getCategory().name(),
                Date.valueOf(transaction.getOccurredAt()),
                transaction.getNote()
        );
        return new ExpenseTransaction(nextId, transaction.getAmount(), transaction.getCategory(), transaction.getOccurredAt(), transaction.getNote());
    }

    @Override
    public List<ExpenseTransaction> findAll(LocalDate fromDate, LocalDate toDate) {
        String sql = "SELECT id, amount, category_code, occurred_at, note FROM expense_transactions WHERE 1=1";
        List<Object> args = new ArrayList<>();

        if (fromDate != null) {
            sql += " AND occurred_at >= ?";
            args.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql += " AND occurred_at <= ?";
            args.add(Date.valueOf(toDate));
        }

        sql += " ORDER BY id ASC";

        return jdbcTemplate.query(sql, args.toArray(), (rs, rowNum) -> new ExpenseTransaction(
                rs.getLong("id"),
                rs.getBigDecimal("amount"),
                ExpenseCategory.valueOf(rs.getString("category_code")),
                rs.getDate("occurred_at").toLocalDate(),
                rs.getString("note")
        ));
    }
}
