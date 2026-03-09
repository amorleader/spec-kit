package com.amor.speckit.mvp.session.service;

public class SessionPathIsolationException extends RuntimeException {
    public SessionPathIsolationException(String message) {
        super(message);
    }

    public SessionPathIsolationException(String message, Throwable cause) {
        super(message, cause);
    }
}
