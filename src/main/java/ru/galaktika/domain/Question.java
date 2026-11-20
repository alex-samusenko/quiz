package ru.galaktika.domain;

import java.util.List;

public record Question(String text, List<Answer> answers, Difficulty difficulty, ChoiceType choiceType,
                       String topic) {

    public Question(String text, List<Answer> answers, Difficulty difficulty, ChoiceType choiceType) {
        this(text, answers, difficulty, choiceType, "Без темы");
    }
}
