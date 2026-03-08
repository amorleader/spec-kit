package com.amor.speckit.mvp.mhr.repository;

import com.amor.speckit.mvp.mhr.domain.Decoration;

import java.util.List;

public interface DecorationCatalogPort {
    List<Decoration> findAll();
}
