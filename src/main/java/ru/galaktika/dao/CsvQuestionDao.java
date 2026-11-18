package ru.galaktika.dao;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import ru.galaktika.config.TestFileNameProvider;
import ru.galaktika.domain.Question;

import java.util.List;

@Component
@RequiredArgsConstructor
public class CsvQuestionDao implements QuestionDao {

    private final TestFileNameProvider fileNameProvider;

    private final QuestionCsvReader questionCsvReader;

    @Override
    public List<Question> findAll() {
        return questionCsvReader.read(fileNameProvider.getTestFileName());
    }
}
