package ru.galaktika.integration;

public record MoodleBankView(String code, String name, String courseName, int courseModuleId,
                             int contextId, int questions, int automaticQuestions,
                             int easy, int medium, int hard) { }
