package ru.galaktika.web.dto;

import java.time.Instant;

public record AttemptReportView(
        String id,
        String testTitle,
        Instant finishedAt,
        Instant reviewUntil,
        boolean reviewDataAvailable,
        String appealStatus,
        int scorePercent,
        boolean passed,
        String listenerName) {
}
