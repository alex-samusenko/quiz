package ru.galaktika.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import java.util.Locale;

@ConfigurationProperties(prefix = "test")
public class AppProperties implements TestConfig, TestFileNameProvider {

    private int passingScore;

    private int timeLimitSeconds;

    private int questionCount = 20;

    private boolean shuffleQuestions = true;

    private boolean shuffleAnswers = true;

    private int heartbeatTimeoutSeconds = 15;

    private Locale locale;

    @Override
    public int getPassingScore() {
        return passingScore;
    }

    public void setPassingScore(int passingScore) {
        this.passingScore = passingScore;
    }

    @Override
    public int getTimeLimitSeconds() {
        return timeLimitSeconds;
    }

    public void setTimeLimitSeconds(int timeLimitSeconds) {
        this.timeLimitSeconds = timeLimitSeconds;
    }

    @Override
    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    @Override
    public boolean isShuffleQuestions() {
        return shuffleQuestions;
    }

    public void setShuffleQuestions(boolean shuffleQuestions) {
        this.shuffleQuestions = shuffleQuestions;
    }

    @Override
    public boolean isShuffleAnswers() {
        return shuffleAnswers;
    }

    public void setShuffleAnswers(boolean shuffleAnswers) {
        this.shuffleAnswers = shuffleAnswers;
    }

    @Override
    public int getHeartbeatTimeoutSeconds() {
        return heartbeatTimeoutSeconds;
    }

    public void setHeartbeatTimeoutSeconds(int heartbeatTimeoutSeconds) {
        this.heartbeatTimeoutSeconds = heartbeatTimeoutSeconds;
    }

    @Override
    public Locale getLocale() {
        return locale;
    }

    public void setLocale(String locale) {
        this.locale = Locale.forLanguageTag(locale);
    }

    @Override
    public String getTestFileName() {
        return String.format("questions_%s.csv", locale.toLanguageTag());
    }
}
