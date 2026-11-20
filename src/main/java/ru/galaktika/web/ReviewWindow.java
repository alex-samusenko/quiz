package ru.galaktika.web;

import java.time.Instant;
import java.time.ZoneId;

public final class ReviewWindow {

    private static final ZoneId MOSCOW = ZoneId.of("Europe/Moscow");

    private ReviewWindow() {
    }

    public static Instant until(Instant finishedAt) {
        return finishedAt.atZone(MOSCOW).toLocalDate().plusDays(3).atStartOfDay(MOSCOW).toInstant();
    }
}
