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
                questions_json, answers_json
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
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

    private static final String ACTIVE_SELECT = """
            SELECT attempt.*, moodle_user.firstname, moodle_user.lastname
            FROM attestation.attestation_attempt attempt
            JOIN public.mdl_user moodle_user ON moodle_user.id = attempt.listener_id
            WHERE attempt.finished_at IS NULL
            """;

    private static final String FINISHED = """
            SELECT attempt.test_title, attempt.finished_at, attempt.score_percent, attempt.passed,
                   moodle_user.firstname, moodle_user.lastname
            FROM attestation.attestation_attempt attempt
            JOIN public.mdl_user moodle_user ON moodle_user.id = attempt.listener_id
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
                json(attempt.getSelected()));
    }

    public void saveAnswers(Attempt attempt) {
        jdbc.update(SAVE_ANSWERS, json(attempt.getSelected()), attempt.getId());
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

    public boolean hasFinished(String assignmentId) {
        var count = jdbc.queryForObject(FINISHED_EXISTS, Integer.class, assignmentId);
        return count != null && count > 0;
    }

    public List<AttemptReportView> findFinished() {
        return jdbc.query(FINISHED + " ORDER BY attempt.finished_at DESC", this::toReport);
    }

    public List<AttemptReportView> findFinishedByListener(long listenerId) {
        return jdbc.query(FINISHED + " AND attempt.listener_id = ? ORDER BY attempt.finished_at DESC",
                this::toReport, listenerId);
    }

    public List<AttemptStats> stats() {
        return jdbc.query(STATS, (rs, row) -> new AttemptStats(
                rs.getString("test_code"), rs.getInt("passed_count"), rs.getInt("failed_count")));
    }

    private Attempt toAttempt(ResultSet rs, int row) throws SQLException {
        var questions = read(rs.getString("questions_json"), new TypeReference<List<Question>>() { });
        var answers = read(rs.getString("answers_json"), new TypeReference<List<Set<Integer>>>() { });
        var student = new Student(rs.getString("firstname"), rs.getString("lastname"));
        var meta = new AttemptMeta(rs.getLong("listener_id"), rs.getString("assignment_id"),
                rs.getString("test_code"), rs.getString("test_title"),
                Instant.ofEpochMilli(rs.getLong("started_at")));
        return new Attempt(rs.getString("id"), student, questions, meta, answers);
    }

    private AttemptReportView toReport(ResultSet rs, int row) throws SQLException {
        var finished = Instant.ofEpochMilli(rs.getLong("finished_at"));
        var name = rs.getString("lastname") + " " + rs.getString("firstname");
        return new AttemptReportView(rs.getString("test_title"), finished, rs.getInt("score_percent"),
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
