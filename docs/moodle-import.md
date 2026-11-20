# Перенос банка вопросов из Moodle

Приложение использует минимальную Moodle-подобную схему из
`src/main/resources/db/moodle-question-bank.sql`. При старте она создаётся
автоматически. Демонстрационные вопросы загружаются скриптом
`src/main/resources/db/moodle-question-seed.sql`.

Реальный проверочный пример хранится отдельно в
`src/main/resources/db/moodle-real-topic-autonomous-forms.sql`: это вопросы уровня
«Легкий» темы «Автономные формы» из курса Moodle 375, категории 1785.

## Прямой импорт из PostgreSQL Moodle 4.x/5.x

1. Подключите реальную базу как отдельную схему `moodle_source`. Это можно
   сделать дампом нужных таблиц или через `postgres_fdw`.
2. Откройте `docs/moodle-import-postgresql.sql`.
3. Заполните таблицу управления `attestation.moodle_quiz_import`, указав ID
   нужных тестов из настоящей `mdl_quiz`.
4. Выполните оставшуюся часть скрипта и проверьте итоговый запрос в конце.

Пример выбора тестов в Moodle:

```sql
SELECT id, course, name, timelimit, grade
FROM mdl_quiz
ORDER BY course, name;
```

Пример настройки импорта:

```sql
INSERT INTO attestation.moodle_quiz_import
    (source_quiz_id, target_code, mentor_username)
VALUES
    (42, 'java-certification', 'mentor'),
    (57, 'product-admin', 'petrov');
```

Скрипт импортирует обычные вопросы типа `multichoice`, включая одиночный и
множественный выбор. Случайные вопросы, вычисляемые вопросы, embedded answers,
файлы и изображения пока намеренно не переносятся.

## Если Moodle работает на MySQL/MariaDB

Сначала выгрузите перечисленные таблицы в PostgreSQL-схему `moodle_source`:

- `mdl_quiz`;
- `mdl_quiz_slots`;
- `mdl_question_categories`;
- `mdl_question_bank_entries`;
- `mdl_question_versions`;
- `mdl_question_references`;
- `mdl_question`;
- `mdl_qtype_multichoice_options`;
- `mdl_question_answers`.

Удобно использовать `pgloader`, CSV или временную PostgreSQL-базу. После
загрузки применяется тот же `moodle-import-postgresql.sql`. Такой двухэтапный
вариант безопаснее прямой записи в рабочую базу Moodle: исходные таблицы
остаются только источником чтения.

## Ограничения модели

- Сложность вопроса не является стандартным полем Moodle, поэтому импорт
  устанавливает `MEDIUM`. Её можно изменить после импорта.
- HTML очищается регулярным выражением. Это исключает XSS, но изображения и
  сложное форматирование не сохраняются.
- Автор теста в стандартной `mdl_quiz` отсутствует, поэтому преподаватель
  задаётся через `mentor_username` в таблице управления импортом.
- Запрос рассчитан на новую версионную модель банка Moodle 4.0 и новее.
  Для Moodle 3.11 и старше нужен отдельный запрос без `question_versions` и
  `question_references`.
