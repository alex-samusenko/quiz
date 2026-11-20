package ru.galaktika.db;

import ru.galaktika.domain.AttestationLevel;

public record AssignmentListRow(
        String id,
        String testCode,
        AttestationLevel level,
        long assignedAt,
        long startsAt,
        long endsAt,
        long accessFrom,
        long accessUntil,
        String listenerName,
        boolean finished,
        boolean active,
        boolean cancelled) {
}
