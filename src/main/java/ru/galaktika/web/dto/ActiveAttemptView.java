package ru.galaktika.web.dto;

public record ActiveAttemptView(
        String id,
        String listenerName,
        String testTitle,
        boolean paused,
        int remainingSeconds) {
}
