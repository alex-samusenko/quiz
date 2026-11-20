package ru.galaktika.web.dto;

import java.util.List;

public record ReviewedAnswerView(
        int index,
        String text,
        boolean correctAnswer,
        List<Integer> selected,
        List<Integer> correct) {
}
