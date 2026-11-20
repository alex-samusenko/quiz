package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.*;
import ru.galaktika.web.dto.AppealRequest;
import ru.galaktika.web.dto.AppealResolutionRequest;
import ru.galaktika.web.dto.AppealView;

import java.util.List;

@RestController
@Profile("!console")
@RequiredArgsConstructor
public class AppealController {
    private final AppealService service;

    @PostMapping("/api/my/attempts/{id}/appeal")
    public void create(@PathVariable("id") String id, @RequestBody AppealRequest request) {
        service.create(id, request);
    }

    @GetMapping("/api/mentor/appeals")
    public List<AppealView> mentorAppeals() { return service.mentorAppeals(); }

    @PostMapping("/api/mentor/appeals/{id}/resolve")
    public void resolve(@PathVariable("id") String id, @RequestBody AppealResolutionRequest request) {
        service.resolve(id, request);
    }
}
