package ru.galaktika.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.galaktika.config.TestConfig;
import ru.galaktika.domain.TestResult;

@Service
@RequiredArgsConstructor
public class ResultServiceImpl implements ResultService {

    private final TestConfig testConfig;

    private final IOService ioService;

    private final LocalizedMessagesService messages;

    @Override
    public void showResult(TestResult testResult) {
        ioService.printLine("");
        ioService.printLine(messages.getMessage("result.title"));
        ioService.printLine(messages.getMessage("result.student", testResult.getStudent().getFullName()));
        ioService.printLine(messages.getMessage(
                "result.answered", testResult.getAnsweredQuestions().size()));
        ioService.printLine(messages.getMessage("result.right", testResult.getRightAnswersCount()));
        ioService.printLine(messages.getMessage("result.score", testResult.getScorePercent()));
        if (testResult.getScorePercent() >= testConfig.getPassingScore()) {
            ioService.printLine(messages.getMessage("result.passed"));
            return;
        }
        ioService.printLine(messages.getMessage("result.failed"));
    }
}
