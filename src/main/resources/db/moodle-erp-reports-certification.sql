-- Generated from the Moodle GIFT export; do not edit by hand.
INSERT INTO mdl_question_categories (idnumber, name, sortorder)
SELECT 'erp-reports-certification', 'ERP: Сертификация Отчёты', 50
WHERE NOT EXISTS (SELECT 1 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification');
UPDATE mdl_question_categories SET name = 'ERP: Сертификация Отчёты', sortorder = 50 WHERE idnumber = 'erp-reports-certification';

INSERT INTO mdl_quiz (idnumber, name, created_by, timelimit, visible)
SELECT 'erp-reports-certification', 'Сертификация: Отчёты ERP', id, 10800, TRUE
FROM mdl_user WHERE username = 'mentor' AND NOT EXISTS (SELECT 1 FROM mdl_quiz WHERE idnumber = 'erp-reports-certification');
UPDATE mdl_quiz SET name = 'Сертификация: Отчёты ERP', timelimit = 10800, visible = TRUE WHERE idnumber = 'erp-reports-certification';

UPDATE mdl_quiz SET visible = FALSE WHERE idnumber IN ('java', 'spring', 'galaxy', 'erp-autonomous-forms');

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q0', 'Раздел: Автономные формы, Легкий. Имя логической таблицы', 'Какое ограничение действует на имя логической таблицы автономной формы?', TRUE, 'EASY', 0 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q0');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Имя логической таблицы', questiontext = 'Какое ограничение действует на имя логической таблицы автономной формы?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 0 WHERE idnumber = 'moodle-q0';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q0');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Имя может повторяться в одном ресурсном файле, если таблицы в разных формах', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q0';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Имя — идентификатор или строка длиной до 100 символов; имена должны быть уникальными в пределах одного ресурсного файла', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q0';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Имя логической таблицы всегда совпадает с именем физической таблицы БД', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q0';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21723', 'Раздел: Автономные формы, Легкий. Конвертация в RTF', 'Как в модуле «Редактор отчетов FCOM» выполнить конвертацию формы из формата бизнес-текст в RTF?', TRUE, 'EASY', 21723 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21723');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Конвертация в RTF', questiontext = 'Как в модуле «Редактор отчетов FCOM» выполнить конвертацию формы из формата бизнес-текст в RTF?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21723 WHERE idnumber = 'moodle-q21723';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21723');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Нажать Ctrl+A и выбрать «Компиляция форм | Компиляция»', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21723';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Открыть файл на редактирование и нажать Shift+F8 (пункт «Компиляция форм | Конвертация»)', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21723';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Сохранить документ в MS EXCEL в формате SYLK (*.slk)', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21723';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21727', 'Раздел: Автономные формы, Легкий. Оператор .nameInList', 'Для чего в автономной форме используется оператор .nameInList?', TRUE, 'EASY', 21727 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21727');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Оператор .nameInList', questiontext = 'Для чего в автономной форме используется оператор .nameInList?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21727 WHERE idnumber = 'moodle-q21727';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21727');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Чтобы сделать форму видимой в среде выполнения приложения', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21727';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Чтобы задать заголовок формы, который будет виден пользователю в списке отчетов', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21727';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Чтобы объявить логическую таблицу без SQL-элементов', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21727';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21724', 'Раздел: Автономные формы, Легкий. Опция .slkNumber', 'Для чего предназначена опция формы .slkNumber?', TRUE, 'EASY', 21724 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21724');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Опция .slkNumber', questiontext = 'Для чего предназначена опция формы .slkNumber?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21724 WHERE idnumber = 'moodle-q21724';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21724');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Для конвертации бизнес-текста в RTF', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21724';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Только для отчетов в формате SLK: в поля с шаблоном «&» выводятся числа в понимании EXCEL, их можно форматировать как числа и использовать в расчетах', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21724';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Для подавления вывода нулевых значений в отчетах бизнес-текст', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21724';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21728', 'Раздел: Автономные формы, Легкий. Превышение размера шаблона', 'Что выводится в отчет, если размер числового поля превышает размер шаблона?', TRUE, 'EASY', 21728 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21728');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Превышение размера шаблона', questiontext = 'Что выводится в отчет, если размер числового поля превышает размер шаблона?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21728 WHERE idnumber = 'moodle-q21728';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21728');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'В отчет выводятся символы ***', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21728';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Число автоматически переносится на следующую строку', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21728';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Значение обрезается без каких-либо признаков в отчете', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21728';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21729', 'Раздел: Автономные формы, Легкий. Секция переменных', 'Что верно про объявление переменных и массивов в автономной форме (.var … .endvar)?', TRUE, 'EASY', 21729 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21729');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Секция переменных', questiontext = 'Что верно про объявление переменных и массивов в автономной форме (.var … .endvar)?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21729 WHERE idnumber = 'moodle-q21729';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21729');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Ключевое слово .var может стоять в любой позиции строки, переменные инициализируются случайными значениями', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21729';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Ключевое слово .var стоит в первой позиции строки; при объявлении переменные и массивы инициализируются нулевыми значениями; область действия ограничивается формой', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21729';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переменные, объявленные в форме, видны во всех формах одного ресурсного файла', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21729';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21730', 'Раздел: Автономные формы, Легкий. Условный внутренний блок', 'Чем условный внутренний блок .{?internal отличается от цикла по SQL-таблице?', TRUE, 'EASY', 21730 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21730');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Условный внутренний блок', questiontext = 'Чем условный внутренний блок .{?internal отличается от цикла по SQL-таблице?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21730 WHERE idnumber = 'moodle-q21730';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21730');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Он выполняется столько раз, сколько записей в узле логической таблицы', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21730';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Он не является циклом: выполняется только один раз и только при истинности условия исполнения', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21730';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Он всегда выполняется, даже если условие ложно', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21730';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21725', 'Раздел: Автономные формы, Легкий. Цикл WHILE', 'В чем основное отличие цикла WHILE от цикла по SQL-таблице в автономной форме?', TRUE, 'EASY', 21725 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21725');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Легкий. Цикл WHILE', questiontext = 'В чем основное отличие цикла WHILE от цикла по SQL-таблице в автономной форме?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21725 WHERE idnumber = 'moodle-q21725';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21725');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'В цикле WHILE нельзя использовать программные блоки .begin', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21725';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Условие выхода из цикла WHILE задается явно и не определяется наличием записей в узле логической таблицы', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21725';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Цикл WHILE можно использовать только в формах формата SLK', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21725';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21636', 'Раздел: Автономные формы, Сложный. Вычисляемое поле', 'Выберите элементы, из которых может состоять вычисляемое поле автономной формы:', FALSE, 'HARD', 21636 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21636');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Сложный. Вычисляемое поле', questiontext = 'Выберите элементы, из которых может состоять вычисляемое поле автономной формы:', single_answer = FALSE, difficulty = 'HARD', source_question_id = 21636 WHERE idnumber = 'moodle-q21636';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21636');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'элемент массива данной формы', 0.2000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21636';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'параметр данной формы', 0.2000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21636';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'переменная данной формы', 0.2000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21636';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'переменная формы, вызывающей данную', -1.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21636';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'поле таблицы БД, доступ к которому возможен через логические таблицы, созданные или объявленные в данной форме', 0.2000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21636';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'поле таблицы БД, доступ к которому возможен через логические таблицы, созданные или объявленные в форме, вызывающей данную форму', -1.0000000, 7 FROM mdl_question WHERE idnumber = 'moodle-q21636';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'арифметическое выражение, содержащее функции дат, строковые, математические функции и др.', 0.2000000, 8 FROM mdl_question WHERE idnumber = 'moodle-q21636';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21740', 'Раздел: Автономные формы, Сложный. Корень выборки в цикле', 'По какой таблице работает цикл, если в шапке указано только имя логической таблицы (можно без кавычек), без ключевого слова table и без имени узла?', TRUE, 'HARD', 21740 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21740');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Сложный. Корень выборки в цикле', questiontext = 'По какой таблице работает цикл, если в шапке указано только имя логической таблицы (можно без кавычек), без ключевого слова table и без имени узла?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21740 WHERE idnumber = 'moodle-q21740';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21740');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'По всем узлам выборки одновременно', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21740';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'По корневой таблице выборки', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21740';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Цикл в этом случае не выполняется и форма завершается с ошибкой компиляции', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21740';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21741', 'Раздел: Автономные формы, Сложный. Область видимости в .begin', 'Какие данные можно использовать в программном блоке .begin … end. автономной формы?', FALSE, 'HARD', 21741 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21741');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Сложный. Область видимости в .begin', questiontext = 'Какие данные можно использовать в программном блоке .begin … end. автономной формы?', single_answer = FALSE, difficulty = 'HARD', source_question_id = 21741 WHERE idnumber = 'moodle-q21741';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21741');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переменные и массивы, объявленные в форме (область видимости — эта форма)', 0.3333333, 2 FROM mdl_question WHERE idnumber = 'moodle-q21741';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переменные и массивы, объявленные в данном блоке .begin: они видны в своем блоке и во всех вложенных блоках', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21741';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Поля таблиц базы данных и вызовы стандартных процедур и функций', 0.3333333, 4 FROM mdl_question WHERE idnumber = 'moodle-q21741';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Операторы VIP исполняются в произвольном порядке, независимо от текста блока', -1.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21741';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21742', 'Раздел: Автономные формы, Сложный. Позиционирование getfirst', 'Почему при выводе одиночных полей логической таблицы без цикла данные могут не попасть в отчет и что требуется сделать?', FALSE, 'HARD', 21742 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21742');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Сложный. Позиционирование getfirst', questiontext = 'Почему при выводе одиночных полей логической таблицы без цикла данные могут не попасть в отчет и что требуется сделать?', single_answer = FALSE, difficulty = 'HARD', source_question_id = 21742 WHERE idnumber = 'moodle-q21742';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21742');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Компилятор всегда пропускает секцию .fields, пока не вызван AbortForm', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21742';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Из-за встроенной оптимизации логической таблицы нужно выполнить ручное позиционирование, например <имя_логической_таблицы>.getfirst
 <имя_узла>=tsOk в программном блоке', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21742';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '', 1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21742';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Одиночные поля выводятся только в формах формата SLK при опции .slkNumber', 0.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21742';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21743', 'Раздел: Автономные формы, Сложный. Служебные строки', 'Когда строка автономной формы считается служебной и не выводится в отчет?', TRUE, 'HARD', 21743 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21743');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Сложный. Служебные строки', questiontext = 'Когда строка автономной формы считается служебной и не выводится в отчет?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21743 WHERE idnumber = 'moodle-q21743';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21743');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Если в любой позиции строки встречается символ «!»', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21743';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Если компилятор встречает «.» в первом символе строки (исключение — завершающие элементы некоторых секций и горизонтальные циклы, где «.» может быть в любой позиции)', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21743';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Если строка содержит только шаблоны ^, & или @', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21743';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21637', 'Раздел: Автономные формы, Средний. Конструкция If и Fexit', 'Выберите правильное пояснение к следующей конструкции if, используемой в автономной форме:

