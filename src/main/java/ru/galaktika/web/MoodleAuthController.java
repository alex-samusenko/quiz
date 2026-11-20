package ru.galaktika.web;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;
import ru.galaktika.config.MoodleAuthProperties;
import ru.galaktika.web.dto.MoodleEmulatorRequest;
import ru.galaktika.web.dto.MoodleLaunchRequest;
import ru.galaktika.web.dto.UserView;

import java.util.Map;

@RestController
@RequestMapping("/api/moodle")
@Profile("!console")
@RequiredArgsConstructor
public class MoodleAuthController {

    private final MoodleAuthProperties properties;
    private final MoodleLaunchService launches;
    private final AuthService auth;

    @GetMapping("/config")
    public Map<String, Boolean> config() {
        return Map.of("emulatorEnabled", properties.isEnabled() && properties.isEmulatorEnabled());
    }

    @PostMapping("/launch")
    public UserView launch(@RequestBody MoodleLaunchRequest request, HttpServletRequest http) {
        return auth.loginMoodle(launches.verify(request), http);
    }

    @PostMapping("/emulator/launch")
    public UserView emulate(@RequestBody MoodleEmulatorRequest request, HttpServletRequest http) {
        if (!properties.isEmulatorEnabled()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        var signedLaunch = launches.issue(request.username());
        return auth.loginMoodle(launches.verify(signedLaunch), http);
    }
}
