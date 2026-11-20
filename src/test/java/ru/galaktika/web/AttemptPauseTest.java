package ru.galaktika.web;

import org.junit.jupiter.api.Test;
import ru.galaktika.domain.Student;

import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class AttemptPauseTest {

    @Test
    void pausedTimeDoesNotConsumeAttemptLimit() {
        var started = Instant.parse("2026-11-19T10:00:00Z");
        var meta = new AttemptMeta(1L, "assignment", "test", "Test", started);
        var attempt = new Attempt("attempt", new Student("Ivan", "Petrov"), List.of(), meta);

        attempt.pause(started.plusSeconds(60));
        assertThat(attempt.elapsedSeconds(started.plusSeconds(360))).isEqualTo(60);

        attempt.resume(started.plusSeconds(360));
        assertThat(attempt.getPausedSeconds()).isEqualTo(300);
        assertThat(attempt.elapsedSeconds(started.plusSeconds(420))).isEqualTo(120);
    }
}