if runinterface (''GetState'', nState) = cmCancel then <имя_формы>.fexit', TRUE, 'MEDIUM', 21637 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21637');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Конструкция If и Fexit', questiontext = 'Выберите правильное пояснение к следующей конструкции if, используемой в автономной форме:

if runinterface (''GetState'', nState) = cmCancel then <имя_формы>.fexit', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21637 WHERE idnumber = 'moodle-q21637';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21637');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'При нажатии пользователем кнопки [Cancel] открытого интерфейса GetState применяется метод немедленного выхода из формы (для интерфейса, не имеющих подобных кнопок, конструкция не подходит)', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21637';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'При закрытии пользователем открытого интерфейса GetState клавишами ESC или Alt+F3 применяется метод немедленного выхода из формы', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21637';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'При запуске пользователем интерфейса GetState интерфейс принудительно закрывается и продолжается выполнение формы', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21637';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'При выборе государства клавишей Enter интерфейс принудительно закрывается и применяется метод немедленного выхода из формы', 0.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21637';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21744', 'Раздел: Автономные формы, Средний. Перенос строкового шаблона', 'Что происходит, если размер строкового значения превышает размер шаблона?', TRUE, 'MEDIUM', 21744 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21744');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Перенос строкового шаблона', questiontext = 'Что происходит, если размер строкового значения превышает размер шаблона?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21744 WHERE idnumber = 'moodle-q21744';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21744');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'В отчет выводятся символы ***, как для числового поля', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21744';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Текст переносится на следующую строку начиная с позиции первого символа шаблона', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21744';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Лишние символы отбрасываются, перенос строк не выполняется', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21744';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21745', 'Раздел: Автономные формы, Средний. Поля логической таблицы', 'Как связан список полей в секции полей логической таблицы (перед select) с секцией выборки (после select)?', TRUE, 'MEDIUM', 21745 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21745');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Поля логической таблицы', questiontext = 'Как связан список полей в секции полей логической таблицы (перед select) с секцией выборки (после select)?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21745 WHERE idnumber = 'moodle-q21745';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21745');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Поля можно перечислять в любом порядке, независимо от SELECT', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21745';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Список полей должен совпадать с началом списка полей секции описания выборки: первое поле секции именует первое поле выборки и т. д.', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21745';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'В секции полей логической таблицы допускаются только константы, но не поля SELECT', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21745';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21746', 'Раздел: Автономные формы, Средний. Порядок объявления переменных', 'Где в автономной форме должны быть объявлены переменные и массивы секции .var?', TRUE, 'MEDIUM', 21746 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21746');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Порядок объявления переменных', questiontext = 'Где в автономной форме должны быть объявлены переменные и массивы секции .var?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21746 WHERE idnumber = 'moodle-q21746';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21746');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'После первого шаблона вывода, непосредственно перед .endform', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21746';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'До описания полей, процедур, программных блоков, а также до первого шаблона', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21746';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Только внутри цикла по SQL-таблице', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21746';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21640', 'Раздел: Автономные формы, Средний. Синтаксические ошибки', 'Найдите синтаксические ошибки в форме и укажите их:

