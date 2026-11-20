-- Демонстрационные данные из прежних CSV-файлов. Все вставки идемпотентны.

INSERT INTO mdl_question_categories (idnumber, name, sortorder)
SELECT 'java', 'Java', 10 WHERE NOT EXISTS (SELECT 1 FROM mdl_question_categories WHERE idnumber = 'java');
INSERT INTO mdl_question_categories (idnumber, name, sortorder)
SELECT 'spring', 'Spring', 20 WHERE NOT EXISTS (SELECT 1 FROM mdl_question_categories WHERE idnumber = 'spring');
INSERT INTO mdl_question_categories (idnumber, name, sortorder)
SELECT 'galaxy', 'Продукт', 30 WHERE NOT EXISTS (SELECT 1 FROM mdl_question_categories WHERE idnumber = 'galaxy');

INSERT INTO mdl_quiz (idnumber, name, created_by, timelimit)
SELECT 'java', 'Основы Java', (SELECT id FROM mdl_user WHERE username = 'mentor'), 600
WHERE NOT EXISTS (SELECT 1 FROM mdl_quiz WHERE idnumber = 'java');
INSERT INTO mdl_quiz (idnumber, name, created_by, timelimit)
SELECT 'spring', 'Spring Boot', (SELECT id FROM mdl_user WHERE username = 'mentor'), 600
WHERE NOT EXISTS (SELECT 1 FROM mdl_quiz WHERE idnumber = 'spring');
INSERT INTO mdl_quiz (idnumber, name, created_by, timelimit)
SELECT 'galaxy', 'Администрирование продукта', (SELECT id FROM mdl_user WHERE username = 'petrov'), 600
WHERE NOT EXISTS (SELECT 1 FROM mdl_quiz WHERE idnumber = 'galaxy');

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'java-mars', 'Поле final', 'Что гарантирует модификатор final для поля объекта?', TRUE, 'EASY'
FROM mdl_question_categories WHERE idnumber = 'java'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'java-mars');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'java-resources', 'Ресурсы в JAR', 'Как загружать ресурсы из jar в Java?', FALSE, 'MEDIUM'
FROM mdl_question_categories WHERE idnumber = 'java'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'java-resources');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'java-exceptions', 'Обработка исключений', 'Как правильно обработать исключение?', TRUE, 'HARD'
FROM mdl_question_categories WHERE idnumber = 'java'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'java-exceptions');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'java-orange', 'Контракт equals и hashCode', 'Какие утверждения входят в контракт equals и hashCode?', FALSE, 'MEDIUM'
FROM mdl_question_categories WHERE idnumber = 'java'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'java-orange');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'java-earth', 'Выбор коллекции', 'Какая коллекция сохраняет порядок добавления и допускает дубликаты?', TRUE, 'EASY'
FROM mdl_question_categories WHERE idnumber = 'java'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'java-earth');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'spring-web-starter', 'Web starter', 'Какой стартер поднимает встроенный веб-сервер?', TRUE, 'EASY'
FROM mdl_question_categories WHERE idnumber = 'spring'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'spring-web-starter');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'spring-application', 'Класс приложения', 'Что отмечает класс приложения Spring Boot?', FALSE, 'MEDIUM'
FROM mdl_question_categories WHERE idnumber = 'spring'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'spring-application');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'galaxy-db', 'СУБД Moodle', 'Какая СУБД хранит имитацию пользователей Moodle?', TRUE, 'EASY'
FROM mdl_question_categories WHERE idnumber = 'galaxy'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'galaxy-db');

-- Обновления нужны и для уже созданного локального стенда. Технические idnumber
-- сохранены ради совместимости с существующими ссылками и назначениями.
UPDATE mdl_question SET name = 'Поле final',
    questiontext = 'Что гарантирует модификатор final для поля объекта?',
    single_answer = TRUE, difficulty = 'EASY'
WHERE idnumber = 'java-mars';
UPDATE mdl_question SET name = 'Ресурсы в JAR',
    questiontext = 'Какие способы корректно читают ресурс из classpath внутри JAR?',
    single_answer = FALSE, difficulty = 'MEDIUM'
WHERE idnumber = 'java-resources';
UPDATE mdl_question SET name = 'Обработка исключений',
    questiontext = 'Какой подход к обработке исключения наиболее корректен в прикладном сервисе?',
    single_answer = TRUE, difficulty = 'HARD'
WHERE idnumber = 'java-exceptions';
UPDATE mdl_question SET name = 'Контракт equals и hashCode',
    questiontext = 'Какие утверждения входят в контракт equals и hashCode?',
    single_answer = FALSE, difficulty = 'MEDIUM'
