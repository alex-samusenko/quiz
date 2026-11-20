package ru.galaktika.db;

import ru.galaktika.domain.Question;

import java.time.Instant;
import java.util.List;
import java.util.Set;

public record FinishedAttemptReview(
        String id,
        String testTitle,
        Instant finishedAt,
        int scorePercent,
        boolean passed,
        int rightAnswers,
        int questionsCount,
        List<Question> questions,
        List<Set<Integer>> answers) {
}
