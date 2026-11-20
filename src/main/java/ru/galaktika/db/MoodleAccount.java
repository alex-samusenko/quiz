package ru.galaktika.db;

public record MoodleAccount(
        long id,
        String username,
        String passwordHash,
        String firstName,
        String lastName,
        String role,
        String timezone) {
}