.form ''bdoc''
.ard
.var vids,t:string .endvar
create view as select basedoc.*,klval.*,katorg.* from basedoc, klval, katorg
where ((basedoc.cval==klval.nrec and basedoc.corg==katorg.nrec));
.fields basedoc.nodoc basedoc.name:''p:1'' basedoc.summa:''p:r''
klval.simvolv katorg.name vids t .endfields
.begin datetostr(tl.basedoc.dform,''''); end.
Номер Наименование Сумма Валюта Контрагент
.{
&&&&&&& @@@@@@@@@@@@ &&&&& ^ ^
.begin
vids:=''Счет'';
if basedoc.viddoc=201 then vids:=''счет - фактура'';
if basedoc.viddoc=501 then vids:=''заявка'';
t:=datetostr(basedoc.dform,'''');
end.
Вид документа: ^
.{?internal;t<>'''');
Дата формирования: ^
.}
.}
.endform', FALSE, 'MEDIUM', 21640 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21640');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Синтаксические ошибки', questiontext = 'Найдите синтаксические ошибки в форме и укажите их:

.form ''bdoc''
.ard
.var vids,t:string .endvar
create view as select basedoc.*,klval.*,katorg.* from basedoc, klval, katorg
where ((basedoc.cval==klval.nrec and basedoc.corg==katorg.nrec));
.fields basedoc.nodoc basedoc.name:''p:1'' basedoc.summa:''p:r''
klval.simvolv katorg.name vids t .endfields
.begin datetostr(tl.basedoc.dform,''''); end.
Номер Наименование Сумма Валюта Контрагент
.{
&&&&&&& @@@@@@@@@@@@ &&&&& ^ ^
.begin
vids:=''Счет'';
if basedoc.viddoc=201 then vids:=''счет - фактура'';
if basedoc.viddoc=501 then vids:=''заявка'';
t:=datetostr(basedoc.dform,'''');
end.
Вид документа: ^
.{?internal;t<>'''');
Дата формирования: ^
.}
.}
.endform', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21640 WHERE idnumber = 'moodle-q21640';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21640');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Не хватает точки в одном из ключевых слов', 0.3333333, 2 FROM mdl_question WHERE idnumber = 'moodle-q21640';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Не указано имя логической таблицы', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21640';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Неверное использование вложенного цикла', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21640';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Неверный синтаксис оператора IF', -1.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21640';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Неверен синтаксис цикла по логической таблице', 0.3333333, 6 FROM mdl_question WHERE idnumber = 'moodle-q21640';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Синтаксически неверная запись секции var... endVar', -1.0000000, 7 FROM mdl_question WHERE idnumber = 'moodle-q21640';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Синтаксически неверная запись одной из секций begin... end', -1.0000000, 8 FROM mdl_question WHERE idnumber = 'moodle-q21640';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21747', 'Раздел: Автономные формы, Средний. Состав секции .fields', 'Что, кроме полей логической таблицы, допускается указывать в секции .fields?', TRUE, 'MEDIUM', 21747 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21747');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Состав секции .fields', questiontext = 'Что, кроме полей логической таблицы, допускается указывать в секции .fields?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21747 WHERE idnumber = 'moodle-q21747';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21747');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Только имена полей таблиц словаря БД', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21747';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Имена полей таблиц словаря БД, переменные, константы или вычисляемые выражения', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21747';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Только обработчики событий FastReport', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21747';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21748', 'Раздел: Автономные формы, Средний. Форматирование шаблонов', 'Какие символы форматирования шаблонов соответствуют описанию курса (отчеты в формате бизнес-текст)?', FALSE, 'MEDIUM', 21748 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21748');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Форматирование шаблонов', questiontext = 'Какие символы форматирования шаблонов соответствуют описанию курса (отчеты в формате бизнес-текст)?', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21748 WHERE idnumber = 'moodle-q21748';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21748');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '&&&&&&.&& — задает количество знаков дробной части', 0.3333333, 2 FROM mdl_question WHERE idnumber = 'moodle-q21748';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '&''&&&&&&& — задает деление числа по разрядам', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21748';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '@#@@@@@@@ — задает центрирование значения внутри шаблона', 0.3333333, 4 FROM mdl_question WHERE idnumber = 'moodle-q21748';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '', 0.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21748';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Те же символы форматирования обязательны для RTF и SLK вместо встроенных средств редакторов', -1.0000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21748';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21681', 'Раздел: Автономные формы, Средний. Циклы с группировкой', 'Какие из перечисленных условий являются необходимыми для организации корректной работы циклов по логической таблице с группировкой данных в общем случае? Один из примеров формы — см. ниже.

.autoform ''primer''
.ard
.var
 state: comp;
.endvar
.create view sv as
select KatState.Name, KatCity.Name, Katorg.Name Where
(( KatState.nrec == KatCity.cState
And KatCity.nrec /== KatOrg.cCity (noindex) ))
and KatState.nrec=state order by KatCity.Name;
.begin
 runinterface(''L_KATORG::GETSTATE'', state)
end.
.fields
 KatState.Name KatCity.Name KatOrg.Name
