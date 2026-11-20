package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.galaktika.web.dto.AttemptResultView;
import ru.galaktika.web.dto.AttemptReviewView;
import ru.galaktika.web.dto.AttemptSession;
import ru.galaktika.web.dto.AttemptStateView;
import ru.galaktika.web.dto.SaveAnswerRequest;
import ru.galaktika.web.dto.StartAttemptRequest;

@RestController
@RequestMapping("/api/attempts")
@Profile("!console")
@RequiredArgsConstructor
public class AttemptController {

    private final AttemptService attemptService;

    @PostMapping
    public AttemptSession start(@RequestBody StartAttemptRequest request) {
        return attemptService.start(request.assignmentId());
    }

    @GetMapping("/{id}")
    public AttemptSession read(@PathVariable("id") String id) {
        return attemptService.read(id);
    }

    @PostMapping("/{id}/heartbeat")
    public AttemptStateView heartbeat(@PathVariable("id") String id) {
        return attemptService.heartbeat(id);
    }

    @PutMapping("/{id}/answers")
    public void saveAnswer(@PathVariable("id") String id, @RequestBody SaveAnswerRequest request) {
        attemptService.saveAnswer(id, request.questionIndex(), request.selected());
    }

    @PostMapping("/{id}/finish")
    public AttemptResultView finish(@PathVariable("id") String id) {
        return attemptService.finish(id);
    }

    @GetMapping("/{id}/review")
    public AttemptReviewView review(@PathVariable("id") String id) {
        return attemptService.review(id);
    }

    @GetMapping("/{id}/mentor-review")
    public AttemptReviewView mentorReview(@PathVariable("id") String id) {
        return attemptService.mentorReview(id);
    }

    @PutMapping("/{id}/mentor-answers")
    public AttemptReviewView updateByMentor(@PathVariable("id") String id,
                                             @RequestBody SaveAnswerRequest request) {
        return attemptService.updateByMentor(id, request.questionIndex(), request.selected());
    }
}
