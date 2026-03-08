package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Skill;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "db")
public class JdbcSkillCatalogRepository implements SkillCatalogPort {
    private final JdbcTemplate jdbcTemplate;

    public JdbcSkillCatalogRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Skill> findAll() {
        return jdbcTemplate.query(
                "SELECT id, code, name, name_zh, max_level FROM mhr_skills ORDER BY id ASC",
                (rs, rowNum) -> new Skill(
                        rs.getLong("id"),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                        rs.getInt("max_level")
                )
        );
    }

    @Override
    public Optional<Skill> findByCode(String code) {
        List<Skill> skills = jdbcTemplate.query(
                "SELECT id, code, name, name_zh, max_level FROM mhr_skills WHERE code = ?",
                (rs, rowNum) -> new Skill(
                        rs.getLong("id"),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                        rs.getInt("max_level")
                ),
                code
        );
        return skills.stream().findFirst();
    }
}