.endfields
.{table ''sv.KatState''
СПИСОК ОРГАНИЗАЦИЙ ПО СТРАНЕ: ^
НАИМЕНОВАНИЕ ОРГАНИЗАЦИИ
.{table ''sv.KatCity''
Город: @@@@@@@@@@@@@@@@@@@@@@@@@
.{table ''sv.KatOrg''
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.}
.}
.}
.endform', FALSE, 'MEDIUM', 21681 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21681');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Автономные формы, Средний. Циклы с группировкой', questiontext = 'Какие из перечисленных условий являются необходимыми для организации корректной работы циклов по логической таблице с группировкой данных в общем случае? Один из примеров формы — см. ниже.

.autoform ''primer''
.ard
.var
 state: comp;
.endvar
.create view sv as
select KatState.Name, KatCity.Name, Katorg.Name Where
(( KatState.nrec == KatCity.cState
And KatCity.nrec /== KatOrg.cCity (noindex) ))
and KatState.nrec=state order by KatCity.Name;
.begin
 runinterface(''L_KATORG::GETSTATE'', state)
end.
.fields
 KatState.Name KatCity.Name KatOrg.Name
.endfields
.{table ''sv.KatState''
СПИСОК ОРГАНИЗАЦИЙ ПО СТРАНЕ: ^
НАИМЕНОВАНИЕ ОРГАНИЗАЦИИ
.{table ''sv.KatCity''
Город: @@@@@@@@@@@@@@@@@@@@@@@@@
.{table ''sv.KatOrg''
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.}
.}
.}
.endform', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21681 WHERE idnumber = 'moodle-q21681';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21681');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'отсутствие переменных в перечне выводимых в циклах полей', -1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21681';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'указание имен узлов в циклах по логической таблице', 0.5000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21681';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'вызов интерфейса с участием физической таблицы, по которой организован внешний цикл', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21681';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'физическая таблица, по которой организован вышестоящий цикл, должна быть родительской для таблицы, по которой организован вложенный цикл', 0.5000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21681';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'в перечне выводимых полей внутри каждого цикла должны быть поля только той физической таблицы, по которой он организован', -1.0000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21681';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21695', 'Раздел: Атлантис-SQL, Легкий. Начало SQL-предложения', 'С каких операторов может начинаться SQL-предложение в «Атлантис-SQL»?', FALSE, 'EASY', 21695 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21695');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Легкий. Начало SQL-предложения', questiontext = 'С каких операторов может начинаться SQL-предложение в «Атлантис-SQL»?', single_answer = FALSE, difficulty = 'EASY', source_question_id = 21695 WHERE idnumber = 'moodle-q21695';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21695');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'CREATE', 0.3333333, 2 FROM mdl_question WHERE idnumber = 'moodle-q21695';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'IMPORT', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21695';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'INSERT', 0.3333333, 4 FROM mdl_question WHERE idnumber = 'moodle-q21695';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'DEL', -1.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21695';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21696', 'Раздел: Атлантис-SQL, Легкий. Операторы реляционных отношений', 'Какие из перечисленных выражений являются операторами реляционных отношений?', FALSE, 'EASY', 21696 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21696');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Легкий. Операторы реляционных отношений', questiontext = 'Какие из перечисленных выражений являются операторами реляционных отношений?', single_answer = FALSE, difficulty = 'EASY', source_question_id = 21696 WHERE idnumber = 'moodle-q21696';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21696');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '/==', 0.3333333, 2 FROM mdl_question WHERE idnumber = 'moodle-q21696';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '==', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21696';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '<<>>', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21696';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '>>=', 0.3333333, 5 FROM mdl_question WHERE idnumber = 'moodle-q21696';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, '>>==', -1.0000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21696';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21701', 'Раздел: Атлантис-SQL, Легкий. Результат в окне OUTPUT', 'Какое из SQL-предложений вернет результат в виде набора записей в окне «OUTPUT» модуля «SQL. Доступ к БД» утилит Support?', TRUE, 'EASY', 21701 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21701');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Легкий. Результат в окне OUTPUT', questiontext = 'Какое из SQL-предложений вернет результат в виде набора записей в окне «OUTPUT» модуля «SQL. Доступ к БД» утилит Support?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21701 WHERE idnumber = 'moodle-q21701';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21701');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'create view LogTable аз select * from katmc;', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21701';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'select * from katorg to txt katorg.txt;', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21701';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'select katmc.*;', 1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21701';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'update katmc where kgroupmc = ''4301'' set massa = massa * 2;', 0.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21701';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21700', 'Раздел: Атлантис-SQL, Легкий. Сортировка на внешней выгрузке', 'В каких случаях, для указанного ниже запроса, сортировка будет выполняться на внешней выгрузке?

select KatOrg.Name, BaseDoc.Nodoc, BaseDoc.dDoc, BaseDoc.Total
From KatOrg, BaseDoc
Where ((
KatOrg.Nrec == BaseDoc.cOrg
and 101 == BaseDoc.vidDoc
))', FALSE, 'EASY', 21700 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21700');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Легкий. Сортировка на внешней выгрузке', questiontext = 'В каких случаях, для указанного ниже запроса, сортировка будет выполняться на внешней выгрузке?

select KatOrg.Name, BaseDoc.Nodoc, BaseDoc.dDoc, BaseDoc.Total
From KatOrg, BaseDoc
Where ((
KatOrg.Nrec == BaseDoc.cOrg
and 101 == BaseDoc.vidDoc
))', single_answer = FALSE, difficulty = 'EASY', source_question_id = 21700 WHERE idnumber = 'moodle-q21700';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21700');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'order by Katorg.Name', -1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21700';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'order by KatOrg.Name, BaseDoc.Nodoc', 0.5000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21700';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'order by KatOrg.Name, BaseDoc.dDoc', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21700';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'order by BaseDoc.Nodoc', 0.5000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21700';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21702', 'Раздел: Атлантис-SQL, Сложный. Параметры set impex', 'Какие параметры (в том числе и по умолчанию) будут установлены оператором

set impex txt justify=on quotas="*";', FALSE, 'HARD', 21702 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21702');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Сложный. Параметры set impex', questiontext = 'Какие параметры (в том числе и по умолчанию) будут установлены оператором

