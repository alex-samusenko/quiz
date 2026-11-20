package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import ru.galaktika.auth.CurrentUser;
import ru.galaktika.auth.CurrentUserService;
import ru.galaktika.auth.UserRole;
import ru.galaktika.config.TestConfig;
import ru.galaktika.dao.TestCatalog;
import ru.galaktika.db.AssignmentRepository;
import ru.galaktika.db.AssignmentRow;
import ru.galaktika.db.AttemptRepository;
import ru.galaktika.domain.AttestationTest;
import ru.galaktika.domain.ChoiceType;
import ru.galaktika.domain.Question;
import ru.galaktika.domain.Student;
import ru.galaktika.domain.TestResult;
import ru.galaktika.service.AnswerKeys;
import ru.galaktika.web.dto.AttemptResultView;
import ru.galaktika.web.dto.AttemptReviewView;
import ru.galaktika.web.dto.AttemptSession;
import ru.galaktika.web.dto.AttemptStateView;
import ru.galaktika.web.dto.ActiveAttemptView;
import ru.galaktika.web.dto.MistakeView;
import ru.galaktika.web.dto.QuestionView;
import ru.galaktika.web.dto.ReviewedAnswerView;

import java.time.Duration;
import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@Profile("!console")
@RequiredArgsConstructor
public class AttemptService {

    private final TestCatalog catalog;

    private final TestConfig testConfig;

    private final AnswerKeys answerKeys;

    private final AssignmentRepository assignments;

    private final AttemptRepository attemptRepository;

    private final ActiveAttempts activeAttempts;

    private final CurrentUserService currentUser;

    private final AttemptQuestionSelector questionSelector;

    private final Clock clock;

    public AttemptSession start(String assignmentId) {
        var listener = currentUser.require(UserRole.USER);
        if (assignmentId == null || assignmentId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Не выбрано назначение");
        }
        return open(listener, assignmentId);
    }

    public AttemptSession read(String id) {
        var attempt = requireOwned(id);
        if (attempt.getResult() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Аттестация уже завершена");
        }
        updateConnectionState(attempt, Instant.now(clock), false);
        return toSession(attempt);
    }

    public AttemptStateView heartbeat(String id) {
        var attempt = requireOwned(id);
        var now = Instant.now(clock);
        updateConnectionState(attempt, now, true);
        return new AttemptStateView(attempt.isPaused(), remainingSeconds(attempt));
    }

    public void saveAnswer(String id, int questionIndex, List<Integer> selected) {
        var attempt = requireOwned(id);
        if (attempt.getResult() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Аттестация уже завершена");
        }
        updateConnectionState(attempt, Instant.now(clock), true);
        requireRunning(attempt);
        if (remainingSeconds(attempt) == 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Время аттестации истекло");
        }
        if (questionIndex < 0 || questionIndex >= attempt.getQuestions().size()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Неизвестный вопрос");
        }
        var values = selected == null ? Set.<Integer>of() : Set.copyOf(selected);
        validateSelection(attempt.getQuestions().get(questionIndex), values);
        attempt.select(questionIndex, values);
        attemptRepository.saveAnswers(attempt);
    }

    public AttemptResultView finish(String id) {
        var attempt = requireOwned(id);
        if (attempt.getResult() != null) {
            return attempt.getResult();
        }
        updateConnectionState(attempt, Instant.now(clock), true);
        requireRunning(attempt);
        var graded = grade(attempt);
        attemptRepository.complete(attempt, graded, Instant.now(clock).toEpochMilli());
        attempt.complete(graded);
        activeAttempts.finish(attempt);
        return graded;
    }

    public AttemptReviewView review(String id) {
        var listener = currentUser.require(UserRole.USER);
        var stored = attemptRepository.findFinishedReview(id, listener.id())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Данные для разбора этой попытки не сохранены"));
        var reviewUntil = ReviewWindow.until(stored.finishedAt());
        if (!Instant.now(clock).isBefore(reviewUntil)) {
            throw new ResponseStatusException(HttpStatus.GONE, "Срок просмотра разбора истёк");
        }
        return toReview(stored, reviewUntil);
    }

    public AttemptReviewView mentorReview(String id) {
        var mentor = currentUser.require(UserRole.MENTOR);
        var stored = attemptRepository.findFinishedReviewForMentor(id, mentor.username())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Попытка не найдена"));
        return toReview(stored, ReviewWindow.until(stored.finishedAt()));
    }