WHERE idnumber = 'java-orange';
UPDATE mdl_question SET name = 'Выбор коллекции',
    questiontext = 'Какая коллекция сохраняет порядок добавления и допускает дубликаты?',
    single_answer = TRUE, difficulty = 'EASY'
WHERE idnumber = 'java-earth';

DELETE FROM mdl_question_answers
WHERE question IN (SELECT id FROM mdl_question WHERE idnumber IN
    ('java-mars', 'java-resources', 'java-exceptions', 'java-orange', 'java-earth'));

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Ссылку можно присвоить только один раз', 1, 1 FROM mdl_question WHERE idnumber = 'java-mars'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Объект по этой ссылке автоматически становится неизменяемым', 0, 2 FROM mdl_question WHERE idnumber = 'java-mars'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Поле автоматически становится static', 0, 3 FROM mdl_question WHERE idnumber = 'java-mars'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'ClassLoader#getResourceAsStream', 0.5, 1 FROM mdl_question WHERE idnumber = 'java-resources'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'ClassPathResource#getInputStream', 0.5, 2 FROM mdl_question WHERE idnumber = 'java-resources'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'ClassLoader#getResource#getFile + FileReader', 0, 3 FROM mdl_question WHERE idnumber = 'java-resources'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Wingardium Leviosa', 0, 4 FROM mdl_question WHERE idnumber = 'java-resources'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 3;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Перехватить там, где можно восстановиться, либо пробросить с сохранением причины', 1, 1 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Всегда перехватывать Exception и продолжать выполнение', 0, 2 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Выводить stack trace в стандартный поток и возвращать null', 0, 3 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Заменять любое исключение новым без передачи исходной причины', 0, 4 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 3;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Равные по equals объекты должны иметь одинаковый hashCode', 0.5, 1 FROM mdl_question WHERE idnumber = 'java-orange'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'При переопределении equals обычно необходимо переопределить hashCode', 0.5, 2 FROM mdl_question WHERE idnumber = 'java-orange'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Одинаковый hashCode гарантирует равенство объектов по equals', 0, 3 FROM mdl_question WHERE idnumber = 'java-orange'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Оператор == для объектов вызывает метод equals', 0, 4 FROM mdl_question WHERE idnumber = 'java-orange'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 3;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'ArrayList', 1, 1 FROM mdl_question WHERE idnumber = 'java-earth'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'HashSet', 0, 2 FROM mdl_question WHERE idnumber = 'java-earth'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'TreeSet', 0, 3 FROM mdl_question WHERE idnumber = 'java-earth'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'HashMap', 0, 4 FROM mdl_question WHERE idnumber = 'java-earth'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 3;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'spring-boot-starter-web', 1, 1 FROM mdl_question WHERE idnumber = 'spring-web-starter'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'spring-boot-starter-mail', 0, 2 FROM mdl_question WHERE idnumber = 'spring-web-starter'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'spring-boot-starter-batch', 0, 3 FROM mdl_question WHERE idnumber = 'spring-web-starter'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, '@SpringBootApplication', 0.5, 1 FROM mdl_question WHERE idnumber = 'spring-application'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, '@ConfigurationPropertiesScan', 0.5, 2 FROM mdl_question WHERE idnumber = 'spring-application'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, '@CsvBindByPosition', 0, 3 FROM mdl_question WHERE idnumber = 'spring-application'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'PostgreSQL', 1, 1 FROM mdl_question WHERE idnumber = 'galaxy-db'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'H2', 0, 2 FROM mdl_question WHERE idnumber = 'galaxy-db'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'MongoDB', 0, 3 FROM mdl_question WHERE idnumber = 'galaxy-db'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;

INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark)
SELECT quiz.id, source.slot, 1, question.id, 1
FROM mdl_quiz quiz
JOIN (SELECT 'java' quiz_code, 1 slot, 'java-mars' question_code
      UNION ALL SELECT 'java', 2, 'java-resources'
      UNION ALL SELECT 'java', 3, 'java-exceptions'
      UNION ALL SELECT 'java', 4, 'java-orange'
      UNION ALL SELECT 'java', 5, 'java-earth'
      UNION ALL SELECT 'spring', 1, 'spring-web-starter'
      UNION ALL SELECT 'spring', 2, 'spring-application'
      UNION ALL SELECT 'galaxy', 1, 'galaxy-db') source ON source.quiz_code = quiz.idnumber
JOIN mdl_question question ON question.idnumber = source.question_code
WHERE NOT EXISTS (SELECT 1 FROM mdl_quiz_slots slot WHERE slot.quizid = quiz.id AND slot.slot = source.slot);
