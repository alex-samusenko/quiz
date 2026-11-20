package ru.galaktika.web;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Profile("!console")
public class ActiveAttempts {

    private final Map<String, Attempt> byId = new ConcurrentHashMap<>();

    private final Map<String, String> byAssignment = new ConcurrentHashMap<>();

    public void put(Attempt attempt) {
        byId.put(attempt.getId(), attempt);
        byAssignment.put(attempt.getMeta().assignmentId(), attempt.getId());
    }

    public Attempt find(String id) {
        return byId.get(id);
    }

    public String idForAssignment(String assignmentId) {
        return byAssignment.get(assignmentId);
    }

    public List<Attempt> all() {
        return List.copyOf(byId.values());
    }

    public void finish(Attempt attempt) {
        byAssignment.remove(attempt.getMeta().assignmentId());
    }
}
