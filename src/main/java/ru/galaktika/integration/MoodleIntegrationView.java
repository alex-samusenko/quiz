package ru.galaktika.integration;

import java.util.List;

public record MoodleIntegrationView(boolean enabled, String status, String release,
                                    List<MoodleBankView> banks) { }
