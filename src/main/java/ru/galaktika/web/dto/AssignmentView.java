package ru.galaktika.web.dto;

import ru.galaktika.domain.AttestationLevel;

public record AssignmentView(
        String id,
        String testCode,
        String testTitle,
        AttestationLevel level,
        String listenerUsername,
        String timezoneWarning) {
}
