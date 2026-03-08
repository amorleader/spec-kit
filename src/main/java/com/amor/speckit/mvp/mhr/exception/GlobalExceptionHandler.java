package com.amor.speckit.mvp.mhr.exception;

import com.amor.speckit.mvp.mhr.dto.ApiError;
import com.amor.speckit.mvp.mhr.dto.ErrorDetail;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.ArrayList;
import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ApiError> handleValidation(ValidationException ex) {
        ApiError body = new ApiError("VALIDATION_ERROR", ex.getMessage(), ex.getDetails());
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleBeanValidation(MethodArgumentNotValidException ex) {
        List<ErrorDetail> details = new ArrayList<>();
        String message = "Request validation failed";
        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            String reason = "invalid";
            if ("maxResults".equals(fieldError.getField())) {
                reason = "out_of_range";
                message = "maxResults must be between 1 and 20";
            } else if ("amount".equals(fieldError.getField())) {
                reason = "out_of_range";
                message = "amount must be greater than 0";
            }
            details.add(new ErrorDetail(fieldError.getField(), reason));
        }
        ApiError body = new ApiError("VALIDATION_ERROR", message, details);
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ApiError> handleNotFound(NotFoundException ex) {
        ApiError body = new ApiError("NOT_FOUND", ex.getMessage(), List.of());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(body);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleUnknown(Exception ex) {
        ApiError body = new ApiError("INTERNAL_ERROR", "Unexpected server error", List.of());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
