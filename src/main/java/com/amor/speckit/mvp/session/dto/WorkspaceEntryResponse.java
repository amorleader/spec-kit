package com.amor.speckit.mvp.session.dto;

public class WorkspaceEntryResponse {
    private final String path;
    private final boolean directory;
    private final int depth;

    public WorkspaceEntryResponse(String path, boolean directory, int depth) {
        this.path = path;
        this.directory = directory;
        this.depth = depth;
    }

    public String getPath() {
        return path;
    }

    public boolean isDirectory() {
        return directory;
    }

    public int getDepth() {
        return depth;
    }
}
