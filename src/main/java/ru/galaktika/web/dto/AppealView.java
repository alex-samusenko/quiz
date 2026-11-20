package ru.galaktika.web.dto;

import java.time.Instant;

public record AppealView(
        String id, String attemptId, String listenerName, String testTitle,
        String questionReference, String exampleDescription, String interpretation,
        String legalReference, String attachmentName, String attachmentType,
        String attachmentBase64, String status, Instant createdAt, Instant resolvedAt,
        String resolution, int originalScore, Integer changedScore) {
}
