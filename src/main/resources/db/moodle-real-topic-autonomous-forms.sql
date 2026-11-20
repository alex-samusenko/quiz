-- Реальный пример из Moodle: курс 375, категория 1785, тема «Автономные формы».
-- Перенесены восемь вопросов уровня «Легкий» (Moodle question id 21723-21730).

INSERT INTO mdl_question_categories (idnumber, name, sortorder)
SELECT 'moodle-1785-autonomous-forms', 'ERP: Автономные формы', 40
WHERE NOT EXISTS (SELECT 1 FROM mdl_question_categories WHERE idnumber = 'moodle-1785-autonomous-forms');

INSERT INTO mdl_quiz (idnumber, name, created_by, timelimit)
SELECT 'erp-autonomous-forms', 'ERP: Автономные формы',
       (SELECT id FROM mdl_user WHERE username = 'mentor'), 1800
WHERE NOT EXISTS (SELECT 1 FROM mdl_quiz WHERE idnumber = 'erp-autonomous-forms');

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)
SELECT category.id, source.idnumber, source.name, source.questiontext, TRUE, 'EASY'
FROM mdl_question_categories category
JOIN (
    SELECT 'moodle-q21726' idnumber, 'Имя логической таблицы' name,
           'Какое ограничение действует на имя логической таблицы автономной формы?' questiontext
    UNION ALL SELECT 'moodle-q21723', 'Конвертация в RTF',
           'Как в модуле «Редактор отчетов FCOM» выполнить конвертацию формы из формата бизнес-текст в RTF?'
    UNION ALL SELECT 'moodle-q21727', 'Оператор .nameInList',
           'Для чего в автономной форме используется оператор .nameInList?'
    UNION ALL SELECT 'moodle-q21724', 'Опция .slkNumber',
           'Для чего предназначена опция формы .slkNumber?'
    UNION ALL SELECT 'moodle-q21728', 'Превышение размера шаблона',
           'Что выводится в отчет, если размер числового поля превышает размер шаблона?'
    UNION ALL SELECT 'moodle-q21729', 'Секция переменных',
           'Что верно про объявление переменных и массивов в автономной форме (.var … .endvar)?'
    UNION ALL SELECT 'moodle-q21730', 'Условный внутренний блок',
           'Чем условный внутренний блок .{?internal отличается от цикла по SQL-таблице?'
    UNION ALL SELECT 'moodle-q21725', 'Цикл WHILE',
           'В чем основное отличие цикла WHILE от цикла по SQL-таблице в автономной форме?'
) source ON 1 = 1
WHERE category.idnumber = 'moodle-1785-autonomous-forms'
  AND NOT EXISTS (SELECT 1 FROM mdl_question q WHERE q.idnumber = source.idnumber);

DELETE FROM mdl_question_answers
WHERE question IN (SELECT id FROM mdl_question WHERE idnumber IN
    ('moodle-q21726', 'moodle-q21723', 'moodle-q21727', 'moodle-q21724',
     'moodle-q21728', 'moodle-q21729', 'moodle-q21730', 'moodle-q21725'));

