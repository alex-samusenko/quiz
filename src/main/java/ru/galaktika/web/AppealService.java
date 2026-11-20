package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import ru.galaktika.auth.CurrentUserService;
import ru.galaktika.auth.UserRole;
import ru.galaktika.db.AppealRepository;
import ru.galaktika.web.dto.AppealRequest;
import ru.galaktika.web.dto.AppealResolutionRequest;
import ru.galaktika.web.dto.AppealView;
import ru.galaktika.service.AnswerKeys;

import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@Profile("!console")
@RequiredArgsConstructor
public class AppealService {

    private static final int MAX_BASE64_LENGTH = 14_000_000;
    private static final Set<String> TYPES = Set.of("image/png", "image/jpeg", "application/pdf");

    private final CurrentUserService currentUser;
    private final AppealRepository appeals;
    private final Clock clock;
    private final AnswerKeys answerKeys;

    @Transactional
    public void create(String attemptId, AppealRequest request) {
        var listener = currentUser.require(UserRole.USER);
        var attempt = appeals.attempt(attemptId, listener.id());
        if (attempt == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Попытка не найдена");
        if (attempt.passed() || attempt.score() >= 80) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Апелляция доступна только при результате ниже 80");
        }
        if (!Instant.now(clock).isBefore(ReviewWindow.until(attempt.finishedAt()))) {
            throw new ResponseStatusException(HttpStatus.GONE, "Срок подачи апелляции истёк");
        }
        if (appeals.exists(attemptId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Апелляция по этой попытке уже подана");
        }
        validate(request, attemptId, listener.id());
        appeals.insert(UUID.randomUUID().toString(), attempt, listener.id(), request,
                Instant.now(clock).toEpochMilli());
    }

    public List<AppealView> mentorAppeals() {
        var mentor = currentUser.require(UserRole.MENTOR);
        return appeals.forMentor(mentor.username());
    }

    @Transactional
    public void resolve(String id, AppealResolutionRequest request) {
        var mentor = currentUser.require(UserRole.MENTOR);
        var appeal = appeals.owner(id, mentor.username());
        if (appeal == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Апелляция не найдена");
        if (!"SUBMITTED".equals(appeal.status())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Апелляция уже рассмотрена");
        }
        requireText(request.explanation(), "Укажите пояснение к решению");
        if ("REJECT".equals(request.decision())) {
            appeals.resolve(id, "REJECTED", mentor.id(), Instant.now(clock).toEpochMilli(),
                    request.explanation().trim(), null);
            return;
        }
        if (!"CHANGE_SCORE".equals(request.decision()) || request.score() == null
                || request.score() < 0 || request.score() > 100) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Укажите новый балл от 0 до 100");
        }
        appeals.changeScore(appeal.attemptId(), request.score());
        appeals.resolve(id, "SCORE_CHANGED", mentor.id(), Instant.now(clock).toEpochMilli(),
                request.explanation().trim(), request.score());
    }

    private void validate(AppealRequest request, String attemptId, long listenerId) {
        if (request == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Заполните апелляцию");
        if (request.questionIndexes() == null || request.questionIndexes().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Выберите хотя бы один неверный ответ");
        }
        var review = appeals.attemptReview(attemptId, listenerId);
        if (review == null || request.questionIndexes().stream().distinct().anyMatch(index ->
                index == null || index < 0 || index >= review.questions().size()
                        || review.answers().get(index).equals(answerKeys.correctIndexes(review.questions().get(index))))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Можно выбрать только вопросы с неверным ответом");
        }
        requireText(request.exampleDescription(), "Опишите выполненный пример");
        requireText(request.interpretation(), "Изложите свою позицию");
        requireText(request.attachmentName(), "Приложите скриншот или PDF");
        if (!TYPES.contains(request.attachmentType()) || request.attachmentBase64() == null
                || request.attachmentBase64().isBlank() || request.attachmentBase64().length() > MAX_BASE64_LENGTH) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Приложите PNG, JPEG или PDF размером не более 10 МБ");
        }
    }

    private void requireText(String value, String message) {
        if (value == null || value.isBlank()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, message);
    }
}
