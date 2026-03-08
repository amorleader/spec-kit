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
            "SELECT t.id, t.code, t.name, t.name_zh, t.max_level, COALESCE(se.effect, '') AS effect FROM (" +
                "SELECT DISTINCT ON (LOWER(TRIM(name_zh))) id, code, name, name_zh, max_level " +
                "FROM mhr_skills " +
                "ORDER BY LOWER(TRIM(name_zh)), max_level DESC, id ASC" +
                ") t LEFT JOIN mhr_skill_effects se ON se.skill_code = t.code ORDER BY t.id ASC",
                (rs, rowNum) -> new Skill(
                        rs.getLong("id"),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                rs.getInt("max_level"),
                rs.getString("effect")
                )
        );
    }

    @Override
    public Optional<Skill> findByCode(String code) {
        List<Skill> skills = jdbcTemplate.query(
            "SELECT s.id, s.code, s.name, s.name_zh, s.max_level, COALESCE(se.effect, '') AS effect " +
                "FROM mhr_skills s LEFT JOIN mhr_skill_effects se ON se.skill_code = s.code WHERE s.code = ?",
                (rs, rowNum) -> new Skill(
                        rs.getLong("id"),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("name_zh"),
                rs.getInt("max_level"),
                rs.getString("effect")
                ),
                code
        );
        return skills.stream().findFirst();
    }
}
