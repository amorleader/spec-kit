package com.amor.speckit.mvp.mhr.controller;

import com.amor.speckit.mvp.mhr.dto.BuildGenerateRequest;
import com.amor.speckit.mvp.mhr.dto.BuildGenerateResponse;
import com.amor.speckit.mvp.mhr.dto.BuildResultResponse;
import com.amor.speckit.mvp.mhr.exception.NotFoundException;
import com.amor.speckit.mvp.mhr.service.BuildGenerationService;
import com.amor.speckit.mvp.mhr.service.BuildResultStore;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

@RestController
@Validated
@RequestMapping("/api/v1/builds")
public class BuildController {
    private final BuildGenerationService buildGenerationService;
    private final BuildResultStore buildResultStore;

    public BuildController(BuildGenerationService buildGenerationService,
                           BuildResultStore buildResultStore) {
        this.buildGenerationService = buildGenerationService;
        this.buildResultStore = buildResultStore;
    }

    @PostMapping("/generate")
    public BuildGenerateResponse generate(@Valid @RequestBody BuildGenerateRequest request) {
        return buildGenerationService.generate(request);
    }

    @GetMapping("/{id}")
    public BuildResultResponse getById(@PathVariable String id) {
        return buildResultStore.findById(id)
                .orElseThrow(() -> new NotFoundException("Build result not found: " + id));
    }
}
