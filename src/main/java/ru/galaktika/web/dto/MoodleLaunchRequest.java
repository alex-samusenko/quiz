package ru.galaktika.web.dto;

public record MoodleLaunchRequest(String username, long issuedAt, String nonce, String signature) {
}
