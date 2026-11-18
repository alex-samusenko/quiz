package ru.galaktika.service;

public interface LocalizedMessagesService {

    String getMessage(String code, Object... args);
}
