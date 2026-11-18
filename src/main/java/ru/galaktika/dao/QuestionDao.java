package ru.galaktika.dao;

import ru.galaktika.domain.Question;

import java.util.List;

public interface QuestionDao {

    List<Question> findAll();
}
