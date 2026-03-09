package com.amor.speckit.mvp.session.dto;

import java.util.List;

public class SessionArtifactsResponse {
    private final String specMd;
    private final String planMd;
    private final String tasksMd;
    private final List<TimelineEntryResponse> timeline;

    public SessionArtifactsResponse(String specMd,
                                    String planMd,
                                    String tasksMd,
                                    List<TimelineEntryResponse> timeline) {
        this.specMd = specMd;
        this.planMd = planMd;
        this.tasksMd = tasksMd;
        this.timeline = timeline;
    }

    public String getSpecMd() {
        return specMd;
    }

    public String getPlanMd() {
        return planMd;
    }

    public String getTasksMd() {
        return tasksMd;
    }

    public List<TimelineEntryResponse> getTimeline() {
        return timeline;
    }
}
