package ru.galaktika.dao;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import ru.galaktika.domain.ChoiceType;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class TestCatalogTest {

    @Autowired
    private TestCatalog catalog;

    @Test
    void readsMentorFromTheFirstLineOfEachTestFile() {
        var javaTest = catalog.find("java").orElseThrow();

        assertThat(javaTest.mentor()).isEqualTo("mentor");
        assertThat(javaTest.title()).isEqualTo("Основы Java");
        assertThat(catalog.questions(javaTest)).hasSize(5);
        assertThat(catalog.questions(javaTest)).anyMatch(question -> question.choiceType() == ChoiceType.MULTIPLE);
        assertThat(catalog.find("galaxy").orElseThrow().mentor()).isEqualTo("petrov");
        assertThat(catalog.findAll()).extracting(test -> test.mentor()).contains("mentor", "petrov");

        var realMoodleTopic = catalog.find("erp-autonomous-forms").orElseThrow();
        assertThat(realMoodleTopic.title()).isEqualTo("ERP: Автономные формы");
        assertThat(catalog.questions(realMoodleTopic)).hasSize(8)
                .allMatch(question -> question.answers().size() == 3)
                .allMatch(question -> question.choiceType() == ChoiceType.SINGLE);
    }
}
