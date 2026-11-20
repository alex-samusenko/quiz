package ru.galaktika.web.dto;

import java.time.Instant;
import java.util.List;

public record AttemptReviewView(
        String testTitle,
        Instant finishedAt,
        Instant reviewUntil,
        int scorePercent,
        boolean passed,
        int rightAnswersCount,
        int questionsCount,
        List<QuestionView> questions,
        List<ReviewedAnswerView> answers) {
}
