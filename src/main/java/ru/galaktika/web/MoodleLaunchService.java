package ru.galaktika.web;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import ru.galaktika.config.MoodleAuthProperties;
import ru.galaktika.web.dto.MoodleLaunchRequest;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class MoodleLaunchService {

    private static final String HMAC_ALGORITHM = "HmacSHA256";

    private final MoodleAuthProperties properties;
    private final Clock clock;
    private final Map<String, Instant> usedNonces = new ConcurrentHashMap<>();

    public MoodleLaunchService(MoodleAuthProperties properties, Clock clock) {
        this.properties = properties;
        this.clock = clock;
    }

    public MoodleLaunchRequest issue(String username) {
        requireConfigured();
        var issuedAt = clock.instant().getEpochSecond();
        var nonce = UUID.randomUUID().toString();
        return new MoodleLaunchRequest(username, issuedAt, nonce, sign(username, issuedAt, nonce));
    }

    public String verify(MoodleLaunchRequest request) {
        requireConfigured();
        if (request == null || isBlank(request.username()) || isBlank(request.nonce())
                || isBlank(request.signature())) {
            throw unauthorized("Некорректный переход из Moodle");
        }
        var now = clock.instant();
        var issued = Instant.ofEpochSecond(request.issuedAt());
        var ttl = properties.getTokenTtlSeconds();
        if (issued.isAfter(now.plusSeconds(5)) || issued.isBefore(now.minusSeconds(ttl))) {
            throw unauthorized("Срок действия перехода из Moodle истёк");
        }
        var expected = sign(request.username(), request.issuedAt(), request.nonce());
        if (!MessageDigest.isEqual(expected.getBytes(StandardCharsets.US_ASCII),
                request.signature().getBytes(StandardCharsets.US_ASCII))) {
            throw unauthorized("Подпись перехода из Moodle недействительна");
        }
        purgeExpired(now, ttl);
        if (usedNonces.putIfAbsent(request.nonce(), issued) != null) {
            throw unauthorized("Переход из Moodle уже был использован");
        }
        return request.username().trim();
    }

    private String sign(String username, long issuedAt, String nonce) {
        try {
            var mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(properties.getSharedSecret().getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM));
            var value = username.trim() + "\n" + issuedAt + "\n" + nonce;
            return Base64.getUrlEncoder().withoutPadding()
                    .encodeToString(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception cause) {
            throw new IllegalStateException("Не удалось подписать переход из Moodle", cause);
        }
    }

    private void requireConfigured() {
        if (!properties.isEnabled() || isBlank(properties.getSharedSecret())
                || properties.getSharedSecret().length() < 32 || properties.getTokenTtlSeconds() <= 0) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Авторизация через Moodle не настроена");
        }
    }

    private void purgeExpired(Instant now, long ttl) {
        usedNonces.entrySet().removeIf(entry -> entry.getValue().isBefore(now.minusSeconds(ttl)));
    }

    private ResponseStatusException unauthorized(String message) {
        return new ResponseStatusException(HttpStatus.UNAUTHORIZED, message);
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
