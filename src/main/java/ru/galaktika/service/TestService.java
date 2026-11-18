package ru.galaktika.service;

import ru.galaktika.domain.Student;
import ru.galaktika.domain.TestResult;

public interface TestService {

    TestResult executeTestFor(Student student);
}
