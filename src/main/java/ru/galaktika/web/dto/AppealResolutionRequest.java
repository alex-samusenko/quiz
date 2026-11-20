package ru.galaktika.web.dto;

public record AppealResolutionRequest(String decision, Integer score, String explanation) {
}
