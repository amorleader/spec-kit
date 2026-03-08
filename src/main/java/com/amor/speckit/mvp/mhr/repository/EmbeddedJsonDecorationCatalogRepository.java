package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Decoration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@ConditionalOnProperty(name = "app.mhr.catalog.repository-mode", havingValue = "embedded-json")
public class EmbeddedJsonDecorationCatalogRepository implements DecorationCatalogPort {
    private final List<Decoration> decorations;

    public EmbeddedJsonDecorationCatalogRepository(EmbeddedMhrCatalogStore store) {
        this.decorations = store.getDecorations();
    }

    @Override
    public List<Decoration> findAll() {
        return decorations;
    }
}
