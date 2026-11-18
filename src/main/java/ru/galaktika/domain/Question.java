package ru.galaktika.domain;

import java.util.List;

public record Question(String text, List<Answer> answers, Difficulty difficulty, ChoiceType choiceType) {
}
