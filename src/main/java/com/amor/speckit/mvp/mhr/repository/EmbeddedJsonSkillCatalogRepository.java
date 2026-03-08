package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Skill;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "embedded-json")
public class EmbeddedJsonSkillCatalogRepository implements SkillCatalogPort {
    private final List<Skill> skills;
    private final Map<String, Skill> byCode;

    public EmbeddedJsonSkillCatalogRepository(EmbeddedMhrCatalogStore store) {
        this.skills = store.getSkills();
        this.byCode = new LinkedHashMap<>();
        for (Skill skill : skills) {
            byCode.put(skill.getCode(), skill);
        }
    }

    @Override
    public List<Skill> findAll() {
        return skills;
    }

    @Override
    public Optional<Skill> findByCode(String code) {
        return Optional.ofNullable(byCode.get(code));
    }
}
