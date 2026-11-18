package ru.galaktika.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.galaktika.domain.Student;

@Service
@RequiredArgsConstructor
public class StudentServiceImpl implements StudentService {

    private final IOService ioService;

    private final LocalizedMessagesService messages;

    @Override
    public Student determineCurrentStudent() {
        var firstName = ioService.readStringWithPrompt(messages.getMessage("student.first.name"));
        var lastName = ioService.readStringWithPrompt(messages.getMessage("student.last.name"));
        return new Student(firstName, lastName);
    }
}
