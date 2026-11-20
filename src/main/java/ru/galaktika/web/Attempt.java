package ru.galaktika.web;

import ru.galaktika.domain.Question;
import ru.galaktika.domain.Student;
import ru.galaktika.web.dto.AttemptResultView;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.time.Duration;
import java.time.Instant;

public class Attempt {

    private final String id;

    private final Student student;

    private final List<Question> questions;

    private final AttemptMeta meta;

    private final List<Set<Integer>> selected;

    private AttemptResultView result;

    private Instant pausedAt;

    private long pausedSeconds;

    private Instant lastContactAt;

    public Attempt(String id, Student student, List<Question> questions, AttemptMeta meta) {
        this(id, student, questions, meta, null);
    }

    public Attempt(String id, Student student, List<Question> questions, AttemptMeta meta,
                   List<Set<Integer>> restoredAnswers) {
        this(id, student, questions, meta, restoredAnswers, null, 0, meta.startedAt());
    }

    public Attempt(String id, Student student, List<Question> questions, AttemptMeta meta,
                   List<Set<Integer>> restoredAnswers, Instant pausedAt, long pausedSeconds,
                   Instant lastContactAt) {
        this.id = id;
        this.student = student;
        this.questions = List.copyOf(questions);
        this.meta = meta;
        this.pausedAt = pausedAt;
        this.pausedSeconds = pausedSeconds;
        this.lastContactAt = lastContactAt;
        this.selected = new ArrayList<>();
        for (var i = 0; i < this.questions.size(); i++) {
            var restored = restoredAnswers != null && i < restoredAnswers.size()
                    ? restoredAnswers.get(i) : Set.<Integer>of();
            selected.add(Set.copyOf(restored));
        }
    }

    public String getId() {
        return id;
    }

    public Student getStudent() {
        return student;
    }

    public List<Question> getQuestions() {
        return questions;
    }

    public AttemptMeta getMeta() {
        return meta;
    }

    public List<Set<Integer>> getSelected() {
        return selected;
    }

    public AttemptResultView getResult() {
        return result;
    }

    public synchronized boolean isPaused() {
        return pausedAt != null;
    }

    public synchronized Instant getPausedAt() {
        return pausedAt;
    }

    public synchronized long getPausedSeconds() {
        return pausedSeconds;
    }

    public synchronized Instant getLastContactAt() {
        return lastContactAt;
    }

    public synchronized void touch(Instant now) {
        lastContactAt = now;
    }

    public synchronized void pause(Instant at) {
        if (pausedAt == null) {
            pausedAt = at;
        }
    }

    public synchronized void resume(Instant now) {
        if (pausedAt != null) {
            pausedSeconds += Math.max(0, Duration.between(pausedAt, now).toSeconds());
            pausedAt = null;
            lastContactAt = now;
        }
    }

    public synchronized long elapsedSeconds(Instant now) {
        var effectiveNow = pausedAt == null ? now : pausedAt;
        return Math.max(0, Duration.between(meta.startedAt(), effectiveNow).toSeconds() - pausedSeconds);
    }

    public synchronized void select(int index, Set<Integer> values) {
        selected.set(index, Set.copyOf(values));
    }

    public synchronized void complete(AttemptResultView graded) {
        this.result = graded;
    }
}