INSERT INTO mdl_question_answers (question, answer, fraction, answer_order)
SELECT question.id, source.answer, source.fraction, source.answer_order
FROM mdl_question question
JOIN (
    SELECT 'moodle-q21726' code, 'Имя может повторяться в одном ресурсном файле, если таблицы в разных формах' answer, 0 fraction, 1 answer_order
    UNION ALL SELECT 'moodle-q21726', 'Имя — идентификатор или строка длиной до 100 символов; имена должны быть уникальными в пределах одного ресурсного файла', 1, 2
    UNION ALL SELECT 'moodle-q21726', 'Имя логической таблицы всегда совпадает с именем физической таблицы БД', 0, 3
    UNION ALL SELECT 'moodle-q21723', 'Нажать Ctrl+A и выбрать «Компиляция форм | Компиляция»', 0, 1
    UNION ALL SELECT 'moodle-q21723', 'Открыть файл на редактирование и нажать Shift+F8 (пункт «Компиляция форм | Конвертация»)', 1, 2
    UNION ALL SELECT 'moodle-q21723', 'Сохранить документ в MS EXCEL в формате SYLK (*.slk)', 0, 3
    UNION ALL SELECT 'moodle-q21727', 'Чтобы сделать форму видимой в среде выполнения приложения', 0, 1
    UNION ALL SELECT 'moodle-q21727', 'Чтобы задать заголовок формы, который будет виден пользователю в списке отчетов', 1, 2
    UNION ALL SELECT 'moodle-q21727', 'Чтобы объявить логическую таблицу без SQL-элементов', 0, 3
    UNION ALL SELECT 'moodle-q21724', 'Для конвертации бизнес-текста в RTF', 0, 1
    UNION ALL SELECT 'moodle-q21724', 'Только для отчетов в формате SLK: в поля с шаблоном «&» выводятся числа в понимании EXCEL, их можно форматировать как числа и использовать в расчетах', 1, 2
    UNION ALL SELECT 'moodle-q21724', 'Для подавления вывода нулевых значений в отчетах бизнес-текст', 0, 3
    UNION ALL SELECT 'moodle-q21728', 'В отчет выводятся символы ***', 1, 1
    UNION ALL SELECT 'moodle-q21728', 'Число автоматически переносится на следующую строку', 0, 2
    UNION ALL SELECT 'moodle-q21728', 'Значение обрезается без каких-либо признаков в отчете', 0, 3
    UNION ALL SELECT 'moodle-q21729', 'Ключевое слово .var может стоять в любой позиции строки, переменные инициализируются случайными значениями', 0, 1
    UNION ALL SELECT 'moodle-q21729', 'Ключевое слово .var стоит в первой позиции строки; при объявлении переменные и массивы инициализируются нулевыми значениями; область действия ограничивается формой', 1, 2
    UNION ALL SELECT 'moodle-q21729', 'Переменные, объявленные в форме, видны во всех формах одного ресурсного файла', 0, 3
    UNION ALL SELECT 'moodle-q21730', 'Он выполняется столько раз, сколько записей в узле логической таблицы', 0, 1
    UNION ALL SELECT 'moodle-q21730', 'Он не является циклом: выполняется только один раз и только при истинности условия исполнения', 1, 2
    UNION ALL SELECT 'moodle-q21730', 'Он всегда выполняется, даже если условие ложно', 0, 3
    UNION ALL SELECT 'moodle-q21725', 'В цикле WHILE нельзя использовать программные блоки .begin', 0, 1
    UNION ALL SELECT 'moodle-q21725', 'Условие выхода из цикла WHILE задается явно и не определяется наличием записей в узле логической таблицы', 1, 2
    UNION ALL SELECT 'moodle-q21725', 'Цикл WHILE можно использовать только в формах формата SLK', 0, 3
) source ON source.code = question.idnumber;

DELETE FROM mdl_quiz_slots
WHERE quizid = (SELECT id FROM mdl_quiz WHERE idnumber = 'erp-autonomous-forms');

INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark)
SELECT quiz.id, source.slot, 1, question.id, 1
FROM mdl_quiz quiz
JOIN (
    SELECT 1 slot, 'moodle-q21726' code
    UNION ALL SELECT 2, 'moodle-q21723'
    UNION ALL SELECT 3, 'moodle-q21727'
    UNION ALL SELECT 4, 'moodle-q21724'
    UNION ALL SELECT 5, 'moodle-q21728'
    UNION ALL SELECT 6, 'moodle-q21729'
    UNION ALL SELECT 7, 'moodle-q21730'
    UNION ALL SELECT 8, 'moodle-q21725'
) source ON 1 = 1
JOIN mdl_question question ON question.idnumber = source.code
WHERE quiz.idnumber = 'erp-autonomous-forms';
