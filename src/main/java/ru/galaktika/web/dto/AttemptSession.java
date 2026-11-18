package ru.galaktika.web.dto;

import java.util.List;

public record AttemptSession(
        String id,
        String testTitle,
        int timeLimitSeconds,
        int remainingSeconds,
        int passingScore,
        List<QuestionView> questions,
        List<List<Integer>> selected) {
}
