package ru.galaktika.db;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import ru.galaktika.web.dto.ListenerView;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

@Repository
@Profile("!console")
@RequiredArgsConstructor
public class MoodleUserRepository {

    private static final String ACTIVE_BY_USERNAME = """
            SELECT id, username, password, firstname, lastname, role, timezone
            FROM public.mdl_user
            WHERE username = ? AND mnethostid = 1
              AND deleted = 0 AND suspended = 0 AND confirmed = 1
            """;

    private static final String LISTENERS = """
            SELECT username, firstname, lastname, email, institution, department
            FROM public.mdl_user
            WHERE role = 'user' AND deleted = 0 AND suspended = 0 AND confirmed = 1 AND mnethostid = 1
            ORDER BY lastname, firstname, username
            """;

    private static final String SEARCH_LISTENERS = """
            SELECT username, firstname, lastname, email, institution, department
            FROM public.mdl_user
            WHERE role = 'user' AND deleted = 0 AND suspended = 0 AND confirmed = 1 AND mnethostid = 1
              AND (LOWER(firstname) LIKE ? OR LOWER(lastname) LIKE ?
                OR LOWER(username) LIKE ? OR LOWER(email) LIKE ?
                OR LOWER(CONCAT(firstname, ' ', lastname)) LIKE ?
                OR LOWER(CONCAT(lastname, ' ', firstname)) LIKE ?)
            ORDER BY lastname, firstname, username
            LIMIT 20
            """;

    private final JdbcTemplate jdbc;

    public Optional<MoodleAccount> findActive(String username) {
        var found = jdbc.query(ACTIVE_BY_USERNAME, (rs, row) -> toAccount(rs), username);
        if (found.isEmpty()) {
            return Optional.empty();
        }
        return Optional.of(found.get(0));
    }

    public List<ListenerView> findListeners() {
        return jdbc.query(LISTENERS, (rs, row) -> toListener(rs));
    }

    public List<ListenerView> searchListeners(String query) {
        var prefix = query.trim().toLowerCase() + "%";
        return jdbc.query(SEARCH_LISTENERS, (rs, row) -> toListener(rs),
                prefix, prefix, prefix, prefix, prefix, prefix);
    }

    private MoodleAccount toAccount(ResultSet rs) throws SQLException {
        return new MoodleAccount(rs.getLong("id"), rs.getString("username"), rs.getString("password"),
                rs.getString("firstname"), rs.getString("lastname"), rs.getString("role"),
                rs.getString("timezone"));
    }

    private ListenerView toListener(ResultSet rs) throws SQLException {
        return new ListenerView(rs.getString("username"), rs.getString("firstname"), rs.getString("lastname"),
                rs.getString("email"), rs.getString("institution"), rs.getString("department"));
    }
}
