package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Skill;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
public class SkillCatalogRepository {
    private final List<Skill> skills = List.of(
            new Skill(1L, "ATTACK_BOOST", "Attack Boost", 7),
            new Skill(2L, "WEAKNESS_EXPLOIT", "Weakness Exploit", 3),
            new Skill(3L, "CRITICAL_EYE", "Critical Eye", 7)
    );

    private final Map<String, Skill> byCode = skills.stream()
            .collect(Collectors.toUnmodifiableMap(Skill::getCode, s -> s));

    public List<Skill> findAll() {
        return skills;
    }

    public Optional<Skill> findByCode(String code) {
        return Optional.ofNullable(byCode.get(code));
    }
}
