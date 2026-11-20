package ru.galaktika.web;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import ru.galaktika.auth.CurrentUserService;
import ru.galaktika.auth.UserRole;
import ru.galaktika.dao.TestCatalog;
import ru.galaktika.db.AttemptRepository;
import ru.galaktika.db.AttemptStats;
import ru.galaktika.db.MoodleUserRepository;
import ru.galaktika.domain.AttestationTest;
import ru.galaktika.web.dto.AttemptReportView;
import ru.galaktika.web.dto.ListenerView;
import ru.galaktika.web.dto.MentorTestView;
import ru.galaktika.web.dto.TestOptionView;

import java.util.List;

@Service
@Profile("!console")
@RequiredArgsConstructor
public class ReportService {

    private final CurrentUserService currentUser;

    private final AttemptRepository attempts;

    private final TestCatalog catalog;

    private final MoodleUserRepository users;

    public List<AttemptReportView> allAttempts() {
        currentUser.require(UserRole.MANAGER);
        return attempts.findFinished();
    }

    public List<AttemptReportView> myAttempts() {
        var listener = currentUser.require(UserRole.USER);
        return attempts.findFinishedByListener(listener.id());
    }

    public List<MentorTestView> mentorTests() {
        var mentor = currentUser.require(UserRole.MENTOR);
        var stats = attempts.stats();
        return catalog.findAll().stream()
                .filter(test -> test.mentor().equals(mentor.username()))
                .map(test -> toMentorView(test, stats))
                .toList();
    }

    public List<AttemptReportView> mentorAttempts() {
        var mentor = currentUser.require(UserRole.MENTOR);
        return attempts.findFinishedByMentor(mentor.username());
    }

    public List<ListenerView> listeners() {
        currentUser.requireAny(UserRole.ADMIN, UserRole.MANAGER);
        return users.findListeners();
    }

    public List<ListenerView> searchListeners(String query) {
        currentUser.require(UserRole.MANAGER);
        if (query == null || query.trim().length() < 2) {
            return List.of();
        }
        return users.searchListeners(query);
    }

    public List<TestOptionView> tests() {
        currentUser.require(UserRole.MANAGER);
        return catalog.findAll().stream()
                .map(test -> new TestOptionView(test.code(), test.title(), test.mentor()))
                .toList();
    }

    public void requireManager() {
        currentUser.require(UserRole.MANAGER);
    }

    private MentorTestView toMentorView(AttestationTest test, List<AttemptStats> stats) {
        var matched = stats.stream().filter(item -> item.testCode().equals(test.code())).findFirst();
        var passed = matched.map(AttemptStats::passedCount).orElse(0);
        var failed = matched.map(AttemptStats::failedCount).orElse(0);
        return new MentorTestView(test.code(), test.title(), passed, failed);
    }
}
