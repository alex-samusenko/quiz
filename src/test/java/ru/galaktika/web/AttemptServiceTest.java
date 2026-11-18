package ru.galaktika.web;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import ru.galaktika.auth.CurrentUser;
import ru.galaktika.auth.CurrentUserService;
import ru.galaktika.auth.UserRole;
import ru.galaktika.config.TestConfig;
import ru.galaktika.dao.TestCatalog;
import ru.galaktika.db.AssignmentRepository;
import ru.galaktika.db.AttemptRepository;
import ru.galaktika.domain.Answer;
import ru.galaktika.domain.ChoiceType;
import ru.galaktika.domain.Difficulty;
import ru.galaktika.domain.Question;
import ru.galaktika.domain.Student;
import ru.galaktika.service.AnswerKeys;

import java.time.Clock;
import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AttemptServiceTest {

    @Mock private TestCatalog catalog;
    @Mock private TestConfig testConfig;
    @Mock private AnswerKeys answerKeys;
    @Mock private AssignmentRepository assignments;
    @Mock private AttemptRepository attemptRepository;
    @Mock private ActiveAttempts activeAttempts;
    @Mock private CurrentUserService currentUser;
    @Mock private Clock clock;

    @InjectMocks private AttemptService service;

    @Test
    void rejectsAnswersAfterServerDeadline() {
        var now = Instant.parse("2026-11-17T12:10:01Z");
        var question = new Question("Q", List.of(new Answer("A", true)),
                Difficulty.EASY, ChoiceType.SINGLE);
        var meta = new AttemptMeta(7L, "assignment", "test", "Test",
                Instant.parse("2026-11-17T12:00:00Z"));
        var attempt = new Attempt("attempt", new Student("Ivan", "Petrov"), List.of(question), meta);
        var listener = new CurrentUser(7L, "user", "Ivan", "Petrov", UserRole.USER);

        when(clock.instant()).thenReturn(now);
        when(testConfig.getTimeLimitSeconds()).thenReturn(600);
        when(currentUser.require(UserRole.USER)).thenReturn(listener);
        when(activeAttempts.find("attempt")).thenReturn(attempt);

        assertThatThrownBy(() -> service.saveAnswer("attempt", 0, List.of(1)))
                .isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.CONFLICT))
                .hasMessageContaining("Время аттестации истекло");
        assertThat(attempt.getSelected().get(0)).isEmpty();
    }
}
