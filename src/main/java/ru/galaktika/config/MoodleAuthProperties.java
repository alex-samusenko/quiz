package ru.galaktika.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "auth.moodle")
public class MoodleAuthProperties {

    private boolean enabled;
    private boolean emulatorEnabled;
    private String sharedSecret = "";
    private long tokenTtlSeconds = 60;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public boolean isEmulatorEnabled() {
        return emulatorEnabled;
    }

    public void setEmulatorEnabled(boolean emulatorEnabled) {
        this.emulatorEnabled = emulatorEnabled;
    }

    public String getSharedSecret() {
        return sharedSecret;
    }

    public void setSharedSecret(String sharedSecret) {
        this.sharedSecret = sharedSecret;
    }

    public long getTokenTtlSeconds() {
        return tokenTtlSeconds;
    }

    public void setTokenTtlSeconds(long tokenTtlSeconds) {
        this.tokenTtlSeconds = tokenTtlSeconds;
    }
}
