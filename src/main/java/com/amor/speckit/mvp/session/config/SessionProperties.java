package com.amor.speckit.mvp.session.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.spec-kit.session")
public class SessionProperties {
    private String workspaceRoot = "/srv/spec-kit/workspaces";

    public String getWorkspaceRoot() {
        return workspaceRoot;
    }

    public void setWorkspaceRoot(String workspaceRoot) {
        this.workspaceRoot = workspaceRoot;
    }
}
