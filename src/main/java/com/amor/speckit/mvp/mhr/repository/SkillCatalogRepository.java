package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Skill;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "in-memory", matchIfMissing = true)
public class SkillCatalogRepository implements SkillCatalogPort {
    private final List<Skill> skills = List.of(
            new Skill(1L, "ATTACK_BOOST", "Attack Boost", "攻击强化", 7),
            new Skill(2L, "WEAKNESS_EXPLOIT", "Weakness Exploit", "弱点特效", 3),
            new Skill(3L, "CRITICAL_EYE", "Critical Eye", "看破", 7)
    );

    private final Map<String, Skill> byCode = skills.stream()
            .collect(Collectors.toUnmodifiableMap(Skill::getCode, s -> s));

    @Override
    public List<Skill> findAll() {
        return skills;
    }

    @Override
    public Optional<Skill> findByCode(String code) {
        return Optional.ofNullable(byCode.get(code));
    }
}
