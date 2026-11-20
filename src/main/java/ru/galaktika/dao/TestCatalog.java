package ru.galaktika.dao;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import ru.galaktika.domain.Answer;
import ru.galaktika.domain.AttestationLevel;
import ru.galaktika.domain.AttestationTest;
import ru.galaktika.domain.ChoiceType;
import ru.galaktika.domain.Difficulty;
import ru.galaktika.domain.Question;
import ru.galaktika.integration.MoodleApiClient;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class TestCatalog {

    private final JdbcTemplate jdbc;

    private final MoodleApiClient moodleApiClient;

    public List<AttestationTest> findAll() {
        var result = new ArrayList<AttestationTest>();
        result.addAll(findLocalTests());
        result.addAll(moodleApiClient.tests());
        return List.copyOf(result);
    }

    private List<AttestationTest> findLocalTests() {
        var sql = """
                SELECT quiz.idnumber, quiz.name, COALESCE(author.username, ''), quiz.attestation_level
                FROM mdl_quiz quiz
                LEFT JOIN mdl_user author ON author.id = quiz.created_by
                WHERE quiz.visible = TRUE
                ORDER BY quiz.name, quiz.id
                """;
        return jdbc.query(sql, (row, index) -> toTest(row));
    }

    public Optional<AttestationTest> find(String code) {
        if (moodleApiClient.isBankCode(code)) return moodleApiClient.findTest(code);
        return findLocalTests().stream().filter(test -> test.code().equals(code)).findFirst();
    }

    public Optional<AttestationTest> findAny(String code) {
        if (moodleApiClient.isBankCode(code)) return moodleApiClient.findTest(code);
        var sql = """
                SELECT quiz.idnumber, quiz.name, COALESCE(author.username, ''), quiz.attestation_level
                FROM mdl_quiz quiz
                LEFT JOIN mdl_user author ON author.id = quiz.created_by
                WHERE quiz.idnumber = ?
                """;
        return jdbc.query(sql, (row, index) -> toTest(row), code)
                .stream().findFirst();
    }

    public List<Question> questions(AttestationTest test) {
        if (moodleApiClient.isBankCode(test.code())) return moodleApiClient.questions(test);
        var sql = """
                SELECT question.id, question.name, question.questiontext, question.defaultmark,
                       question.single_answer, category.name AS topic,
                       answer.answer, answer.fraction
                FROM mdl_quiz quiz
                JOIN mdl_quiz_slots slot ON slot.quizid = quiz.id
                JOIN mdl_question question ON question.id = slot.questionid
                JOIN mdl_question_categories category ON category.id = question.category
                JOIN mdl_question_answers answer ON answer.question = question.id
                WHERE quiz.idnumber = ? AND quiz.visible = TRUE AND question.status = 'ready'
                ORDER BY slot.slot, answer.answer_order, answer.id
                """;
        var grouped = new LinkedHashMap<Long, QuestionBuilder>();
        jdbc.query(sql, row -> {
            var questionId = row.getLong("id");
            var name = row.getString("name");
            var text = row.getString("questiontext");
            var difficulty = difficulty(row.getInt("defaultmark"));
            if (difficulty == null || !nameMatches(name, difficulty)) {
                return;
            }
            var choiceType = row.getBoolean("single_answer") ? ChoiceType.SINGLE : ChoiceType.MULTIPLE;
            var topic = topic(name, row.getString("topic"));
            var builder = grouped.computeIfAbsent(questionId, ignored -> new QuestionBuilder(
                    text, difficulty, choiceType, topic));
            builder.answers.add(new Answer(row.getString("answer"), row.getBigDecimal("fraction").signum() > 0));
        }, test.code());
        return grouped.values().stream().map(QuestionBuilder::build).toList();
    }

    public int sharedQuestionCount(AttestationTest test) {
        if (moodleApiClient.isBankCode(test.code())) return 0;
        var sql = """
                SELECT COUNT(DISTINCT own.questionid)
                FROM mdl_quiz quiz
                JOIN mdl_quiz_slots own ON own.quizid = quiz.id
                WHERE quiz.idnumber = ?
                  AND EXISTS (
                    SELECT 1
                    FROM mdl_quiz_slots other
                    JOIN mdl_quiz other_quiz ON other_quiz.id = other.quizid
                    WHERE other.questionid = own.questionid
                      AND other.quizid <> own.quizid
                      AND other_quiz.visible = TRUE
                  )
                """;
        return jdbc.queryForObject(sql, Integer.class, test.code());
    }

    private AttestationTest toTest(java.sql.ResultSet row) throws java.sql.SQLException {
        return new AttestationTest(row.getString(1), row.getString(2), row.getString(3),
                row.getString(1), AttestationLevel.valueOf(row.getString(4)));
    }

    private Difficulty difficulty(int defaultMark) {
        return switch (defaultMark) {
            case 10 -> Difficulty.EASY;
            case 20 -> Difficulty.MEDIUM;
            case 40 -> Difficulty.HARD;
            default -> null;
        };
    }

    private boolean nameMatches(String name, Difficulty difficulty) {
        if (name == null) {
            return false;
        }
        var normalized = name.toLowerCase(java.util.Locale.ROOT).replace('ё', 'е');
        var marker = switch (difficulty) {
            case EASY -> "легкий";
            case MEDIUM -> "средний";
            case HARD -> "сложный";
        };
        return normalized.contains(marker);
    }

    private String topic(String name, String fallback) {
        var matcher = java.util.regex.Pattern.compile("(?iu)раздел\\s*:\\s*([^,.;]+)").matcher(name);
        return matcher.find() ? matcher.group(1).trim() : fallback;
    }

    private static final class QuestionBuilder {

        private final String text;

        private final Difficulty difficulty;

        private final ChoiceType choiceType;

        private final String topic;

        private final List<Answer> answers = new ArrayList<>();

        private QuestionBuilder(String text, Difficulty difficulty, ChoiceType choiceType, String topic) {
            this.text = text;
            this.difficulty = difficulty;
            this.choiceType = choiceType;
            this.topic = topic;
        }

        private Question build() {
            return new Question(text, List.copyOf(answers), difficulty, choiceType, topic);
        }
    }
}
