package ru.galaktika.web.dto;

public record MentorTestView(String code, String title, int passedCount, int failedCount) {
}
