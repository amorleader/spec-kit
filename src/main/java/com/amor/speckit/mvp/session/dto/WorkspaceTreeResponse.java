package com.amor.speckit.mvp.session.dto;

import java.util.List;

public class WorkspaceTreeResponse {
    private final List<WorkspaceEntryResponse> entries;

    public WorkspaceTreeResponse(List<WorkspaceEntryResponse> entries) {
        this.entries = entries;
    }

    public List<WorkspaceEntryResponse> getEntries() {
        return entries;
    }
}
