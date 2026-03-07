package com.amor.speckit.mvp.mhr.exception;

import com.amor.speckit.mvp.mhr.dto.ErrorDetail;

import java.util.List;

public class ValidationException extends RuntimeException {
    private final List<ErrorDetail> details;

    public ValidationException(String message, List<ErrorDetail> details) {
        super(message);
        this.details = details;
    }

    public List<ErrorDetail> getDetails() {
        return details;
    }
}
