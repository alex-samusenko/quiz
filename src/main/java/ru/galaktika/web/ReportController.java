package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;
import ru.galaktika.web.dto.AssignmentReportView;
import ru.galaktika.web.dto.AssignmentRequest;
import ru.galaktika.web.dto.AssignmentView;
import ru.galaktika.web.dto.ActiveAttemptView;
import ru.galaktika.web.dto.AttemptStateView;
import ru.galaktika.web.dto.AttemptReportView;
import ru.galaktika.web.dto.ListenerView;
import ru.galaktika.web.dto.MentorTestView;
import ru.galaktika.web.dto.TestOptionView;
import ru.galaktika.integration.MoodleApiClient;
import ru.galaktika.integration.MoodleIntegrationView;

import java.util.List;

@RestController
@Profile("!console")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    private final AssignmentService assignmentService;

    private final AttemptService attemptService;
    private final MoodleApiClient moodleApiClient;

    @PostMapping("/api/manager/assignments")
    public List<AssignmentView> createAssignment(@RequestBody AssignmentRequest request) {
        return assignmentService.create(request);
    }

    @PostMapping("/api/manager/assignments/{id}/cancel")
    public void cancelAssignment(@org.springframework.web.bind.annotation.PathVariable("id") String id) {
        assignmentService.cancel(id);
    }

    @GetMapping("/api/manager/assignments")
    public List<AssignmentReportView> assignments() {
        return assignmentService.all();
    }

    @GetMapping("/api/manager/active-attempts")
    public List<ActiveAttemptView> activeAttempts() {
        return attemptService.managerActive();
    }

    @PostMapping("/api/manager/attempts/{id}/resume")
    public AttemptStateView resumeAttempt(@org.springframework.web.bind.annotation.PathVariable("id") String id) {
        return attemptService.resume(id);
    }

    @GetMapping("/api/reports/attempts")
    public List<AttemptReportView> attempts() {
        return reportService.allAttempts();
    }

    @GetMapping("/api/my/attempts")
    public List<AttemptReportView> myAttempts() {
        return reportService.myAttempts();
    }

    @GetMapping("/api/mentor/tests")
    public List<MentorTestView> mentorTests() {
        return reportService.mentorTests();
    }

    @GetMapping("/api/mentor/attempts")
    public List<AttemptReportView> mentorAttempts() {
        return reportService.mentorAttempts();
    }

    @GetMapping("/api/listeners")
    public List<ListenerView> listeners() {
        return reportService.listeners();
    }

    @GetMapping("/api/manager/listeners/search")
    public List<ListenerView> searchListeners(@RequestParam("q") String query) {
        return reportService.searchListeners(query);
    }

    @GetMapping("/api/tests")
    public List<TestOptionView> tests() {
        return reportService.tests();
    }

    @GetMapping("/api/manager/moodle-integration")
    public MoodleIntegrationView moodleIntegration() {
        reportService.requireManager();
        return moodleApiClient.inspect();
    }
}
