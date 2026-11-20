package ru.galaktika.web;

import org.springframework.stereotype.Component;
import ru.galaktika.domain.AttestationLevel;
import ru.galaktika.domain.Difficulty;
import ru.galaktika.domain.Question;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;

@Component
public class AttemptQuestionSelector {

    public List<Question> select(List<Question> source, AttestationLevel level, int count,
                                 boolean shuffleQuestions, boolean shuffleAnswers) {
        var primaryCount = Math.round(count * 0.7f);
        var secondaryCount = count - primaryCount;
        var primary = level == AttestationLevel.SPECIALIST ? Difficulty.EASY : Difficulty.MEDIUM;
        var secondary = level == AttestationLevel.SPECIALIST ? Difficulty.MEDIUM : Difficulty.HARD;

        var selected = new ArrayList<Question>();
        selected.addAll(selectByTopic(source, primary, primaryCount));
        selected.addAll(selectByTopic(source, secondary, secondaryCount));
        if (shuffleQuestions) {
            Collections.shuffle(selected);
        }
        return selected.stream().map(question -> copy(question, shuffleAnswers)).toList();
    }

    private List<Question> selectByTopic(List<Question> source, Difficulty difficulty, int required) {
        var candidates = source.stream().filter(question -> question.difficulty() == difficulty).toList();
        if (candidates.size() < required) {
            throw new IllegalArgumentException("Недостаточно вопросов сложности «"
                    + title(difficulty) + "»: требуется " + required + ", доступно " + candidates.size());
        }

        var grouped = new LinkedHashMap<String, List<Question>>();
        for (var question : candidates) {
            grouped.computeIfAbsent(question.topic(), ignored -> new ArrayList<>()).add(question);
        }
        for (var questions : grouped.values()) {
            Collections.shuffle(questions);
        }

        var buckets = grouped.entrySet().stream()
                .map(entry -> new Bucket(entry.getValue(), required * entry.getValue().size()
                        / (double) candidates.size()))
                .toList();
        var allocated = 0;
        for (var bucket : buckets) {
            bucket.selected = Math.min(bucket.questions.size(), (int) Math.floor(bucket.target));
            allocated += bucket.selected;
        }
        while (allocated < required) {
            var next = buckets.stream()
                    .filter(bucket -> bucket.selected < bucket.questions.size())
                    .max((left, right) -> Double.compare(left.target - left.selected,
                            right.target - right.selected))
                    .orElseThrow();
            next.selected++;
            allocated++;
        }

        var result = new ArrayList<Question>();
        for (var bucket : buckets) {
            result.addAll(bucket.questions.subList(0, bucket.selected));
        }
        return result;
    }

    private Question copy(Question question, boolean shuffleAnswers) {
        var answers = new ArrayList<>(question.answers());
        if (shuffleAnswers) {
            Collections.shuffle(answers);
        }
        return new Question(question.text(), List.copyOf(answers), question.difficulty(),
                question.choiceType(), question.topic());
    }

    private String title(Difficulty difficulty) {
        return switch (difficulty) {
            case EASY -> "лёгкие";
            case MEDIUM -> "средние";
            case HARD -> "сложные";
        };
    }

    private static final class Bucket {

        private final List<Question> questions;

        private final double target;

        private int selected;

        private Bucket(List<Question> questions, double target) {
            this.questions = questions;
            this.target = target;
        }
    }
}
