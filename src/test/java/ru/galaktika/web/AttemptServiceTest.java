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
import ru.galaktika.db.AssignmentRow;
import ru.galaktika.db.AttemptRepository;
import ru.galaktika.domain.Answer;
import ru.galaktika.domain.AttestationLevel;
import ru.galaktika.domain.ChoiceType;
import ru.galaktika.domain.Difficulty;
import ru.galaktika.domain.Question;
import ru.galaktika.domain.Student;
import ru.galaktika.service.AnswerKeys;

import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Set;

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
    @Mock private AttemptQuestionSelector questionSelector;
    @Mock private Clock clock;

    @InjectMocks private AttemptService service;

    @Test
    void cannotStartBeforeAccessWindow() {
        var now = Instant.parse("2026-11-19T10:00:00Z");
        var listener = new CurrentUser(7L, "user", "Ivan", "Petrov", UserRole.USER);
        var assignment = new AssignmentRow("assignment", 7L, "test", AttestationLevel.SPECIALIST,
                now.minusSeconds(60).toEpochMilli(), now.plusSeconds(7200).toEpochMilli(),
                now.plusSeconds(60).toEpochMilli(), now.plusSeconds(3600).toEpochMilli(), null);

        when(currentUser.require(UserRole.USER)).thenReturn(listener);
        when(assignments.findById("assignment")).thenReturn(Optional.of(assignment));
        when(clock.instant()).thenReturn(now);

        assertThatThrownBy(() -> service.start("assignment"))
                .isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.CONFLICT))
                .hasMessageContaining("Окно доступности ещё не открыто");
    }

    @Test
    void rejectsAnswersAfterServerDeadline() {
        var now = Instant.parse("2026-11-17T12:10:01Z");
        var question = new Question("Q", List.of(new Answer("A", true)),
                Difficulty.EASY, ChoiceType.SINGLE);
        var meta = new AttemptMeta(7L, "assignment", "test", "Test",
                Instant.parse("2026-11-17T12:00:00Z"));
        var attempt = new Attempt("attempt", new Student("Ivan", "Petrov"), List.of(question), meta);
        attempt.touch(now);
        var listener = new CurrentUser(7L, "user", "Ivan", "Petrov", UserRole.USER);

        when(clock.instant()).thenReturn(now);
        when(testConfig.getTimeLimitSeconds()).thenReturn(600);
        when(testConfig.getHeartbeatTimeoutSeconds()).thenReturn(15);
        when(currentUser.require(UserRole.USER)).thenReturn(listener);
        when(activeAttempts.find("attempt")).thenReturn(attempt);

        assertThatThrownBy(() -> service.saveAnswer("attempt", 0, List.of(1)))
                .isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.CONFLICT))
                .hasMessageContaining("Время аттестации истекло");
        assertThat(attempt.getSelected().get(0)).isEmpty();
    }

    @Test
    void anyIncorrectOptionMakesMultipleChoiceQuestionWrong() {
        var question = new Question("Q", List.of(
                new Answer("A", true), new Answer("B", true), new Answer("C", false)),
                Difficulty.MEDIUM, ChoiceType.MULTIPLE);
        var attempt = attempt(question);
        attempt.select(0, Set.of(1, 2, 3));
        var listener = new CurrentUser(7L, "user", "Ivan", "Petrov", UserRole.USER);

        when(currentUser.require(UserRole.USER)).thenReturn(listener);
        when(activeAttempts.find("attempt")).thenReturn(attempt);
        when(answerKeys.correctIndexes(question)).thenReturn(Set.of(1, 2));
        when(testConfig.getPassingScore()).thenReturn(80);
        when(clock.instant()).thenReturn(Instant.parse("2026-11-19T10:00:00Z"));

        var result = service.finish("attempt");

        assertThat(result.scorePercent()).isZero();
        assertThat(result.rightAnswersCount()).isZero();
        assertThat(result.mistakes()).hasSize(1);
    }

    @Test
    void unansweredQuestionIsWrongButNotShownInMistakeReview() {
        var question = new Question("Q", List.of(new Answer("A", true)),
                Difficulty.EASY, ChoiceType.SINGLE);
        var attempt = attempt(question);
        var listener = new CurrentUser(7L, "user", "Ivan", "Petrov", UserRole.USER);

        when(currentUser.require(UserRole.USER)).thenReturn(listener);
        when(activeAttempts.find("attempt")).thenReturn(attempt);
        when(answerKeys.correctIndexes(question)).thenReturn(Set.of(1));
        when(testConfig.getPassingScore()).thenReturn(80);
        when(clock.instant()).thenReturn(Instant.parse("2026-11-19T10:00:00Z"));

        var result = service.finish("attempt");

        assertThat(result.scorePercent()).isZero();
        assertThat(result.rightAnswersCount()).isZero();
        assertThat(result.mistakes()).isEmpty();
    }

    @Test
    void heartbeatPausesAttemptAfterConnectionTimeout() {
        var started = Instant.parse("2026-11-19T10:00:00Z");
        var question = new Question("Q", List.of(new Answer("A", true)),
                Difficulty.EASY, ChoiceType.SINGLE);
        var meta = new AttemptMeta(7L, "assignment", "test", "Test", started);
        var attempt = new Attempt("attempt", new Student("Ivan", "Petrov"), List.of(question), meta);
        var listener = new CurrentUser(7L, "user", "Ivan", "Petrov", UserRole.USER);

        when(currentUser.require(UserRole.USER)).thenReturn(listener);
        when(activeAttempts.find("attempt")).thenReturn(attempt);
        when(testConfig.getHeartbeatTimeoutSeconds()).thenReturn(15);
        when(testConfig.getTimeLimitSeconds()).thenReturn(600);
        when(clock.instant()).thenReturn(started.plusSeconds(20));

        var state = service.heartbeat("attempt");

        assertThat(state.paused()).isTrue();
        assertThat(state.remainingSeconds()).isEqualTo(585);
    }

    @Test
    void managerCanResumePausedAttemptWithoutConsumingPausedTime() {
        var started = Instant.parse("2026-11-19T10:00:00Z");
        var meta = new AttemptMeta(7L, "assignment", "test", "Test", started);
        var attempt = new Attempt("attempt", new Student("Ivan", "Petrov"), List.of(), meta);
        attempt.pause(started.plusSeconds(15));

        when(currentUser.require(UserRole.MANAGER)).thenReturn(
                new CurrentUser(2L, "manager", "Manager", "One", UserRole.MANAGER));
        when(activeAttempts.find("attempt")).thenReturn(attempt);
        when(testConfig.getTimeLimitSeconds()).thenReturn(600);
        when(clock.instant()).thenReturn(started.plusSeconds(120));

        var state = service.resume("attempt");

        assertThat(state.paused()).isFalse();
        assertThat(state.remainingSeconds()).isEqualTo(585);
    }

    private Attempt attempt(Question question) {
        var meta = new AttemptMeta(7L, "assignment", "test", "Test",
                Instant.parse("2026-11-19T09:00:00Z"));
        return new Attempt("attempt", new Student("Ivan", "Petrov"), List.of(question), meta);
    }
}
