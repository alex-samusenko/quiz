package ru.galaktika.web.dto;

import java.time.Instant;
import ru.galaktika.domain.AttestationLevel;

public record AssignmentReportView(
        String id,
        String listenerName,
        String testTitle,
        AttestationLevel level,
        Instant assignedAt,
        Instant accessFrom,
        Instant accessUntil,
        String status) {
}
