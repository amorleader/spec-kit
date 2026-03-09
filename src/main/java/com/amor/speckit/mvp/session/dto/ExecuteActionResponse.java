package com.amor.speckit.mvp.session.dto;

public class ExecuteActionResponse {
    private final String sessionId;
    private final String action;
    private final int exitCode;
    private final String stdout;
    private final String stderr;

    public ExecuteActionResponse(String sessionId, String action, int exitCode, String stdout, String stderr) {
        this.sessionId = sessionId;
        this.action = action;
        this.exitCode = exitCode;
        this.stdout = stdout;
        this.stderr = stderr;
    }

    public String getSessionId() {
        return sessionId;
    }

    public String getAction() {
        return action;
    }

    public int getExitCode() {
        return exitCode;
    }

    public String getStdout() {
        return stdout;
    }

    public String getStderr() {
        return stderr;
    }
}
