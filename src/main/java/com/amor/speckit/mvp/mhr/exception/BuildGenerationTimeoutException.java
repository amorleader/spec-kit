package com.amor.speckit.mvp.mhr.exception;

public class BuildGenerationTimeoutException extends RuntimeException {
    private final long timeoutSeconds;
    private final long checkedCombinations;
    private final int matchedCandidates;

    public BuildGenerationTimeoutException(String message,
                                           long timeoutSeconds,
                                           long checkedCombinations,
                                           int matchedCandidates) {
        super(message);
        this.timeoutSeconds = timeoutSeconds;
        this.checkedCombinations = checkedCombinations;
        this.matchedCandidates = matchedCandidates;
    }

    public long getTimeoutSeconds() {
        return timeoutSeconds;
    }

    public long getCheckedCombinations() {
        return checkedCombinations;
    }

    public int getMatchedCandidates() {
        return matchedCandidates;
    }
}