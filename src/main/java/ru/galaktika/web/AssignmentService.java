package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import ru.galaktika.auth.CurrentUserService;
import ru.galaktika.auth.UserRole;
import ru.galaktika.dao.TestCatalog;
import ru.galaktika.db.AssignmentListRow;
import ru.galaktika.db.AssignmentRepository;
import ru.galaktika.db.AssignmentRow;
import ru.galaktika.db.AttemptRepository;
import ru.galaktika.db.MoodleAccount;
import ru.galaktika.db.MoodleUserRepository;
import ru.galaktika.domain.AttestationTest;
import ru.galaktika.domain.AttestationLevel;
import ru.galaktika.web.dto.AssignmentReportView;
import ru.galaktika.web.dto.AssignmentRequest;
import ru.galaktika.web.dto.AssignmentView;
import ru.galaktika.web.dto.OpenAssignmentView;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

@Service
@Profile("!console")
@RequiredArgsConstructor
public class AssignmentService {

    private static final String LISTENER_ROLE = "user";

    private final CurrentUserService currentUser;
    private final MoodleUserRepository users;
    private final AssignmentRepository assignments;
    private final TestCatalog catalog;
    private final ActiveAttempts activeAttempts;
    private final AttemptRepository attempts;
    private final Clock clock;

    public AssignmentView create(String username, String testCode) {
        var now = Instant.now(clock);
        var test = requireTest(testCode);
        var request = new AssignmentRequest(username, null, testCode, test.level(), now,
                now.plus(Duration.ofDays(30)), now, now.plus(Duration.ofDays(30)));
        return create(request).get(0);
    }

    @Transactional
    public List<AssignmentView> create(AssignmentRequest request) {
        var manager = currentUser.require(UserRole.MANAGER);
        var test = requireTest(request.testCode());
        var level = requireLevel(request.level());
        validateTest(test);
        var window = validateWindow(request);
        if (request.listeners().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Выберите хотя бы одного слушателя");
        }
        return request.listeners().stream().distinct().map(username -> {
            var listener = requireListener(username);
            validateRetake(listener, test.code(), window.accessFrom());
            validateDuplicate(listener, test.code(), level, window);
            var id = UUID.randomUUID().toString();
            assignments.insert(id, listener.id(), test.code(), level, manager.id(), Instant.now(clock).toEpochMilli(),
                    window.startsAt().toEpochMilli(), window.endsAt().toEpochMilli(),
                    window.accessFrom().toEpochMilli(), window.accessUntil().toEpochMilli());
            return new AssignmentView(id, test.code(), test.title(), level, listener.username(),
                    timezoneWarning(listener));
        }).toList();
    }

    public List<AssignmentReportView> all() {
        currentUser.require(UserRole.MANAGER);
        var now = Instant.now(clock);
        return assignments.listAll().stream().map(row -> toReport(row, now)).toList();
    }

    public List<OpenAssignmentView> mine() {
        var listener = currentUser.require(UserRole.USER);
        var now = Instant.now(clock);
        return assignments.findOpen(listener.id(), now.toEpochMilli()).stream()
                .map(row -> toOpen(row, now)).toList();
    }

    public void cancel(String id) {
        var manager = currentUser.require(UserRole.MANAGER);
        var assignment = assignments.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Назначение не найдено"));
        if (attempts.hasActive(assignment.id())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Нельзя отменить назначение с активной попыткой");
        }
        assignments.cancel(id, manager.id(), Instant.now(clock).toEpochMilli());
    }

    private AssignmentReportView toReport(AssignmentListRow row, Instant now) {
        var test = catalog.findAny(row.testCode())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Тест не найден"));
        return new AssignmentReportView(row.id(), row.listenerName(), test.title(), row.level(),
                Instant.ofEpochMilli(row.assignedAt()), Instant.ofEpochMilli(row.accessFrom()),
                Instant.ofEpochMilli(row.accessUntil()), status(row, now));
    }

