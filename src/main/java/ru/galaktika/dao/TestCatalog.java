package ru.galaktika.dao;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import ru.galaktika.domain.Answer;
import ru.galaktika.domain.AttestationTest;
import ru.galaktika.domain.ChoiceType;
import ru.galaktika.domain.Difficulty;
import ru.galaktika.domain.Question;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class TestCatalog {

    private final JdbcTemplate jdbc;

    public List<AttestationTest> findAll() {
        var sql = """
                SELECT quiz.idnumber, quiz.name, COALESCE(author.username, '')
                FROM mdl_quiz quiz
                LEFT JOIN mdl_user author ON author.id = quiz.created_by
                WHERE quiz.visible = TRUE
                ORDER BY quiz.name, quiz.id
                """;
        return jdbc.query(sql, (row, index) -> new AttestationTest(
                row.getString(1), row.getString(2), row.getString(3), row.getString(1)));
    }

    public Optional<AttestationTest> find(String code) {
        return findAll().stream().filter(test -> test.code().equals(code)).findFirst();
    }

    public Optional<AttestationTest> findAny(String code) {
        var sql = """
                SELECT quiz.idnumber, quiz.name, COALESCE(author.username, '')
                FROM mdl_quiz quiz
                LEFT JOIN mdl_user author ON author.id = quiz.created_by
                WHERE quiz.idnumber = ?
                """;
        return jdbc.query(sql, (row, index) -> new AttestationTest(
                row.getString(1), row.getString(2), row.getString(3), row.getString(1)), code)
                .stream().findFirst();
    }

    public List<Question> questions(AttestationTest test) {
        var sql = """
                SELECT question.id, question.questiontext, question.difficulty,
                       question.single_answer, answer.answer, answer.fraction
                FROM mdl_quiz quiz
                JOIN mdl_quiz_slots slot ON slot.quizid = quiz.id
                JOIN mdl_question question ON question.id = slot.questionid
                JOIN mdl_question_answers answer ON answer.question = question.id
                WHERE quiz.idnumber = ? AND quiz.visible = TRUE AND question.status = 'ready'
                ORDER BY slot.slot, answer.answer_order, answer.id
                """;
        var grouped = new LinkedHashMap<Long, QuestionBuilder>();
        jdbc.query(sql, row -> {
            var questionId = row.getLong("id");
            var text = row.getString("questiontext");
            var difficulty = Difficulty.valueOf(row.getString("difficulty"));
            var choiceType = row.getBoolean("single_answer") ? ChoiceType.SINGLE : ChoiceType.MULTIPLE;
            var builder = grouped.computeIfAbsent(questionId, ignored -> new QuestionBuilder(
                    text, difficulty, choiceType));
            builder.answers.add(new Answer(row.getString("answer"), row.getBigDecimal("fraction").signum() > 0));
        }, test.code());
        return grouped.values().stream().map(QuestionBuilder::build).toList();
    }

    private static final class QuestionBuilder {

        private final String text;

        private final Difficulty difficulty;

        private final ChoiceType choiceType;

        private final List<Answer> answers = new ArrayList<>();

        private QuestionBuilder(String text, Difficulty difficulty, ChoiceType choiceType) {
            this.text = text;
            this.difficulty = difficulty;
            this.choiceType = choiceType;
        }

        private Question build() {
            return new Question(text, List.copyOf(answers), difficulty, choiceType);
        }
    }
}
