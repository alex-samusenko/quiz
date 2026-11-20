package ru.galaktika.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.test.web.servlet.MockMvc;
import ru.galaktika.web.dto.MoodleLaunchRequest;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class MoodleAuthTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MoodleLaunchService launches;

    @Autowired
    private ObjectMapper json;

    @Test
    void emulatorCreatesSessionForSelectedMoodleUser() throws Exception {
        var result = mockMvc.perform(post("/api/moodle/emulator/launch")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"mentor\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("mentor"))
                .andExpect(jsonPath("$.role").value("mentor"))
                .andReturn();

        mockMvc.perform(get("/api/session")
                        .session((MockHttpSession) result.getRequest().getSession(false)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("mentor"));
    }

    @Test
    void signedLaunchIsSingleUse() throws Exception {
        var request = launches.issue("user");
        var body = json.writeValueAsString(request);
        mockMvc.perform(post("/api/moodle/launch").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isOk());
        mockMvc.perform(post("/api/moodle/launch").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void rejectsTamperedLaunch() throws Exception {
        var valid = launches.issue("user");
        var tampered = new MoodleLaunchRequest("admin", valid.issuedAt(), valid.nonce(), valid.signature());
        mockMvc.perform(post("/api/moodle/launch")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json.writeValueAsString(tampered)))
                .andExpect(status().isUnauthorized());
    }
}
