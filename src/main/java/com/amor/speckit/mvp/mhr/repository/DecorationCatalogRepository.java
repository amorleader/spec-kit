package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Decoration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "in-memory", matchIfMissing = true)
public class DecorationCatalogRepository implements DecorationCatalogPort {
    private final List<Decoration> decorations = List.of(
            new Decoration(1L, "Attack Jewel 2", "攻击珠【2】", 2, "ATTACK_BOOST", "攻击强化", 1, 1500, "修罗原珠x5 ..."),
            new Decoration(2L, "Tenderizer Jewel 2", "痛击珠【2】", 2, "WEAKNESS_EXPLOIT", "弱点特效", 1, 1500, "琉璃原珠x5 ..."),
            new Decoration(3L, "Expert Jewel 2", "达人珠【2】", 2, "CRITICAL_EYE", "看破", 1, 1500, "修罗原珠x4 ..."),
            new Decoration(4L, "Attack Jewel+ 4", "攻击珠II【4】", 4, "ATTACK_BOOST", "攻击强化", 2, 4000, "怪异素材 ...")
    );

    @Override
    public List<Decoration> findAll() {
        return decorations;
    }
}
