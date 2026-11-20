package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Profile("!console")
@RequiredArgsConstructor
public class AttemptConnectionMonitor {

    private final AttemptService attemptService;

    @Scheduled(fixedDelay = 5000, initialDelay = 10000)
    public void pauseStaleAttempts() {
        attemptService.pauseStaleAttempts();
    }
}
