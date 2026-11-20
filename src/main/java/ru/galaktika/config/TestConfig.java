package ru.galaktika.config;

import java.util.Locale;

public interface TestConfig {

    int getPassingScore();

    int getTimeLimitSeconds();

    int getQuestionCount();

    boolean isShuffleQuestions();

    boolean isShuffleAnswers();

    int getHeartbeatTimeoutSeconds();

    Locale getLocale();
}