set impex txt justify=on quotas="*";', single_answer = FALSE, difficulty = 'HARD', source_question_id = 21702 WHERE idnumber = 'moodle-q21702';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21702');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'разделитель полей - *', -1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21702';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'выравнивание полей по столбцам', 0.5000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21702';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'вывод заголовков полей', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21702';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'формат даты DD/MM/YYYY', -1.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21702';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'значения строковых полей будут заключены в символы - *', 0.5000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21702';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21703', 'Раздел: Атлантис-SQL, Средний. Атрибут noIndex', 'Где происходит выборка при использовании атрибута NoIndex в описании реляционных отношений?', TRUE, 'MEDIUM', 21703 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21703');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Средний. Атрибут noIndex', questiontext = 'Где происходит выборка при использовании атрибута NoIndex в описании реляционных отношений?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21703 WHERE idnumber = 'moodle-q21703';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21703');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'на сервере', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21703';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'на клиенте', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21703';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21704', 'Раздел: Атлантис-SQL, Средний. Атрибуты открытия таблиц', 'Укажите верные атрибуты открытия таблиц (для SQL-предложения)?', FALSE, 'MEDIUM', 21704 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21704');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Средний. Атрибуты открытия таблиц', questiontext = 'Укажите верные атрибуты открытия таблиц (для SQL-предложения)?', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21704 WHERE idnumber = 'moodle-q21704';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21704');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'ReadOnly', 0.3333333, 2 FROM mdl_question WHERE idnumber = 'moodle-q21704';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'DropIndex', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21704';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Share', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21704';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Build', 0.3333333, 5 FROM mdl_question WHERE idnumber = 'moodle-q21704';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21706', 'Раздел: Атлантис-SQL, Средний. Группы операторов', 'Какие из перечисленных ниже групп операторов языка SQL присутствуют в «Атлантис-SQL»?', FALSE, 'MEDIUM', 21706 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21706');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Средний. Группы операторов', questiontext = 'Какие из перечисленных ниже групп операторов языка SQL присутствуют в «Атлантис-SQL»?', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21706 WHERE idnumber = 'moodle-q21706';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21706');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Data Definition Language', 0.5000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21706';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Data Control Language', -1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21706';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Data Manipulation Language', 0.5000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21706';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Cursor Control Language', -1.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21706';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21707', 'Раздел: Атлантис-SQL, Средний. Ошибки SQL-предложения', 'Какие ошибки допустил автор приведенного ниже SQL-предложения:

select katmc.*, kated.* order by name where ((katmc.ced == kated.nrec or 0 == katmc.ced (noindex) ));', FALSE, 'MEDIUM', 21707 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21707');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Средний. Ошибки SQL-предложения', questiontext = 'Какие ошибки допустил автор приведенного ниже SQL-предложения:

select katmc.*, kated.* order by name where ((katmc.ced == kated.nrec or 0 == katmc.ced (noindex) ));', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21707 WHERE idnumber = 'moodle-q21707';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21707');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Пропущена секция FROM.', -1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21707';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Используется ключевое слово OR в описании реляционных отношений.', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21707';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Нарушен порядок следования секций.', 0.3333333, 4 FROM mdl_question WHERE idnumber = 'moodle-q21707';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Некорректно определен порядок сортировки.', 0.3333333, 5 FROM mdl_question WHERE idnumber = 'moodle-q21707';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Неверно задана последовательность подцепок в секции WHERE', -1.0000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21707';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Неверно задана константа во втором условии подцепки в WHERE', -1.0000000, 7 FROM mdl_question WHERE idnumber = 'moodle-q21707';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21708', 'Раздел: Атлантис-SQL, Средний. Параметры импорта', 'Выберите предложения, соответствующие параметрам указанной операции импорта:

import kated from dbf edizm.dbf arrangeByType arrangeByName fullInfo skipOverflow rewriteForNRec;', FALSE, 'MEDIUM', 21708 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21708');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Средний. Параметры импорта', questiontext = 'Выберите предложения, соответствующие параметрам указанной операции импорта:

import kated from dbf edizm.dbf arrangeByType arrangeByName fullInfo skipOverflow rewriteForNRec;', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21708 WHERE idnumber = 'moodle-q21708';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21708');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'игнорирование лишних полей источника', 0.2000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21708';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'удаление файла-импортера', -1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21708';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'создание журнального файла', 0.2000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21708';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'сравнение полей по именам', 0.2000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21708';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'сравнение полей по типам', 0.2000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21708';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'обновление записей с существующим первичным ключом', 0.2000000, 7 FROM mdl_question WHERE idnumber = 'moodle-q21708';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21689', 'Раздел: Атлантис-SQL, Средний. Синтаксические ошибки выборки', 'Какие синтаксические ошибки допустил автор SQL-предложения при условии использования словаря, входящего в стандартную поставку системы «Галактика ERP»?

Select Groupmc.Name, Groupmc.Kod, Katmc.Name, +.Barkod, Kated.Name
From Groupmc Gmc
Where ((Katmc.Ced==Kated.Nrec and Groupmc.Nrec/==Katmc.Cgroupmc))
and Katmc.Cgroupmc==Gmc.Nrec
order D11_1 by Groupmc.Name
order Dl1_2 by Groupmc.Kod;', FALSE, 'MEDIUM', 21689 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21689');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Средний. Синтаксические ошибки выборки', questiontext = 'Какие синтаксические ошибки допустил автор SQL-предложения при условии использования словаря, входящего в стандартную поставку системы «Галактика ERP»?

