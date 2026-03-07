package com.amor.speckit.mvp.mhr.service;

import com.amor.speckit.mvp.mhr.dto.BuildResultResponse;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class BuildResultStore {
    private final Map<String, BuildResultResponse> store = new ConcurrentHashMap<>();

    public void put(BuildResultResponse result) {
        store.put(result.getId(), result);
    }

    public Optional<BuildResultResponse> findById(String id) {
        return Optional.ofNullable(store.get(id));
    }
}