    public AttemptReviewView updateByMentor(String id, int questionIndex, List<Integer> selected) {
        var mentor = currentUser.require(UserRole.MENTOR);
        var stored = attemptRepository.findFinishedReviewForMentor(id, mentor.username())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Попытка не найдена"));
        if (!attemptRepository.hasAppeal(id)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Ответы можно изменять только после подачи апелляции");
        }
        if (questionIndex < 0 || questionIndex >= stored.questions().size()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Неизвестный вопрос");
        }
        var values = selected == null ? Set.<Integer>of() : Set.copyOf(selected);
        validateSelection(stored.questions().get(questionIndex), values);
        var answers = new ArrayList<>(stored.answers());
        answers.set(questionIndex, values);
        var result = grade(stored.questions(), answers);
        attemptRepository.updateFinishedAnswers(id, answers, result);
        var updated = new ru.galaktika.db.FinishedAttemptReview(stored.id(), stored.testTitle(),
                stored.finishedAt(), result.scorePercent(), result.passed(), result.rightAnswersCount(),
                result.questionsCount(), stored.questions(), answers);
        return toReview(updated, ReviewWindow.until(stored.finishedAt()));
    }

    private AttemptReviewView toReview(ru.galaktika.db.FinishedAttemptReview stored, Instant reviewUntil) {
        var questions = stored.questions();
        var reviewedAnswers = new ArrayList<ReviewedAnswerView>();
        for (var index = 0; index < questions.size(); index++) {
            var selected = stored.answers().get(index);
            var correct = answerKeys.correctIndexes(questions.get(index));
            reviewedAnswers.add(new ReviewedAnswerView(index, questions.get(index).text(),
                    selected.equals(correct), sorted(selected), sorted(correct)));
        }
        var views = new ArrayList<QuestionView>();
        for (var index = 0; index < questions.size(); index++) {
            views.add(toView(questions.get(index), index));
        }
        return new AttemptReviewView(stored.testTitle(), stored.finishedAt(), reviewUntil,
                stored.scorePercent(), stored.passed(), stored.rightAnswers(), stored.questionsCount(),
                views, reviewedAnswers);
    }

    public List<ActiveAttemptView> managerActive() {
        currentUser.require(UserRole.MANAGER);
        pauseStaleAttempts();
        return attemptRepository.findActive().stream().map(attempt -> new ActiveAttemptView(
                attempt.getId(), attempt.getStudent().lastName() + " " + attempt.getStudent().firstName(),
                attempt.getMeta().testTitle(), attempt.isPaused(), remainingSeconds(attempt))).toList();
    }

    public AttemptStateView resume(String id) {
        currentUser.require(UserRole.MANAGER);
        var attempt = require(id);
        if (!attempt.isPaused()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Попытка не приостановлена");
        }
        attempt.resume(Instant.now(clock));
        attemptRepository.saveRuntimeState(attempt);
        return new AttemptStateView(false, remainingSeconds(attempt));
    }

    public void pauseStaleAttempts() {
        var now = Instant.now(clock);
        for (var persisted : attemptRepository.findActive()) {
            var attempt = activeAttempts.find(persisted.getId());
            if (attempt == null) {
                attempt = persisted;
                activeAttempts.put(attempt);
            }
            updateConnectionState(attempt, now, false);
        }
    }

    private AttemptSession open(CurrentUser listener, String assignmentId) {
        var assignment = requireOpen(assignmentId, listener.id());
        var existingId = activeAttempts.idForAssignment(assignmentId);
        if (existingId != null) {
            return toSession(require(existingId));
        }
        var persisted = attemptRepository.findActiveByAssignment(assignmentId);
        if (persisted.isPresent()) {
            activeAttempts.put(persisted.get());
            return toSession(persisted.get());
        }
        return remember(listener, assignment);
    }

    private AttemptSession remember(CurrentUser listener, AssignmentRow assignment) {
        var test = requireTest(assignment.testCode());
        var attempt = create(listener, assignment, test);
        attemptRepository.create(attempt);
        activeAttempts.put(attempt);
        return toSession(attempt);
    }

    private Attempt create(CurrentUser listener, AssignmentRow assignment, AttestationTest test) {
        var meta = new AttemptMeta(listener.id(), assignment.id(), test.code(), test.title(), Instant.now(clock));
        var student = new Student(listener.firstName(), listener.lastName());
        try {
            var questions = questionSelector.select(catalog.questions(test), assignment.level(),
                    testConfig.getQuestionCount(), testConfig.isShuffleQuestions(),
                    testConfig.isShuffleAnswers());
            return new Attempt(UUID.randomUUID().toString(), student, questions, meta);
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Невозможно сформировать попытку. " + ex.getMessage(), ex);
        }
    }

