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
SELECT id, 'java-mars', 'Жизнь на Марсе', 'Есть ли жизнь на Марсе?', TRUE, 'EASY'
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
SELECT id, 'java-orange', 'Цвет апельсина', 'Какого цвета апельсин?', TRUE, 'EASY'
FROM mdl_question_categories WHERE idnumber = 'java'
AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'java-orange');
INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT id, 'java-earth', 'Форма Земли', 'Какая форма у Земли?', TRUE, 'MEDIUM'
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

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Наука этого пока не знает', 1, 1 FROM mdl_question WHERE idnumber = 'java-mars'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Красная тарелка с Марса, а зелёная с Венеры', 0, 2 FROM mdl_question WHERE idnumber = 'java-mars'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Совершенно нет', 0, 3 FROM mdl_question WHERE idnumber = 'java-mars'
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
SELECT id, '@SneakyThrows', 0, 1 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'e.printStackTrace()', 0, 2 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Пробросить, обернув в бизнес-исключение (например, QuestionReadException)', 1, 3 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Проигнорировать исключение', 0, 4 FROM mdl_question WHERE idnumber = 'java-exceptions'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 3;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Оранжевый', 1, 1 FROM mdl_question WHERE idnumber = 'java-orange'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Зелёный', 0, 2 FROM mdl_question WHERE idnumber = 'java-orange'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Жёлтый', 0, 3 FROM mdl_question WHERE idnumber = 'java-orange'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Идеальное полушарие', 0, 1 FROM mdl_question WHERE idnumber = 'java-earth'
AND NOT EXISTS (SELECT 1 FROM mdl_question_answers a WHERE a.question = mdl_question.id);
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Идеальная сфера', 0, 2 FROM mdl_question WHERE idnumber = 'java-earth'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 1;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'В основном плоская', 0, 3 FROM mdl_question WHERE idnumber = 'java-earth'
AND (SELECT COUNT(*) FROM mdl_question_answers a WHERE a.question = mdl_question.id) = 2;
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT id, 'Сплюснутый сфероид', 1, 4 FROM mdl_question WHERE idnumber = 'java-earth'
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
