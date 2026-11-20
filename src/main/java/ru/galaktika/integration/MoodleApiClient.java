package ru.galaktika.integration;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.util.HtmlUtils;
import org.springframework.web.client.RestClient;
import ru.galaktika.config.MoodleIntegrationProperties;
import ru.galaktika.domain.Answer;
import ru.galaktika.domain.AttestationLevel;
import ru.galaktika.domain.AttestationTest;
import ru.galaktika.domain.ChoiceType;
import ru.galaktika.domain.Difficulty;
import ru.galaktika.domain.Question;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class MoodleApiClient {
    public static final String BANK_PREFIX = "moodle-bank:";

    private final MoodleIntegrationProperties properties;
    private final ObjectMapper mapper;

    public List<AttestationTest> tests() {
        if (!properties.isEnabled()) return List.of();
        var result = new ArrayList<AttestationTest>();
        for (var bank : call("local_attestation_get_banks")) {
            var bankCode = bank.path("code").asText();
            var courseName = bank.path("coursename").asText();
            var bankName = bank.path("name").asText();
            var title = courseName.isBlank() ? bankName : courseName;
            result.add(new AttestationTest(BANK_PREFIX + bankCode, "Moodle · " + title,
                    "mentor", bankCode, AttestationLevel.SPECIALIST));
        }
        return result;
    }

    public Optional<AttestationTest> findTest(String code) {
        if (!isBankCode(code)) return Optional.empty();
        return tests().stream().filter(test -> test.code().equals(code)).findFirst();
    }

    public boolean isBankCode(String code) {
        return code != null && code.startsWith(BANK_PREFIX);
    }

    public List<Question> questions(AttestationTest test) {
        if (!properties.isEnabled() || !isBankCode(test.code())) return List.of();
        var result = new ArrayList<Question>();
        for (var source : call("local_attestation_get_bank_questions", "bankcode", test.resource())) {
            if (!"multichoice".equals(source.path("qtype").asText())) continue;
            var difficulty = difficulty(source);
            if (difficulty == null) continue;
            var answers = readAnswers(source.path("answersjson").asText("[]"));
            var correctCount = answers.stream().filter(Answer::isCorrect).count();
            if (answers.size() < 2 || correctCount == 0) continue;
            var choiceType = correctCount == 1 ? ChoiceType.SINGLE : ChoiceType.MULTIPLE;
            result.add(new Question(cleanHtml(source.path("text").asText()), answers, difficulty,
                    choiceType, source.path("category").asText("Без темы")));
        }
        return result;
    }

    public MoodleIntegrationView inspect() {
        if (!properties.isEnabled()) return new MoodleIntegrationView(false, "Отключено", "", List.of());
        var ping = call("local_attestation_ping");
        var banksNode = call("local_attestation_get_banks");
        var banks = new ArrayList<MoodleBankView>();
        for (var bank : banksNode) {
            var questions = call("local_attestation_get_bank_questions", "bankcode", bank.path("code").asText());
            var automatic = 0; var easy = 0; var medium = 0; var hard = 0;
            for (var question : questions) {
                if (!"multichoice".equals(question.path("qtype").asText())) continue;
                automatic++;
                var tags = readStrings(question.path("tagsjson").asText("[]"));
                if (tags.contains("difficulty:easy")) easy++;
                else if (tags.contains("difficulty:medium")) medium++;
                else if (tags.contains("difficulty:hard")) hard++;
            }
            banks.add(new MoodleBankView(bank.path("code").asText(), bank.path("name").asText(),
                    bank.path("coursename").asText(), bank.path("coursemoduleid").asInt(),
                    bank.path("contextid").asInt(), questions.size(), automatic, easy, medium, hard));
        }
        return new MoodleIntegrationView(true, "Подключено", ping.path("release").asText(), banks);
    }

    private JsonNode call(String function, String... parameter) {
        var client = RestClient.create(properties.getBaseUrl());
        var form = new LinkedMultiValueMap<String, String>();
        form.add("wstoken", properties.getToken());
        form.add("moodlewsrestformat", "json");
        form.add("wsfunction", function);
        if (parameter.length == 2) form.add(parameter[0], parameter[1]);
        var response = client.post()
                .uri("/webservice/rest/server.php")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(form)
                .retrieve()
                .body(JsonNode.class);
        if (response == null) throw new IllegalStateException("Moodle вернул пустой ответ");
        if (response.has("exception")) {
            throw new IllegalStateException("Ошибка Moodle: " + response.path("message").asText("неизвестная ошибка"));
        }
        return response;
    }

    private List<String> readStrings(String value) {
        try { return mapper.readValue(value, new TypeReference<>() { }); }
        catch (Exception exception) { throw new IllegalStateException("Некорректные теги Moodle", exception); }
    }

    private List<Answer> readAnswers(String value) {
        try {
            var nodes = mapper.readTree(value);
            var result = new ArrayList<Answer>();
            for (var node : nodes) {
                result.add(new Answer(cleanHtml(node.path("answer").asText()),
                        node.path("fraction").asDouble() > 0));
            }
            return List.copyOf(result);
        } catch (Exception exception) {
            throw new IllegalStateException("Некорректные варианты ответа Moodle", exception);
        }
    }

    private Difficulty difficulty(JsonNode question) {
        var tags = readStrings(question.path("tagsjson").asText("[]")).stream()
                .map(value -> value.toLowerCase(Locale.ROOT)).toList();
        if (tags.contains("difficulty:easy")) return Difficulty.EASY;
        if (tags.contains("difficulty:medium")) return Difficulty.MEDIUM;
        if (tags.contains("difficulty:hard")) return Difficulty.HARD;
        var mark = question.path("defaultmark").asDouble();
        if (mark == 5.0) return Difficulty.EASY;
        if (mark == 7.0) return Difficulty.MEDIUM;
        if (mark == 10.0) return Difficulty.HARD;
        return null;
    }

    private String cleanHtml(String value) {
        var withBreaks = value.replaceAll("(?i)<br\\s*/?>", "\n")
                .replaceAll("(?i)</p\\s*>", "\n");
        var withoutTags = withBreaks.replaceAll("(?s)<[^>]+>", "");
        return HtmlUtils.htmlUnescape(withoutTags)
                .replace('\u00a0', ' ')
                .replaceAll("[ \\t]+", " ")
                .replaceAll(" *\\n *", "\n")
                .trim();
    }
}
