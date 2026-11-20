package ru.galaktika.db;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ScriptUtils;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.SQLException;

@Component
@Profile("!console")
@Order(2)
@RequiredArgsConstructor
public class MoodleQuestionSeed implements ApplicationRunner {

    private final DataSource dataSource;

    @Override
    public void run(ApplicationArguments args) {
        try (var connection = dataSource.getConnection()) {
            ScriptUtils.executeSqlScript(connection, new ClassPathResource("db/moodle-question-seed.sql"));
            ScriptUtils.executeSqlScript(connection,
                    new ClassPathResource("db/moodle-erp-reports-certification.sql"));
            try (var statement = connection.createStatement()) {
                statement.executeUpdate("""
                        UPDATE mdl_question
                        SET defaultmark = CASE difficulty
                            WHEN 'EASY' THEN 10
                            WHEN 'MEDIUM' THEN 20
                            WHEN 'HARD' THEN 40
                        END
                        WHERE difficulty IN ('EASY', 'MEDIUM', 'HARD')
                        """);
            }
        } catch (SQLException ex) {
            throw new IllegalStateException("Не удалось заполнить демонстрационный банк вопросов", ex);
        }
    }
}
