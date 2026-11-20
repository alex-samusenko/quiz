package ru.galaktika.db;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import ru.galaktika.domain.Question;
import ru.galaktika.domain.Student;
import ru.galaktika.web.Attempt;
import ru.galaktika.web.AttemptMeta;
import ru.galaktika.web.ReviewWindow;
import ru.galaktika.web.dto.AttemptReportView;
import ru.galaktika.web.dto.AttemptResultView;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
@Profile("!console")
@RequiredArgsConstructor
public class AttemptRepository {

    private static final String CREATE = """
            INSERT INTO attestation.attestation_attempt (
                id, listener_id, assignment_id, test_code, test_title, started_at,
                questions_json, answers_json, paused_seconds, last_contact_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?)
            """;

    private static final String COMPLETE = """
            UPDATE attestation.attestation_attempt
            SET finished_at = ?, score_percent = ?, passed = ?, right_answers = ?,
                questions_count = ?, answers_json = ?
            WHERE id = ? AND finished_at IS NULL
            """;

    private static final String SAVE_ANSWERS = """
            UPDATE attestation.attestation_attempt SET answers_json = ?
            WHERE id = ? AND finished_at IS NULL
            """;

    private static final String SAVE_RUNTIME_STATE = """
            UPDATE attestation.attestation_attempt
            SET paused_at = ?, paused_seconds = ?, last_contact_at = ?
            WHERE id = ? AND finished_at IS NULL
            """;

    private static final String ACTIVE_SELECT = """
            SELECT attempt.*, moodle_user.firstname, moodle_user.lastname
            FROM attestation.attestation_attempt attempt
            JOIN public.mdl_user moodle_user ON moodle_user.id = attempt.listener_id
            WHERE attempt.finished_at IS NULL
            """;

    private static final String FINISHED = """
            SELECT attempt.id, attempt.test_title, attempt.finished_at, attempt.score_percent, attempt.passed,
                   (attempt.questions_json IS NOT NULL AND attempt.answers_json IS NOT NULL) review_data_available,
                   appeal.status appeal_status,
                   moodle_user.firstname, moodle_user.lastname
            FROM attestation.attestation_attempt attempt
            JOIN public.mdl_user moodle_user ON moodle_user.id = attempt.listener_id
            LEFT JOIN attestation.appeal appeal ON appeal.attempt_id = attempt.id
            WHERE attempt.finished_at IS NOT NULL
            """;

    private static final String FINISHED_EXISTS = """
            SELECT COUNT(*) FROM attestation.attestation_attempt
            WHERE assignment_id = ? AND finished_at IS NOT NULL
            """;

    private static final String STATS = """
            SELECT test_code,
                   SUM(CASE WHEN passed THEN 1 ELSE 0 END) AS passed_count,
                   SUM(CASE WHEN passed THEN 0 ELSE 1 END) AS failed_count
            FROM attestation.attestation_attempt
            WHERE finished_at IS NOT NULL
            GROUP BY test_code
            """;

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public void create(Attempt attempt) {
        var meta = attempt.getMeta();
        jdbc.update(CREATE, attempt.getId(), meta.listenerId(), meta.assignmentId(), meta.testCode(),
                meta.testTitle(), meta.startedAt().toEpochMilli(), json(attempt.getQuestions()),
                json(attempt.getSelected()), meta.startedAt().toEpochMilli());
    }

    public void saveAnswers(Attempt attempt) {
        jdbc.update(SAVE_ANSWERS, json(attempt.getSelected()), attempt.getId());
    }

    public void saveRuntimeState(Attempt attempt) {
        var pausedAt = attempt.getPausedAt();
        var lastContact = attempt.getLastContactAt();
        jdbc.update(SAVE_RUNTIME_STATE, pausedAt == null ? null : pausedAt.toEpochMilli(),
                attempt.getPausedSeconds(), lastContact == null ? null : lastContact.toEpochMilli(),
                attempt.getId());
    }

    public void complete(Attempt attempt, AttemptResultView result, long finishedAt) {
        jdbc.update(COMPLETE, finishedAt, result.scorePercent(), result.passed(),
                result.rightAnswersCount(), result.questionsCount(), json(attempt.getSelected()),
                attempt.getId());
    }

    public Optional<Attempt> findActive(String id) {
        return jdbc.query(ACTIVE_SELECT + " AND attempt.id = ?", this::toAttempt, id).stream().findFirst();
    }

    public Optional<Attempt> findActiveByAssignment(String assignmentId) {
        return jdbc.query(ACTIVE_SELECT + " AND attempt.assignment_id = ?", this::toAttempt, assignmentId)
                .stream().findFirst();
    }

    public List<Attempt> findActive() {
        return jdbc.query(ACTIVE_SELECT + " ORDER BY attempt.started_at", this::toAttempt);
    }

    public boolean hasFinished(String assignmentId) {
        var count = jdbc.queryForObject(FINISHED_EXISTS, Integer.class, assignmentId);
        return count != null && count > 0;
    }

    public boolean hasActive(String assignmentId) {
        var count = jdbc.queryForObject("""
                SELECT COUNT(*) FROM attestation.attestation_attempt
                WHERE assignment_id = ? AND finished_at IS NULL
                """, Integer.class, assignmentId);
        return count != null && count > 0;
    }

    public String activeIdForAssignment(String assignmentId) {
        return jdbc.query("""
                SELECT id FROM attestation.attestation_attempt
                WHERE assignment_id = ? AND finished_at IS NULL
                """, rs -> rs.next() ? rs.getString(1) : null, assignmentId);
    }

    public List<AttemptReportView> findFinished() {
        return jdbc.query(FINISHED + " ORDER BY attempt.finished_at DESC", this::toReport);
    }

