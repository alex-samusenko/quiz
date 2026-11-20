package ru.galaktika.web;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;
import ru.galaktika.auth.CurrentUser;
import ru.galaktika.auth.CurrentUserService;
import ru.galaktika.auth.UserRole;
import ru.galaktika.dao.TestCatalog;
import ru.galaktika.db.AssignmentRepository;
import ru.galaktika.db.AssignmentRow;
import ru.galaktika.db.AttemptRepository;
import ru.galaktika.db.MoodleAccount;
import ru.galaktika.db.MoodleUserRepository;
import ru.galaktika.domain.AttestationLevel;
import ru.galaktika.domain.AttestationTest;
import ru.galaktika.web.dto.AssignmentRequest;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AssignmentServiceTest {

    private static final Instant NOW = Instant.parse("2026-11-19T10:00:00Z");

    @Mock private CurrentUserService currentUser;
    @Mock private MoodleUserRepository users;
    @Mock private AssignmentRepository assignments;
    @Mock private TestCatalog catalog;
    @Mock private ActiveAttempts activeAttempts;
    @Mock private AttemptRepository attempts;

    private AssignmentService service;

    @BeforeEach
    void setUp() {
        service = new AssignmentService(currentUser, users, assignments, catalog, activeAttempts,
                attempts, Clock.fixed(NOW, ZoneOffset.UTC));
    }

    @Test
    void createsBatchAndWarnsAboutAnotherTimezone() {
        prepareTest();
        when(users.findActive("user1")).thenReturn(Optional.of(listener(1L, "user1", "Europe/Moscow")));
        when(users.findActive("user2")).thenReturn(Optional.of(listener(2L, "user2", "Asia/Yekaterinburg")));

        var created = service.create(request(List.of("user1", "user2"), NOW, NOW.plusSeconds(3600)));

        assertThat(created).hasSize(2);
        assertThat(created.get(0).timezoneWarning()).isEmpty();
        assertThat(created.get(1).timezoneWarning()).contains("Asia/Yekaterinburg");
        verify(assignments).insert(org.mockito.ArgumentMatchers.anyString(), eq(1L), eq("test"),
                eq(AttestationLevel.SPECIALIST), eq(9L), anyLong(), anyLong(), anyLong(), anyLong(), anyLong());
        verify(assignments).insert(org.mockito.ArgumentMatchers.anyString(), eq(2L), eq("test"),
                eq(AttestationLevel.SPECIALIST), eq(9L), anyLong(), anyLong(), anyLong(), anyLong(), anyLong());
    }

    @Test
    void rejectsWindowOutsideAssignmentPeriod() {
        prepareTest();
        var request = new AssignmentRequest(null, List.of("user1"), "test", AttestationLevel.SPECIALIST, NOW,
                NOW.plusSeconds(3600), NOW.minusSeconds(1), NOW.plusSeconds(1800));

        assertThatThrownBy(() -> service.create(request))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("Окно доступности");
        verify(assignments, never()).insert(org.mockito.ArgumentMatchers.anyString(), anyLong(),
                org.mockito.ArgumentMatchers.anyString(), any(AttestationLevel.class), anyLong(), anyLong(), anyLong(), anyLong(),
                anyLong(), anyLong());
    }

    @Test
    void blocksRetakeDuringThirtyDayInterval() {
        prepareTest();
        when(users.findActive("user1")).thenReturn(Optional.of(listener(1L, "user1", "Europe/Moscow")));
        when(assignments.lastFailedAt(1L, "test")).thenReturn(NOW.minusSeconds(10 * 86400).toEpochMilli());

        assertThatThrownBy(() -> service.create(request(List.of("user1"), NOW, NOW.plusSeconds(3600))))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("один месяц");
    }

    @Test
    void blocksOverlappingAssignmentForSameTestAndLevel() {
        prepareTest();
        when(users.findActive("user1")).thenReturn(Optional.of(listener(1L, "user1", "Europe/Moscow")));
        when(assignments.hasOverlapping(eq(1L), eq("test"), eq(AttestationLevel.SPECIALIST),
                anyLong(), anyLong())).thenReturn(true);

        assertThatThrownBy(() -> service.create(request(List.of("user1"), NOW, NOW.plusSeconds(3600))))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("уже есть незавершённое назначение");

        verify(assignments, never()).insert(org.mockito.ArgumentMatchers.anyString(), anyLong(),
                org.mockito.ArgumentMatchers.anyString(), any(AttestationLevel.class), anyLong(), anyLong(),
                anyLong(), anyLong(), anyLong(), anyLong());
    }

    @Test
    void blocksCancellationWhenAttemptIsActive() {
        when(currentUser.require(UserRole.MANAGER))
                .thenReturn(new CurrentUser(9L, "manager", "M", "M", UserRole.MANAGER));
        when(assignments.findById("assignment")).thenReturn(Optional.of(
                new AssignmentRow("assignment", 1L, "test", AttestationLevel.SPECIALIST, NOW.toEpochMilli(),
                        NOW.plusSeconds(3600).toEpochMilli(), NOW.toEpochMilli(),
                        NOW.plusSeconds(3600).toEpochMilli(), null)));
        when(attempts.hasActive("assignment")).thenReturn(true);

        assertThatThrownBy(() -> service.cancel("assignment"))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("активной попыткой");
        verify(assignments, never()).cancel(eq("assignment"), anyLong(), anyLong());
    }

    private void prepareTest() {
        when(currentUser.require(UserRole.MANAGER))
                .thenReturn(new CurrentUser(9L, "manager", "M", "M", UserRole.MANAGER));
        when(catalog.find("test")).thenReturn(Optional.of(
                new AttestationTest("test", "Test", "mentor", "test", AttestationLevel.SPECIALIST)));
        when(catalog.sharedQuestionCount(org.mockito.ArgumentMatchers.any())).thenReturn(0);
    }

    private AssignmentRequest request(List<String> usernames, Instant accessFrom, Instant accessUntil) {
        return new AssignmentRequest(null, usernames, "test", AttestationLevel.SPECIALIST, NOW.minusSeconds(60),
                NOW.plusSeconds(7200), accessFrom, accessUntil);
    }

    private MoodleAccount listener(long id, String username, String timezone) {
        return new MoodleAccount(id, username, "hash", "Ivan", "Petrov", "user", timezone);
    }
}
