package ru.galaktika.db;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import ru.galaktika.domain.AttestationLevel;

@Repository
@Profile("!console")
@RequiredArgsConstructor
public class AssignmentRepository {

    private static final String INSERT = """
            INSERT INTO attestation.test_assignment (
                id, listener_id, test_code, attestation_level, assigned_by, assigned_at,
                starts_at, ends_at, access_from, access_until
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

    private static final String BY_ID = """
            SELECT id, listener_id, test_code, COALESCE(attestation_level, 'SPECIALIST') attestation_level,
                   COALESCE(starts_at, assigned_at) starts_at,
                   COALESCE(ends_at, assigned_at + 31536000000) ends_at,
                   COALESCE(access_from, assigned_at) access_from,
                   COALESCE(access_until, assigned_at + 31536000000) access_until,
                   cancelled_at
            FROM attestation.test_assignment
            WHERE id = ?
            """;

    private static final String OPEN = """
            SELECT id, listener_id, test_code, COALESCE(attestation_level, 'SPECIALIST') attestation_level,
                   COALESCE(starts_at, assigned_at) starts_at,
                   COALESCE(ends_at, assigned_at + 31536000000) ends_at,
                   COALESCE(access_from, assigned_at) access_from,
                   COALESCE(access_until, assigned_at + 31536000000) access_until,
                   cancelled_at
            FROM attestation.test_assignment assignment
            WHERE listener_id = ?
              AND cancelled_at IS NULL
              AND (
                  COALESCE(ends_at, assigned_at + 31536000000) >= ?
                  OR EXISTS (
                      SELECT 1 FROM attestation.attestation_attempt active_attempt
                      WHERE active_attempt.assignment_id = assignment.id
                        AND active_attempt.finished_at IS NULL
                  )
              )
              AND NOT EXISTS (
                  SELECT 1 FROM attestation.attestation_attempt attempt
                  WHERE attempt.assignment_id = assignment.id AND attempt.finished_at IS NOT NULL
              )
            ORDER BY assigned_at
            """;

    private static final String ALL = """
            SELECT assignment.id, assignment.test_code,
                   COALESCE(assignment.attestation_level, 'SPECIALIST') attestation_level,
                   assignment.assigned_at,
                   COALESCE(assignment.starts_at, assignment.assigned_at) starts_at,
                   COALESCE(assignment.ends_at, assignment.assigned_at + 31536000000) ends_at,
                   COALESCE(assignment.access_from, assignment.assigned_at) access_from,
                   COALESCE(assignment.access_until, assignment.assigned_at + 31536000000) access_until,
                   moodle_user.firstname, moodle_user.lastname,
                   EXISTS (
                       SELECT 1 FROM attestation.attestation_attempt attempt
                       WHERE attempt.assignment_id = assignment.id AND attempt.finished_at IS NOT NULL
                   ) AS finished,
                   EXISTS (
                       SELECT 1 FROM attestation.attestation_attempt attempt
                       WHERE attempt.assignment_id = assignment.id AND attempt.finished_at IS NULL
                   ) AS active,
                   assignment.cancelled_at IS NOT NULL AS cancelled
            FROM attestation.test_assignment assignment
            JOIN public.mdl_user moodle_user ON moodle_user.id = assignment.listener_id
            ORDER BY assignment.assigned_at DESC
            """;

    private final JdbcTemplate jdbc;

    public void insert(String id, long listenerId, String testCode, AttestationLevel level,
                       long assignedBy, long assignedAt,
                       long startsAt, long endsAt, long accessFrom, long accessUntil) {
        jdbc.update(INSERT, id, listenerId, testCode, level.name(), assignedBy, assignedAt,
                startsAt, endsAt, accessFrom, accessUntil);
    }

    public Optional<AssignmentRow> findById(String id) {
        var found = jdbc.query(BY_ID, (rs, row) -> toRow(rs), id);
        if (found.isEmpty()) {
            return Optional.empty();
        }
        return Optional.of(found.get(0));
    }

    public List<AssignmentRow> findOpen(long listenerId, long now) {
        return jdbc.query(OPEN, (rs, row) -> toRow(rs), listenerId, now);
    }

    public List<AssignmentListRow> listAll() {
        return jdbc.query(ALL, (rs, row) -> toListRow(rs));
    }

    public void cancel(String id, long managerId, long cancelledAt) {
        jdbc.update("""
                UPDATE attestation.test_assignment
                SET cancelled_at = ?, cancelled_by = ?
                WHERE id = ? AND cancelled_at IS NULL
                """, cancelledAt, managerId, id);
    }

    public Long lastFailedAt(long listenerId, String testCode) {
        return jdbc.query("""
                SELECT MAX(finished_at)
                FROM attestation.attestation_attempt
                WHERE listener_id = ? AND test_code = ? AND finished_at IS NOT NULL AND passed = FALSE
                """, rs -> rs.next() ? (Long) rs.getObject(1) : null, listenerId, testCode);
    }

    public boolean hasOverlapping(long listenerId, String testCode, AttestationLevel level,
                                  long startsAt, long endsAt) {
        var count = jdbc.queryForObject("""
                SELECT COUNT(*)
                FROM attestation.test_assignment assignment
                WHERE assignment.listener_id = ?
                  AND assignment.test_code = ?
                  AND COALESCE(assignment.attestation_level, 'SPECIALIST') = ?
                  AND assignment.cancelled_at IS NULL
                  AND COALESCE(assignment.starts_at, assignment.assigned_at) < ?
                  AND COALESCE(assignment.ends_at, assignment.assigned_at + 31536000000) > ?
                  AND NOT EXISTS (
                      SELECT 1 FROM attestation.attestation_attempt attempt
                      WHERE attempt.assignment_id = assignment.id
                        AND attempt.finished_at IS NOT NULL
                  )
                """, Integer.class, listenerId, testCode, level.name(), endsAt, startsAt);
        return count != null && count > 0;
    }

    private AssignmentRow toRow(ResultSet rs) throws SQLException {
        return new AssignmentRow(rs.getString("id"), rs.getLong("listener_id"), rs.getString("test_code"),
                AttestationLevel.valueOf(rs.getString("attestation_level")),
                rs.getLong("starts_at"), rs.getLong("ends_at"), rs.getLong("access_from"),
                rs.getLong("access_until"), (Long) rs.getObject("cancelled_at"));
    }

    private AssignmentListRow toListRow(ResultSet rs) throws SQLException {
        var name = rs.getString("lastname") + " " + rs.getString("firstname");
        return new AssignmentListRow(rs.getString("id"), rs.getString("test_code"),
                AttestationLevel.valueOf(rs.getString("attestation_level")), rs.getLong("assigned_at"),
                rs.getLong("starts_at"), rs.getLong("ends_at"), rs.getLong("access_from"),
                rs.getLong("access_until"), name, rs.getBoolean("finished"), rs.getBoolean("active"),
                rs.getBoolean("cancelled"));
    }
}