    private OpenAssignmentView toOpen(AssignmentRow row, Instant now) {
        var test = requireTest(row.testCode());
        var activeAttemptId = activeAttempts.idForAssignment(row.id());
        if (activeAttemptId == null) {
            activeAttemptId = attempts.activeIdForAssignment(row.id());
        }
        var available = !now.isBefore(Instant.ofEpochMilli(row.accessFrom()))
                && now.isBefore(Instant.ofEpochMilli(row.accessUntil()));
        return new OpenAssignmentView(row.id(), test.code(), test.title(), row.level(),
                activeAttemptId, Instant.ofEpochMilli(row.accessFrom()),
                Instant.ofEpochMilli(row.accessUntil()), available,
                activeAttemptId != null ? "Выполняется" : available ? "Доступно" : "Запланировано");
    }

    private void validateTest(AttestationTest test) {
        var shared = catalog.sharedQuestionCount(test);
        if (shared > 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Назначение невозможно: " + shared
                            + " вопросов одновременно включены в другие доступные тесты");
        }
    }

    private AssignmentWindow validateWindow(AssignmentRequest request) {
        if (request.startsAt() == null || request.endsAt() == null
                || request.accessFrom() == null || request.accessUntil() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Укажите период и окно доступности");
        }
        if (!request.startsAt().isBefore(request.endsAt())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Дата начала должна быть раньше срока окончания");
        }
        if (!request.accessFrom().isBefore(request.accessUntil())
                || request.accessFrom().isBefore(request.startsAt())
                || request.accessUntil().isAfter(request.endsAt())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Окно доступности должно находиться внутри периода назначения");
        }
        return new AssignmentWindow(request.startsAt(), request.endsAt(),
                request.accessFrom(), request.accessUntil());
    }

    private void validateRetake(MoodleAccount listener, String testCode, Instant accessFrom) {
        var lastFailed = assignments.lastFailedAt(listener.id(), testCode);
        var allowedFrom = lastFailed == null ? null : Instant.ofEpochMilli(lastFailed)
                .atZone(ZoneId.of("Europe/Moscow")).plusMonths(1).toInstant();
        if (allowedFrom != null && accessFrom.isBefore(allowedFrom)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Пересдачу можно назначить не ранее чем через один месяц после неудачной попытки");
        }
    }

    private void validateDuplicate(MoodleAccount listener, String testCode, AttestationLevel level,
                                   AssignmentWindow window) {
        if (assignments.hasOverlapping(listener.id(), testCode, level,
                window.startsAt().toEpochMilli(), window.endsAt().toEpochMilli())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "У слушателя уже есть незавершённое назначение этого теста и уровня на пересекающийся период");
        }
    }

    private String timezoneWarning(MoodleAccount listener) {
        var timezone = listener.timezone();
        return timezone == null || timezone.isBlank() || "Europe/Moscow".equals(timezone)
                ? "" : "Часовой пояс слушателя: " + timezone
                + ". Время назначения указано по Москве";
    }

    private String status(AssignmentListRow row, Instant now) {
        if (row.cancelled()) {
            return "Отменено";
        }
        if (row.finished()) {
            return "Завершено";
        }
        if (row.active()) {
            return "Выполняется";
        }
        if (!now.isBefore(Instant.ofEpochMilli(row.accessUntil()))) {
            return "Просрочено";
        }
        if (now.isBefore(Instant.ofEpochMilli(row.accessFrom()))) {
            return "Запланировано";
        }
        return "Доступно";
    }

    private MoodleAccount requireListener(String username) {
        if (username == null || username.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Укажите слушателя");
        }
        var account = users.findActive(username.trim())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Слушатель не найден"));
        if (!LISTENER_ROLE.equals(account.role())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Назначать тест можно только слушателю");
        }
        return account;
    }

    private AttestationTest requireTest(String testCode) {
        if (testCode == null || testCode.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Укажите тест");
        }
        return catalog.find(testCode)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Тест не найден"));
    }

    private AttestationLevel requireLevel(AttestationLevel level) {
        if (level == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Выберите уровень аттестации");
        }
        return level;
    }

    private record AssignmentWindow(
            Instant startsAt,
            Instant endsAt,
            Instant accessFrom,
            Instant accessUntil) {
    }
}
