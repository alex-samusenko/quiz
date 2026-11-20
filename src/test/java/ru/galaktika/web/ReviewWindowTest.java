package ru.galaktika.web;

import org.junit.jupiter.api.Test;

import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;

class ReviewWindowTest {

    @Test
    void expiresAfterTwoCalendarDaysNotCountingAttemptDay() {
        var finishedAt = Instant.parse("2026-11-19T20:45:00Z"); // 23:45 МСК

        assertThat(ReviewWindow.until(finishedAt))
                .isEqualTo(Instant.parse("2026-11-21T21:00:00Z")); // 22.11 00:00 МСК
    }
}
