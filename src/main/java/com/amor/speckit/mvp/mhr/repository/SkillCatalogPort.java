package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Skill;

import java.util.List;
import java.util.Optional;

public interface SkillCatalogPort {
    List<Skill> findAll();

    Optional<Skill> findByCode(String code);
}
