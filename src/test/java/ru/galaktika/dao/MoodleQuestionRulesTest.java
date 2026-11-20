package ru.galaktika.dao;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import ru.galaktika.domain.Difficulty;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class MoodleQuestionRulesTest {

    @Autowired
    private TestCatalog catalog;

    @Test
    void readsReadyQuestionsWithMatchingTitleAndDefaultMark() {
        var test = catalog.find("erp-reports-certification").orElseThrow();
        var questions = catalog.questions(test);

        assertThat(questions).hasSizeGreaterThanOrEqualTo(20);
        assertThat(questions).filteredOn(question -> question.difficulty() == Difficulty.EASY)
                .hasSizeGreaterThanOrEqualTo(14);
        assertThat(questions).filteredOn(question -> question.difficulty() == Difficulty.MEDIUM)
                .hasSizeGreaterThanOrEqualTo(6);
        assertThat(questions).allMatch(question -> !question.topic().isBlank());
        assertThat(catalog.sharedQuestionCount(test)).isZero();
    }
}
