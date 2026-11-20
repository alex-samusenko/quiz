package ru.galaktika.web;

import org.junit.jupiter.api.Test;
import ru.galaktika.domain.Answer;
import ru.galaktika.domain.AttestationLevel;
import ru.galaktika.domain.ChoiceType;
import ru.galaktika.domain.Difficulty;
import ru.galaktika.domain.Question;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AttemptQuestionSelectorTest {

    private final AttemptQuestionSelector selector = new AttemptQuestionSelector();

    @Test
    void buildsSpecialistAttemptWithFourteenEasyAndSixMediumQuestions() {
        var selected = selector.select(bank(20, 10, 0), AttestationLevel.SPECIALIST,
                20, false, false);

        assertThat(selected).hasSize(20);
        assertThat(selected).filteredOn(question -> question.difficulty() == Difficulty.EASY).hasSize(14);
        assertThat(selected).filteredOn(question -> question.difficulty() == Difficulty.MEDIUM).hasSize(6);
        assertThat(selected).extracting(Question::topic).contains("Тема 1", "Тема 2");
    }

    @Test
    void buildsExpertAttemptWithFourteenMediumAndSixHardQuestions() {
        var selected = selector.select(bank(0, 20, 10), AttestationLevel.EXPERT,
                20, false, false);

        assertThat(selected).filteredOn(question -> question.difficulty() == Difficulty.MEDIUM).hasSize(14);
        assertThat(selected).filteredOn(question -> question.difficulty() == Difficulty.HARD).hasSize(6);
    }

    @Test
    void rejectsAttemptWhenRequiredDifficultyIsMissing() {
        assertThatThrownBy(() -> selector.select(bank(14, 5, 0), AttestationLevel.SPECIALIST,
                20, false, false))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("требуется 6, доступно 5");
    }

    private List<Question> bank(int easy, int medium, int hard) {
        var questions = new ArrayList<Question>();
        add(questions, Difficulty.EASY, easy);
        add(questions, Difficulty.MEDIUM, medium);
        add(questions, Difficulty.HARD, hard);
        return questions;
    }

    private void add(List<Question> questions, Difficulty difficulty, int count) {
        for (var index = 0; index < count; index++) {
            var topic = index % 3 == 0 ? "Тема 1" : "Тема 2";
            questions.add(new Question(difficulty + " " + index,
                    List.of(new Answer("Да", true), new Answer("Нет", false)),
                    difficulty, ChoiceType.SINGLE, topic));
        }
    }
}