    private AssignmentRow requireOpen(String assignmentId, long listenerId) {
        var assignment = assignments.findById(assignmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Назначение не найдено"));
        if (assignment.listenerId() != listenerId) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Назначение другого слушателя");
        }
        var now = Instant.now(clock).toEpochMilli();
        if (assignment.cancelledAt() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Назначение отменено");
        }
        if (now < assignment.accessFrom()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Окно доступности ещё не открыто");
        }
        if (now >= assignment.accessUntil() || now >= assignment.endsAt()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Срок назначения истёк");
        }
        if (attemptRepository.hasFinished(assignmentId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Это назначение уже выполнено");
        }
        return assignment;
    }

    private AttestationTest requireTest(String code) {
        return catalog.find(code)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Тест не найден"));
    }

    private AttemptResultView grade(Attempt attempt) {
        return grade(attempt.getQuestions(), attempt.getSelected());
    }

    private AttemptResultView grade(List<Question> questions, List<Set<Integer>> selected) {
        var result = new TestResult(new Student("", ""));
        List<MistakeView> mistakes = new ArrayList<>();
        for (var i = 0; i < questions.size(); i++) {
            collectAnswer(result, mistakes, questions.get(i), selected.get(i), i);
        }
        var percent = result.getScorePercent();
        return new AttemptResultView(percent, percent >= testConfig.getPassingScore(),
                result.getRightAnswersCount(), questions.size(), mistakes);
    }

    private void collectAnswer(TestResult result, List<MistakeView> mistakes, Question question,
                               Set<Integer> selected, int index) {
        var correct = answerKeys.correctIndexes(question);
        var right = correct.equals(selected);
        result.applyAnswer(question, right);
        if (!right && !selected.isEmpty()) {
            mistakes.add(new MistakeView(index, question.text(), sorted(selected), sorted(correct)));
        }
    }

    private void validateSelection(Question question, Set<Integer> values) {
        var max = question.answers().size();
        if (values.stream().anyMatch(value -> value < 1 || value > max)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Некорректный номер ответа");
        }
        if (question.choiceType() == ChoiceType.SINGLE && values.size() > 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Нужен один вариант");
        }
    }

    private Attempt requireOwned(String id) {
        var listener = currentUser.require(UserRole.USER);
        var attempt = require(id);
        if (attempt.getMeta().listenerId() != listener.id()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Чужая попытка");
        }
        return attempt;
    }

    private Attempt require(String id) {
        var attempt = activeAttempts.find(id);
        if (attempt == null) {
            attempt = attemptRepository.findActive(id).orElse(null);
            if (attempt != null) {
                activeAttempts.put(attempt);
            }
        }
        if (attempt == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Попытка не найдена");
        }
        return attempt;
    }

    private AttemptSession toSession(Attempt attempt) {
        List<QuestionView> views = new ArrayList<>();
        var questions = attempt.getQuestions();
        for (var i = 0; i < questions.size(); i++) {
            views.add(toView(questions.get(i), i));
        }
        return new AttemptSession(attempt.getId(), attempt.getMeta().testTitle(),
                testConfig.getTimeLimitSeconds(), remainingSeconds(attempt),
                testConfig.getPassingScore(), attempt.isPaused(), views,
                attempt.getSelected().stream().map(this::sorted).toList());
    }

    private int remainingSeconds(Attempt attempt) {
        var spent = attempt.elapsedSeconds(Instant.now(clock));
        return (int) Math.max(0, testConfig.getTimeLimitSeconds() - spent);
    }

    private void updateConnectionState(Attempt attempt, Instant now, boolean touch) {
        var lastContact = attempt.getLastContactAt();
        if (!attempt.isPaused() && lastContact != null) {
            var timeout = testConfig.getHeartbeatTimeoutSeconds();
            if (timeout > 0 && Duration.between(lastContact, now).toSeconds() > timeout) {
                attempt.pause(lastContact.plusSeconds(timeout));
            }
        }
        if (touch && !attempt.isPaused()) {
            attempt.touch(now);
        }
        attemptRepository.saveRuntimeState(attempt);
    }

    private void requireRunning(Attempt attempt) {
        if (attempt.isPaused()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Попытка приостановлена. Возобновление выполняет менеджер");
        }
    }

    private QuestionView toView(Question question, int index) {
        List<String> options = question.answers().stream().map(answer -> answer.text()).toList();
        return new QuestionView(index, question.text(), question.difficulty().name(),
                question.difficulty().getWeight(), question.choiceType().name(), options);
    }

    private List<Integer> sorted(Set<Integer> values) {
        return values.stream().sorted().toList();
    }
}
