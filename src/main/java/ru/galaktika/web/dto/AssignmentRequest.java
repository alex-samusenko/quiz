package ru.galaktika.web.dto;

import java.time.Instant;
import java.util.List;
import ru.galaktika.domain.AttestationLevel;

public record AssignmentRequest(
        String username,
        List<String> usernames,
        String testCode,
        AttestationLevel level,
        Instant startsAt,
        Instant endsAt,
        Instant accessFrom,
        Instant accessUntil) {

    public List<String> listeners() {
        if (usernames != null && !usernames.isEmpty()) {
            return usernames;
        }
        return username == null ? List.of() : List.of(username);
    }
}