Select Groupmc.Name, Groupmc.Kod, Katmc.Name, +.Barkod, Kated.Name
From Groupmc Gmc
Where ((Katmc.Ced==Kated.Nrec and Groupmc.Nrec/==Katmc.Cgroupmc))
and Katmc.Cgroupmc==Gmc.Nrec
order D11_1 by Groupmc.Name
order Dl1_2 by Groupmc.Kod;', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21689 WHERE idnumber = 'moodle-q21689';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21689');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'неверный синтаксис порядка сортировки', -1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21689';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'неверный синтаксис секции From', -1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21689';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'ошибка в перечислении', 0.5000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21689';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'неверный синтаксис ограничения на результат выборки', 0.5000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21689';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'используется таблица Gmc, которой нет в словаре', -1.0000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21689';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21709', 'Раздел: Атлантис-SQL, Средний. Элементы Atlantis-SQL', 'Какие из перечисленных элементов используются в «Atlantis-SQL»?', FALSE, 'MEDIUM', 21709 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21709');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Атлантис-SQL, Средний. Элементы Atlantis-SQL', questiontext = 'Какие из перечисленных элементов используются в «Atlantis-SQL»?', single_answer = FALSE, difficulty = 'MEDIUM', source_question_id = 21709 WHERE idnumber = 'moodle-q21709';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21709');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переключаемые поля', -1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21709';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переключаемые порядки сортировки', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21709';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переключаемые реляционные отношения', 0.3333333, 4 FROM mdl_question WHERE idnumber = 'moodle-q21709';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переключаемые ограничения', 0.3333333, 5 FROM mdl_question WHERE idnumber = 'moodle-q21709';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Переключаемые порядки группировки', -1.0000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21709';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21646', 'Раздел: Отчеты FastReport, Легкий. Добавление шаблона в ресурс', 'Как добавить шаблон FastReport-отчета в необходимый ресурс Галактика ERP?', TRUE, 'EASY', 21646 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21646');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Легкий. Добавление шаблона в ресурс', questiontext = 'Как добавить шаблон FastReport-отчета в необходимый ресурс Галактика ERP?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21646 WHERE idnumber = 'moodle-q21646';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21646');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'скомпилировать в определенный res-файл утилитой FRRes.exe', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21646';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'скомпилировать в определенный res-файл утилитой FREasyEdit.exe', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21646';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'добавить имя FastReport-шаблона в файл проекта', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21646';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21663', 'Раздел: Отчеты FastReport, Легкий. Назначение FastReport', 'Для чего предназначен FastReport?', TRUE, 'EASY', 21663 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21663');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Легкий. Назначение FastReport', questiontext = 'Для чего предназначен FastReport?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21663 WHERE idnumber = 'moodle-q21663';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21663');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'отправка отчета об ошибках на диагностику', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21663';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'создание отчетности', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21663';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'автоматическое заполнение полей ввода данными', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21663';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21664', 'Раздел: Отчеты FastReport, Легкий. Параметр дизайнера', 'Какой параметр блокирует доступ к FastReport-дизайнеру из Галактики ERP?', TRUE, 'EASY', 21664 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21664');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Легкий. Параметр дизайнера', questiontext = 'Какой параметр блокирует доступ к FastReport-дизайнеру из Галактики ERP?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21664 WHERE idnumber = 'moodle-q21664';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21664');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Fcenv', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21664';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'EnableVipDebuger', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21664';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'FROneReportMode', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21664';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21665', 'Раздел: Отчеты FastReport, Легкий. Режим дизайнера', 'Что необходимо для использования режима дизайнера FastReport в Галактике ERP?', FALSE, 'EASY', 21665 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21665');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Легкий. Режим дизайнера', questiontext = 'Что необходимо для использования режима дизайнера FastReport в Галактике ERP?', single_answer = FALSE, difficulty = 'EASY', source_question_id = 21665 WHERE idnumber = 'moodle-q21665';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21665');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'параметр Forms.Fcenv должен иметь значение True', 0.3333333, 2 FROM mdl_question WHERE idnumber = 'moodle-q21665';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'наличие лицензии на FastReport', 0.3333333, 3 FROM mdl_question WHERE idnumber = 'moodle-q21665';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'использовать утилиту FREasyEdit.exe из комплекта поставки Атлантис', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21665';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'вызвать функцию «[F4] Изменить» (при ее наличии) в списке отчетов FastReport', 0.3333333, 5 FROM mdl_question WHERE idnumber = 'moodle-q21665';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21666', 'Раздел: Отчеты FastReport, Легкий. Рекомендации по шаблону', 'Какие пункты рекомендуется учитывать при разработке FastReport-шаблона отчета?', FALSE, 'EASY', 21666 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21666');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Легкий. Рекомендации по шаблону', questiontext = 'Какие пункты рекомендуется учитывать при разработке FastReport-шаблона отчета?', single_answer = FALSE, difficulty = 'EASY', source_question_id = 21666 WHERE idnumber = 'moodle-q21666';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21666');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Исключить наложение объектов друг на друга', 0.5000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21666';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Использовать выносные линии', 0.5000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21666';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Использовать объект Линия для обрамления', -1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21666';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21667', 'Раздел: Отчеты FastReport, Легкий. Сохранение шаблона', 'Куда сохраняется шаблон FastReport-отчета, открытый из Галактики ERP, при нажатии в дизайнере кнопки «Сохранить»?', TRUE, 'EASY', 21667 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21667');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Легкий. Сохранение шаблона', questiontext = 'Куда сохраняется шаблон FastReport-отчета, открытый из Галактики ERP, при нажатии в дизайнере кнопки «Сохранить»?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21667 WHERE idnumber = 'moodle-q21667';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21667');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'в оперативную память', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21667';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'в пользовательский ресурс компиляции', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21667';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'в каталог исполняемых файлов Галактики ERP', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21667';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21668', 'Раздел: Отчеты FastReport, Сложный. ContinueDataset', 'Для чего предназначена функция ContinueDataset?', TRUE, 'HARD', 21668 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21668');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Сложный. ContinueDataset', questiontext = 'Для чего предназначена функция ContinueDataset?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21668 WHERE idnumber = 'moodle-q21668';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21668');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'сигнализирует генератору отчета о том, что необходимо выполнить проход следующего потока данных', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21668';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'сигнализирует генератору о том, что текущий элемент потока существует', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21668';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'для построения следующего FastReport-отчета', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21668';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21669', 'Раздел: Отчеты FastReport, Сложный. VIP-выражение', 'С помощью какой функции из FastReport-отчета можно выполнить VIP-выражение?', TRUE, 'HARD', 21669 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21669');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Сложный. VIP-выражение', questiontext = 'С помощью какой функции из FastReport-отчета можно выполнить VIP-выражение?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21669 WHERE idnumber = 'moodle-q21669';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21669');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'GalaxyOnClick', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21669';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'BlobToString', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21669';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'CompileVipExpression', 1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21669';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21670', 'Раздел: Отчеты FastReport, Сложный. Конструкция DataSet', 'Для чего предназначена конструкция DataSet?', TRUE, 'HARD', 21670 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21670');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Сложный. Конструкция DataSet', questiontext = 'Для чего предназначена конструкция DataSet?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21670 WHERE idnumber = 'moodle-q21670';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21670');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Для передачи данных из узлов логической таблицы интерфейса, при этом количество и порядок следования записей определяется логической таблицей', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21670';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'создает связь между XLT-шаблонами и логической таблицей', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21670';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'создает поток данных, алгоритм выборки которого задается программистом', 1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21670';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21671', 'Раздел: Отчеты FastReport, Сложный. Событие перед формированием отчета', 'Какое событие обработчика потока вызывается перед формированием отчета?', TRUE, 'HARD', 21671 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21671');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Сложный. Событие перед формированием отчета', questiontext = 'Какое событие обработчика потока вызывается перед формированием отчета?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21671 WHERE idnumber = 'moodle-q21671';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21671');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'cmOnProcess', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21671';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'cmPostProcess', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21671';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'cmPreProcess', 1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21671';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21672', 'Раздел: Отчеты FastReport, Сложный. Экспорт из VIP', 'С помощью какой функции выполняется экспорт FastReport-отчета из VIP-кода?', TRUE, 'HARD', 21672 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21672');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Сложный. Экспорт из VIP', questiontext = 'С помощью какой функции выполняется экспорт FastReport-отчета из VIP-кода?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21672 WHERE idnumber = 'moodle-q21672';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21672');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'FRPrepareReport', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21672';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'FRExportReport', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21672';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'FROpenReport', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21672';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21673', 'Раздел: Отчеты FastReport, Средний. Агрегатные функции', 'Поддерживает ли FastReport агрегатные функции?', TRUE, 'MEDIUM', 21673 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21673');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Средний. Агрегатные функции', questiontext = 'Поддерживает ли FastReport агрегатные функции?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21673 WHERE idnumber = 'moodle-q21673';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21673');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Да', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21673';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Нет', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21673';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21675', 'Раздел: Отчеты FastReport, Средний. Конструкция потока данных', 'Какая конструкция предназначена для создания потока данных?', TRUE, 'MEDIUM', 21675 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21675');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Средний. Конструкция потока данных', questiontext = 'Какая конструкция предназначена для создания потока данных?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21675 WHERE idnumber = 'moodle-q21675';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21675');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'DataStream', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21675';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'VipInterface', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21675';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'FRCreate', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21675';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21676', 'Раздел: Отчеты FastReport, Средний. Объект управления построением', 'Какой объект FastReport-шаблона управляет построением отчета?', TRUE, 'MEDIUM', 21676 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21676');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Средний. Объект управления построением', questiontext = 'Какой объект FastReport-шаблона управляет построением отчета?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21676 WHERE idnumber = 'moodle-q21676';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21676');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Report', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21676';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Engine', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21676';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'MemoView', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21676';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21677', 'Раздел: Отчеты FastReport, Средний. Передача данных логической таблицы', 'Как передать в FastReport-отчет данные логической таблицы?', TRUE, 'MEDIUM', 21677 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21677');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Средний. Передача данных логической таблицы', questiontext = 'Как передать в FastReport-отчет данные логической таблицы?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21677 WHERE idnumber = 'moodle-q21677';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21677');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'через sql-запрос', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21677';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'путем связывания логической таблицы и потока данных', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21677';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'с помощью компиляции данных в шаблон', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21677';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21678', 'Раздел: Отчеты FastReport, Средний. Поддержка unicode', 'Поддерживает ли FastReport unicode-строки?', TRUE, 'MEDIUM', 21678 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21678');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Средний. Поддержка unicode', questiontext = 'Поддерживает ли FastReport unicode-строки?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21678 WHERE idnumber = 'moodle-q21678';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21678');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Нет', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21678';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Да', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21678';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21679', 'Раздел: Отчеты FastReport, Средний. Событийный механизм', 'Поддерживает ли FastReport событийный механизм?', TRUE, 'MEDIUM', 21679 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21679');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Средний. Событийный механизм', questiontext = 'Поддерживает ли FastReport событийный механизм?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21679 WHERE idnumber = 'moodle-q21679';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21679');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Да', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21679';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Нет', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21679';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21680', 'Раздел: Отчеты FastReport, Средний. Что необходимо для создания отчетности', 'Что необходимо для создания FastReport-отчетности?', TRUE, 'MEDIUM', 21680 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21680');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Отчеты FastReport, Средний. Что необходимо для создания отчетности', questiontext = 'Что необходимо для создания FastReport-отчетности?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21680 WHERE idnumber = 'moodle-q21680';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21680');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'таблица в памяти, PAT-форма, утилита frf_to_fr3.exe', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21680';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'данные, форма-прототип, присоединенные формы', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21680';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'логическая таблица, поток данных, шаблон отчета', 1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21680';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21631', 'Раздел: Редактор отчетов FCOM, Легкий.  Завершение формирования отчета', 'С помощью какой функции из VIP можно аварийно завершить формирования отчета с последующим очищением файла отчета?', TRUE, 'EASY', 21631 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21631');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Легкий.  Завершение формирования отчета', questiontext = 'С помощью какой функции из VIP можно аварийно завершить формирования отчета с последующим очищением файла отчета?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21631 WHERE idnumber = 'moodle-q21631';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21631');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Exit', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21631';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'AbortForm', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21631';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Еrrоr', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21631';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21626', 'Раздел: Редактор отчетов FCOM, Легкий. Наличие формы-прототипа', 'В какой технологии формирования отчетности обязательно требуется наличие формы-прототипа?', TRUE, 'EASY', 21626 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21626');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Легкий. Наличие формы-прототипа', questiontext = 'В какой технологии формирования отчетности обязательно требуется наличие формы-прототипа?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21626 WHERE idnumber = 'moodle-q21626';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21626');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'OLAP', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21626';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'FastReport', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21626';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'FCOM', 1.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21626';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21625', 'Раздел: Редактор отчетов FCOM, Легкий. Ссылка на прототип', 'В какой конструкции шаблона отчета указывается ссылка на имя формы-прототипа для FCOM-технологии отчетности?', TRUE, 'EASY', 21625 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21625');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Легкий. Ссылка на прототип', questiontext = 'В какой конструкции шаблона отчета указывается ссылка на имя формы-прототипа для FCOM-технологии отчетности?', single_answer = TRUE, difficulty = 'EASY', source_question_id = 21625 WHERE idnumber = 'moodle-q21625';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21625');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'prototype is', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21625';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'loadRepFromDB', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21625';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'name is', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21625';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21628', 'Раздел: Редактор отчетов FCOM, Сложный.  Как в присоединенную форму поступают данные', 'Как в FCOM-технологии отчетности в присоединенную форму поступает поток данных?', TRUE, 'HARD', 21628 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21628');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Сложный.  Как в присоединенную форму поступают данные', questiontext = 'Как в FCOM-технологии отчетности в присоединенную форму поступает поток данных?', single_answer = TRUE, difficulty = 'HARD', source_question_id = 21628 WHERE idnumber = 'moodle-q21628';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21628');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'посредством конструкции DataStream', 0.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21628';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'из формы-прототипа', 1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21628';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'из логической таблицы интерфейса', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21628';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21623', 'Раздел: Редактор отчетов FCOM, Сложный. Сообщение компилятора', 'Что означает сообщение, полученное на этапе компиляции формы:

