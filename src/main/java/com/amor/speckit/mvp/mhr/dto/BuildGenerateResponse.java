package com.amor.speckit.mvp.mhr.dto;

import java.util.List;

public class BuildGenerateResponse {
    private List<BuildResultResponse> results;

    public BuildGenerateResponse() {
    }

    public BuildGenerateResponse(List<BuildResultResponse> results) {
        this.results = results;
    }

    public List<BuildResultResponse> getResults() {
        return results;
    }

    public void setResults(List<BuildResultResponse> results) {
        this.results = results;
    }
}
