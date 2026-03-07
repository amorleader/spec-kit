package com.amor.speckit.mvp.mhr.dto;

import java.util.List;

public class ApiError {
    private String code;
    private String message;
    private List<ErrorDetail> details;

    public ApiError() {
    }

    public ApiError(String code, String message, List<ErrorDetail> details) {
        this.code = code;
        this.message = message;
        this.details = details;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<ErrorDetail> getDetails() {
        return details;
    }

    public void setDetails(List<ErrorDetail> details) {
        this.details = details;
    }
}
