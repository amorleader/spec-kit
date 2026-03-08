package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Decoration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "db")
public class JdbcDecorationCatalogRepository implements DecorationCatalogPort {
    private final JdbcTemplate jdbcTemplate;

    public JdbcDecorationCatalogRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Decoration> findAll() {
        return jdbcTemplate.query(
                "SELECT id, name, name_zh, slot_level, skill_code, skill_name_zh, skill_level, price, materials " +
                        "FROM mhr_decorations ORDER BY slot_level ASC, id ASC",
                (rs, rowNum) -> new Decoration(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                        rs.getInt("slot_level"),
                        rs.getString("skill_code"),
                        rs.getString("skill_name_zh"),
                        rs.getInt("skill_level"),
                        rs.getInt("price"),
                        rs.getString("materials")
                )
        );
    }
}
