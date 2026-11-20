package ru.galaktika.db;

import ru.galaktika.domain.AttestationLevel;

public record AssignmentRow(
        String id,
        long listenerId,
        String testCode,
        AttestationLevel level,
        long startsAt,
        long endsAt,
        long accessFrom,
        long accessUntil,
        Long cancelledAt) {
}
