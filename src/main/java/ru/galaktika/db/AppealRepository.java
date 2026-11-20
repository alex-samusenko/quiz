package ru.galaktika.db;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import ru.galaktika.web.dto.AppealRequest;
import ru.galaktika.web.dto.AppealView;
import ru.galaktika.domain.Question;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Set;

@Repository
@Profile("!console")
@RequiredArgsConstructor
public class AppealRepository {

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public AttemptForAppeal attempt(String id, long listenerId) {
        return jdbc.query("""
                SELECT id, test_code, test_title, finished_at, score_percent, passed
                FROM attestation.attestation_attempt
                WHERE id = ? AND listener_id = ? AND finished_at IS NOT NULL
                """, rs -> rs.next() ? new AttemptForAppeal(rs.getString("id"), rs.getString("test_code"),
                rs.getString("test_title"), Instant.ofEpochMilli(rs.getLong("finished_at")),
                rs.getInt("score_percent"), rs.getBoolean("passed")) : null, id, listenerId);
    }

    public boolean exists(String attemptId) {
        return Boolean.TRUE.equals(jdbc.queryForObject(
                "SELECT COUNT(*) > 0 FROM attestation.appeal WHERE attempt_id = ?", Boolean.class, attemptId));
    }

    public FinishedAttemptReview attemptReview(String id, long listenerId) {
        return jdbc.query("""
                SELECT id, test_title, finished_at, score_percent, passed, right_answers,
                       questions_count, questions_json, answers_json
                FROM attestation.attestation_attempt
                WHERE id = ? AND listener_id = ? AND finished_at IS NOT NULL
                """, rs -> {
            if (!rs.next()) return null;
            try {
                return new FinishedAttemptReview(rs.getString("id"), rs.getString("test_title"),
                        Instant.ofEpochMilli(rs.getLong("finished_at")), rs.getInt("score_percent"),
                        rs.getBoolean("passed"), rs.getInt("right_answers"), rs.getInt("questions_count"),
                        objectMapper.readValue(rs.getString("questions_json"), new TypeReference<List<Question>>() { }),
                        objectMapper.readValue(rs.getString("answers_json"), new TypeReference<List<Set<Integer>>>() { }));
            } catch (Exception exception) {
                throw new IllegalStateException("Не удалось прочитать разбор попытки", exception);
            }
        }, id, listenerId);
    }

    public void insert(String id, AttemptForAppeal attempt, long listenerId, AppealRequest request, long now) {
        jdbc.update("""
                INSERT INTO attestation.appeal (
                    id, attempt_id, listener_id, question_reference, example_description,
                    interpretation, legal_reference, attachment_name, attachment_type,
                    attachment_base64, status, created_at, original_score
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'SUBMITTED', ?, ?)
                """, id, attempt.id(), listenerId, questionReference(request.questionIndexes()), request.exampleDescription(),
                request.interpretation(), request.legalReference(), request.attachmentName(),
                request.attachmentType(), request.attachmentBase64(), now, attempt.score());
    }

    public List<AppealView> forMentor(String username) {
        return jdbc.query(baseSelect() + """
                WHERE author.username = ?
                ORDER BY appeal.created_at DESC
                """, this::view, username);
    }

    public AppealOwner owner(String id, String mentorUsername) {
        return jdbc.query(baseSelect() + " WHERE appeal.id = ? AND author.username = ?",
                rs -> rs.next() ? new AppealOwner(rs.getString("id"), rs.getString("attempt_id"),
                        rs.getString("status")) : null, id, mentorUsername);
    }

    public void resolve(String id, String status, long mentorId, long now, String explanation, Integer score) {
        jdbc.update("""
                UPDATE attestation.appeal
                SET status = ?, resolved_by = ?, resolved_at = ?, resolution = ?, changed_score = ?
                WHERE id = ? AND status = 'SUBMITTED'
                """, status, mentorId, now, explanation, score, id);
    }

    public void changeScore(String attemptId, int score) {
        jdbc.update("""
                UPDATE attestation.attestation_attempt
                SET score_percent = ?, passed = ?
                WHERE id = ?
                """, score, score >= 80, attemptId);
    }

    private String baseSelect() {
        return """
                SELECT appeal.*, attempt.test_title, listener.firstname, listener.lastname
                FROM attestation.appeal appeal
                JOIN attestation.attestation_attempt attempt ON attempt.id = appeal.attempt_id
                JOIN public.mdl_user listener ON listener.id = appeal.listener_id
                JOIN public.mdl_quiz quiz ON quiz.idnumber = attempt.test_code
                JOIN public.mdl_user author ON author.id = quiz.created_by
                """;
    }

    private AppealView view(ResultSet rs, int row) throws SQLException {
        var resolved = (Long) rs.getObject("resolved_at");
        return new AppealView(rs.getString("id"), rs.getString("attempt_id"),
                rs.getString("lastname") + " " + rs.getString("firstname"), rs.getString("test_title"),
                rs.getString("question_reference"), rs.getString("example_description"),
                rs.getString("interpretation"), rs.getString("legal_reference"),
                rs.getString("attachment_name"), rs.getString("attachment_type"),
                rs.getString("attachment_base64"), rs.getString("status"),
                Instant.ofEpochMilli(rs.getLong("created_at")),
                resolved == null ? null : Instant.ofEpochMilli(resolved), rs.getString("resolution"),
                rs.getInt("original_score"), (Integer) rs.getObject("changed_score"));
    }

    public record AttemptForAppeal(String id, String testCode, String testTitle,
                                   Instant finishedAt, int score, boolean passed) { }
    public record AppealOwner(String id, String attemptId, String status) { }

    private String questionReference(List<Integer> indexes) {
        return indexes.stream().sorted().map(index -> "Вопрос " + (index + 1))
                .collect(java.util.stream.Collectors.joining(", "));
    }
}