"Использование неинициализированного поля X из формы-прототипа FP в вычисляемом поле Y присоединенной формы FL"?', FALSE, 'HARD', 21623 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21623');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Сложный. Сообщение компилятора', questiontext = 'Что означает сообщение, полученное на этапе компиляции формы:

"Использование неинициализированного поля X из формы-прототипа FP в вычисляемом поле Y присоединенной формы FL"?', single_answer = FALSE, difficulty = 'HARD', source_question_id = 21623 WHERE idnumber = 'moodle-q21623';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21623');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'количество полей в форме прототипе не соответствует количеству полей в присоединенной форме', -1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21623';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'разработчик формы прототипа FP явно не проинициализировал поле X', -1.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21623';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'в момент вычисления поля Y в присоединенной форме поле X ещё не поступило в форму прототипа', 0.5000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21623';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'выполнение этой формы приведет к некорректным данным в отчёте', 0.5000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21623';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21629', 'Раздел: Редактор отчетов FCOM, Сложный. Фильтр видимости форм', 'С помощью какой функции из VIP можно управлять фильтром видимости форм?', FALSE, 'HARD', 21629 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21629');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Сложный. Фильтр видимости форм', questiontext = 'С помощью какой функции из VIP можно управлять фильтром видимости форм?', single_answer = FALSE, difficulty = 'HARD', source_question_id = 21629 WHERE idnumber = 'moodle-q21629';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21629');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'SetSoftSubgroup', 0.2500000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21629';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Form_SetSubgroup', 0.2500000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21629';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'SetGroup', 0.2500000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21629';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'SetSubgroup', 0.2500000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21629';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'SetFormName', -1.0000000, 6 FROM mdl_question WHERE idnumber = 'moodle-q21629';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21627', 'Раздел: Редактор отчетов FCOM, Средний.  Для чего присоединенная форма', 'Для чего предназначена присоединенная форма в FCOM-отчетности?', TRUE, 'MEDIUM', 21627 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21627');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Средний.  Для чего присоединенная форма', questiontext = 'Для чего предназначена присоединенная форма в FCOM-отчетности?', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21627 WHERE idnumber = 'moodle-q21627';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21627');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'создание разнообразных форм отчетов, отвечающих требованиям наибольшей наглядности, информативности, для одного потока данных и команд их использующих', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21627';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'автоматическое заполнение полей ввода данными', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21627';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'загрузка XLA-библиотек', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21627';

INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)
SELECT id, 'moodle-q21624', 'Раздел: Редактор отчетов FCOM, Средний. Что выведет данный отчет', 'Что выведет данный отчет?

.autoform ttt
.create view vvv from x$files, x$fields
where ((0 << xf$code and 3>>xf$code and xf$code==xe$filecode));
.var
 c: integer
.endvar
.{table ''vvv'' by vvv.x$files.xf$code;
.begin
 c := 0;
 end.
.{ by vvv.x$fields.xe$filecode;
.begin
 c++
 end.
.}
.fields
 xf$name
 c
.endfields
 В таблице ^ ^ полей
.}
.endform', TRUE, 'MEDIUM', 21624 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = 'moodle-q21624');
UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), name = 'Раздел: Редактор отчетов FCOM, Средний. Что выведет данный отчет', questiontext = 'Что выведет данный отчет?

.autoform ttt
.create view vvv from x$files, x$fields
where ((0 << xf$code and 3>>xf$code and xf$code==xe$filecode));
.var
 c: integer
.endvar
.{table ''vvv'' by vvv.x$files.xf$code;
.begin
 c := 0;
 end.
.{ by vvv.x$fields.xe$filecode;
.begin
 c++
 end.
.}
.fields
 xf$name
 c
.endfields
 В таблице ^ ^ полей
.}
.endform', single_answer = TRUE, difficulty = 'MEDIUM', source_question_id = 21624 WHERE idnumber = 'moodle-q21624';
DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = 'moodle-q21624');
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'В таблице X$FIELDS 16 полей
 В таблице X$FIELDS 10 полей', 1.0000000, 2 FROM mdl_question WHERE idnumber = 'moodle-q21624';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'В таблице X$FILES 16 полей
 В таблице X$FIELDS 10 полей', 0.0000000, 3 FROM mdl_question WHERE idnumber = 'moodle-q21624';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'В таблице X$FIELDS 26 полей', 0.0000000, 4 FROM mdl_question WHERE idnumber = 'moodle-q21624';
INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) SELECT id, 'Ничего из перечисленного', 0.0000000, 5 FROM mdl_question WHERE idnumber = 'moodle-q21624';

DELETE FROM mdl_quiz_slots WHERE quizid = (SELECT id FROM mdl_quiz WHERE idnumber = 'erp-reports-certification');
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 1, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q0';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 2, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21723';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 3, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21727';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 4, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21724';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 5, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21728';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 6, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21729';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 7, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21730';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 8, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21725';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 9, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21636';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 10, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21740';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 11, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21741';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 12, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21742';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 13, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21743';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 14, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21637';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 15, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21744';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 16, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21745';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 17, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21746';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 18, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21640';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 19, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21747';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 20, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21748';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 21, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21681';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 22, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21695';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 23, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21696';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 24, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21701';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 25, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21700';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 26, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21702';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 27, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21703';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 28, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21704';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 29, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21706';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 30, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21707';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 31, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21708';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 32, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21689';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 33, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21709';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 34, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21646';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 35, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21663';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 36, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21664';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 37, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21665';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 38, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21666';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 39, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21667';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 40, 2, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21668';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 41, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21669';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 42, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21670';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 43, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21671';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 44, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21672';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 45, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21673';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 46, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21675';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 47, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21676';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 48, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21677';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 49, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21678';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 50, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21679';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 51, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21680';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 52, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21631';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 53, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21626';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 54, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21625';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 55, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21628';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 56, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21623';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 57, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21629';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 58, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21627';
INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) SELECT quiz.id, 59, 3, question.id, 1 FROM mdl_quiz quiz, mdl_question question WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = 'moodle-q21624';
