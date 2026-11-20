package ru.galaktika.web.dto;

import java.time.Instant;
import ru.galaktika.domain.AttestationLevel;

public record OpenAssignmentView(
        String id,
        String testCode,
        String testTitle,
        AttestationLevel level,
        String activeAttemptId,
        Instant accessFrom,
        Instant accessUntil,
        boolean available,
        String status) {
}
