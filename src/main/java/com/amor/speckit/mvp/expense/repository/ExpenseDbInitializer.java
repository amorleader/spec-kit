package com.amor.speckit.mvp.expense.repository;

import com.amor.speckit.mvp.expense.domain.ExpenseCategory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Component
@ConditionalOnProperty(name = "app.expense.repository-mode", havingValue = "db")
public class ExpenseDbInitializer {
    private final JdbcTemplate jdbcTemplate;

    public ExpenseDbInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS expense_categories (code VARCHAR(32) PRIMARY KEY, label VARCHAR(64) NOT NULL)");
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS expense_transactions (id BIGINT PRIMARY KEY, amount NUMERIC(12,2) NOT NULL, category_code VARCHAR(32) NOT NULL, occurred_at DATE NOT NULL, note VARCHAR(255), CONSTRAINT fk_expense_category FOREIGN KEY (category_code) REFERENCES expense_categories (code))");

        for (ExpenseCategory category : ExpenseCategory.values()) {
            Integer exists = jdbcTemplate.queryForObject("SELECT COUNT(1) FROM expense_categories WHERE code = ?", Integer.class, category.name());
            if (exists != null && exists == 0) {
                jdbcTemplate.update("INSERT INTO expense_categories (code, label) VALUES (?, ?)", category.name(), category.getLabel());
            }
        }
    }
}
