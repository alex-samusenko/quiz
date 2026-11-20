package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import ru.galaktika.web.dto.AssignmentReportView;
import ru.galaktika.web.dto.AssignmentRequest;
import ru.galaktika.web.dto.AssignmentView;
import ru.galaktika.web.dto.OpenAssignmentView;

import java.util.List;

@RestController
@Profile("!console")
@RequiredArgsConstructor
public class AssignmentController {

    private final AssignmentService assignmentService;

    @PostMapping("/api/assignments")
    public List<AssignmentView> create(@RequestBody AssignmentRequest request) {
        if (request.startsAt() == null) {
            return List.of(assignmentService.create(request.username(), request.testCode()));
        }
        return assignmentService.create(request);
    }

    @GetMapping("/api/assignments")
    public List<AssignmentReportView> all() {
        return assignmentService.all();
    }

    @GetMapping("/api/my/assignments")
    public List<OpenAssignmentView> mine() {
        return assignmentService.mine();
    }
}