    public List<AttemptReportView> findFinishedByListener(long listenerId) {
        return jdbc.query(FINISHED + " AND attempt.listener_id = ? ORDER BY attempt.finished_at DESC",
                this::toReport, listenerId);
    }

    public List<AttemptReportView> findFinishedByMentor(String username) {
        return jdbc.query(FINISHED + """
                AND EXISTS (
                    SELECT 1 FROM public.mdl_quiz quiz
                    JOIN public.mdl_user author ON author.id = quiz.created_by
                    WHERE quiz.idnumber = attempt.test_code AND author.username = ?
                ) ORDER BY attempt.finished_at DESC
                """, this::toReport, username);
    }

    public List<AttemptStats> stats() {
        return jdbc.query(STATS, (rs, row) -> new AttemptStats(
                rs.getString("test_code"), rs.getInt("passed_count"), rs.getInt("failed_count")));
    }

    public Optional<FinishedAttemptReview> findFinishedReview(String id, long listenerId) {
        var sql = """
                SELECT id, test_title, finished_at, score_percent, passed, right_answers,
                       questions_count, questions_json, answers_json
                FROM attestation.attestation_attempt
                WHERE id = ? AND listener_id = ? AND finished_at IS NOT NULL
                  AND questions_json IS NOT NULL AND answers_json IS NOT NULL
                """;
        return jdbc.query(sql, (rs, row) -> new FinishedAttemptReview(
                rs.getString("id"), rs.getString("test_title"),
                Instant.ofEpochMilli(rs.getLong("finished_at")), rs.getInt("score_percent"),
                rs.getBoolean("passed"), rs.getInt("right_answers"), rs.getInt("questions_count"),
                read(rs.getString("questions_json"), new TypeReference<List<Question>>() { }),
                read(rs.getString("answers_json"), new TypeReference<List<Set<Integer>>>() { })),
                id, listenerId).stream().findFirst();
    }

    public Optional<FinishedAttemptReview> findFinishedReviewForMentor(String id, String username) {
        var sql = """
                SELECT attempt.id, attempt.test_title, attempt.finished_at, attempt.score_percent,
                       attempt.passed, attempt.right_answers, attempt.questions_count,
                       attempt.questions_json, attempt.answers_json
                FROM attestation.attestation_attempt attempt
                JOIN public.mdl_quiz quiz ON quiz.idnumber = attempt.test_code
                JOIN public.mdl_user author ON author.id = quiz.created_by
                WHERE attempt.id = ? AND author.username = ? AND attempt.finished_at IS NOT NULL
                """;
        return jdbc.query(sql, this::toFinishedReview, id, username).stream().findFirst();
    }

    public boolean hasAppeal(String attemptId) {
        return Boolean.TRUE.equals(jdbc.queryForObject(
                "SELECT COUNT(*) > 0 FROM attestation.appeal WHERE attempt_id = ?", Boolean.class, attemptId));
    }

    public void updateFinishedAnswers(String id, List<Set<Integer>> answers, AttemptResultView result) {
        jdbc.update("""
                UPDATE attestation.attestation_attempt
                SET answers_json = ?, score_percent = ?, passed = ?, right_answers = ?
                WHERE id = ? AND finished_at IS NOT NULL
                """, json(answers), result.scorePercent(), result.passed(), result.rightAnswersCount(), id);
    }

    private FinishedAttemptReview toFinishedReview(ResultSet rs, int row) throws SQLException {
        return new FinishedAttemptReview(rs.getString("id"), rs.getString("test_title"),
                Instant.ofEpochMilli(rs.getLong("finished_at")), rs.getInt("score_percent"),
                rs.getBoolean("passed"), rs.getInt("right_answers"), rs.getInt("questions_count"),
                read(rs.getString("questions_json"), new TypeReference<List<Question>>() { }),
                read(rs.getString("answers_json"), new TypeReference<List<Set<Integer>>>() { }));
    }

    private Attempt toAttempt(ResultSet rs, int row) throws SQLException {
        var questions = read(rs.getString("questions_json"), new TypeReference<List<Question>>() { });
        var answers = read(rs.getString("answers_json"), new TypeReference<List<Set<Integer>>>() { });
        var student = new Student(rs.getString("firstname"), rs.getString("lastname"));
        var meta = new AttemptMeta(rs.getLong("listener_id"), rs.getString("assignment_id"),
                rs.getString("test_code"), rs.getString("test_title"),
                Instant.ofEpochMilli(rs.getLong("started_at")));
        var pausedMillis = (Long) rs.getObject("paused_at");
        var contactMillis = (Long) rs.getObject("last_contact_at");
        return new Attempt(rs.getString("id"), student, questions, meta, answers,
                pausedMillis == null ? null : Instant.ofEpochMilli(pausedMillis),
                rs.getLong("paused_seconds"),
                contactMillis == null ? meta.startedAt() : Instant.ofEpochMilli(contactMillis));
    }

    private AttemptReportView toReport(ResultSet rs, int row) throws SQLException {
        var finished = Instant.ofEpochMilli(rs.getLong("finished_at"));
        var name = rs.getString("lastname") + " " + rs.getString("firstname");
        return new AttemptReportView(rs.getString("id"), rs.getString("test_title"), finished,
                ReviewWindow.until(finished), rs.getBoolean("review_data_available"),
                rs.getString("appeal_status"), rs.getInt("score_percent"),
                rs.getBoolean("passed"), name);
    }

    private String json(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Не удалось сохранить состояние попытки", exception);
        }
    }

    private <T> T read(String value, TypeReference<T> type) {
        try {
            return objectMapper.readValue(value, type);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Не удалось восстановить состояние попытки", exception);
        }
    }
}
