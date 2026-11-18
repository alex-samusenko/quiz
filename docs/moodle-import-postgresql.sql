-- Импорт тестов из Moodle 4.x/5.x в локальный банк приложения.
-- Предположение: таблицы реального Moodle доступны в схеме moodle_source,
-- а таблицы приложения находятся в public. Измените имена схем при необходимости.
-- Скрипт рассчитан на PostgreSQL и импортирует только вопросы multichoice.

BEGIN;

CREATE SCHEMA IF NOT EXISTS attestation;

-- Явно перечислите тесты, которые разрешено импортировать.
-- source_quiz_id берётся из moodle_source.mdl_quiz.id.
CREATE TABLE IF NOT EXISTS attestation.moodle_quiz_import (
    source_quiz_id BIGINT PRIMARY KEY,
    target_code VARCHAR(100) NOT NULL UNIQUE,
    mentor_username VARCHAR(100),
    enabled BOOLEAN NOT NULL DEFAULT TRUE
);

-- Пример настройки (сначала замените идентификатор и логин):
-- INSERT INTO attestation.moodle_quiz_import (source_quiz_id, target_code, mentor_username)
-- VALUES (42, 'java-certification', 'mentor')
-- ON CONFLICT (source_quiz_id) DO UPDATE
-- SET target_code = EXCLUDED.target_code, mentor_username = EXCLUDED.mentor_username;

INSERT INTO public.mdl_question_categories (idnumber, name, contextid, info, sortorder)
SELECT DISTINCT
       'moodle-category-' || source_category.id,
       source_category.name,
       source_category.contextid,
       source_category.info,
       source_category.sortorder
FROM moodle_source.mdl_question_categories source_category
JOIN moodle_source.mdl_question_bank_entries bank_entry
  ON bank_entry.questioncategoryid = source_category.id
JOIN moodle_source.mdl_question_versions question_version
  ON question_version.questionbankentryid = bank_entry.id
JOIN moodle_source.mdl_question source_question
  ON source_question.id = question_version.questionid
WHERE source_question.qtype = 'multichoice'
ON CONFLICT (idnumber) DO UPDATE
SET name = EXCLUDED.name,
    contextid = EXCLUDED.contextid,
    info = EXCLUDED.info,
    sortorder = EXCLUDED.sortorder;

INSERT INTO public.mdl_quiz (
    course, idnumber, name, intro, created_by, timelimit, grade,
    visible, source_quiz_id, timecreated, timemodified
)
SELECT source_quiz.course,
       import.target_code,
       source_quiz.name,
       source_quiz.intro,
       target_mentor.id,
       source_quiz.timelimit,
       source_quiz.grade,
       TRUE,
       source_quiz.id,
       source_quiz.timecreated,
       source_quiz.timemodified
FROM attestation.moodle_quiz_import import
JOIN moodle_source.mdl_quiz source_quiz ON source_quiz.id = import.source_quiz_id
LEFT JOIN public.mdl_user target_mentor ON target_mentor.username = import.mentor_username
WHERE import.enabled
ON CONFLICT (idnumber) DO UPDATE
SET name = EXCLUDED.name,
    intro = EXCLUDED.intro,
    created_by = EXCLUDED.created_by,
    timelimit = EXCLUDED.timelimit,
    grade = EXCLUDED.grade,
    source_quiz_id = EXCLUDED.source_quiz_id,
    timemodified = EXCLUDED.timemodified;

-- Для ссылки с version IS NULL Moodle использует последнюю готовую версию.
WITH resolved_questions AS (
    SELECT DISTINCT
           source_question.id source_question_id,
           question_version.version,
           question_version.status,
           bank_entry.questioncategoryid source_category_id,
           source_question.name,
           source_question.questiontext,
           source_question.questiontextformat,
           source_question.defaultmark,
           source_question.timecreated,
           source_question.timemodified,
           multichoice.single
    FROM attestation.moodle_quiz_import import
    JOIN moodle_source.mdl_quiz_slots source_slot
      ON source_slot.quizid = import.source_quiz_id
    JOIN moodle_source.mdl_question_references reference
      ON reference.itemid = source_slot.id
     AND reference.component = 'mod_quiz'
     AND reference.questionarea = 'slot'
    JOIN moodle_source.mdl_question_bank_entries bank_entry
      ON bank_entry.id = reference.questionbankentryid
    JOIN LATERAL (
        SELECT candidate.*
        FROM moodle_source.mdl_question_versions candidate
        WHERE candidate.questionbankentryid = bank_entry.id
          AND (reference.version IS NULL OR candidate.version = reference.version)
        ORDER BY candidate.version DESC
        LIMIT 1
    ) question_version ON TRUE
    JOIN moodle_source.mdl_question source_question
      ON source_question.id = question_version.questionid
    JOIN moodle_source.mdl_qtype_multichoice_options multichoice
      ON multichoice.questionid = source_question.id
    WHERE import.enabled
      AND source_question.qtype = 'multichoice'
      AND question_version.status = 'ready'
)
INSERT INTO public.mdl_question (
    category, idnumber, name, questiontext, questiontextformat, qtype,
    single_answer, difficulty, defaultmark, status, version,
    source_question_id, timecreated, timemodified
)
SELECT target_category.id,
       'moodle-question-' || source.source_question_id,
       source.name,
       regexp_replace(source.questiontext, '<[^>]*>', '', 'g'),
       source.questiontextformat,
       'multichoice',
       source.single <> 0,
       'MEDIUM',
       source.defaultmark,
       source.status,
       source.version,
       source.source_question_id,
       source.timecreated,
       source.timemodified
FROM resolved_questions source
JOIN public.mdl_question_categories target_category
  ON target_category.idnumber = 'moodle-category-' || source.source_category_id
ON CONFLICT (idnumber) DO UPDATE
SET category = EXCLUDED.category,
    name = EXCLUDED.name,
    questiontext = EXCLUDED.questiontext,
    questiontextformat = EXCLUDED.questiontextformat,
    single_answer = EXCLUDED.single_answer,
    defaultmark = EXCLUDED.defaultmark,
    status = EXCLUDED.status,
    version = EXCLUDED.version,
    timemodified = EXCLUDED.timemodified;

-- Ответы безопаснее полностью пересобрать: их идентификаторы и порядок могли измениться.
DELETE FROM public.mdl_question_answers target_answer
USING public.mdl_question target_question
WHERE target_answer.question = target_question.id
  AND target_question.source_question_id IS NOT NULL
  AND EXISTS (
      SELECT 1
      FROM moodle_source.mdl_question_answers source_answer
      WHERE source_answer.question = target_question.source_question_id
  );

INSERT INTO public.mdl_question_answers (
    question, answer, answerformat, fraction, feedback, answer_order
)
SELECT target_question.id,
       regexp_replace(source_answer.answer, '<[^>]*>', '', 'g'),
       source_answer.answerformat,
       source_answer.fraction,
       source_answer.feedback,
       ROW_NUMBER() OVER (PARTITION BY source_answer.question ORDER BY source_answer.id)
FROM public.mdl_question target_question
JOIN moodle_source.mdl_question_answers source_answer
  ON source_answer.question = target_question.source_question_id
WHERE target_question.source_question_id IS NOT NULL;

DELETE FROM public.mdl_quiz_slots target_slot
USING public.mdl_quiz target_quiz
WHERE target_slot.quizid = target_quiz.id
  AND target_quiz.source_quiz_id IS NOT NULL;

WITH resolved_slots AS (
    SELECT import.target_code,
           source_slot.slot,
           source_slot.page,
           source_slot.maxmark,
           source_question.id source_question_id
    FROM attestation.moodle_quiz_import import
    JOIN moodle_source.mdl_quiz_slots source_slot
      ON source_slot.quizid = import.source_quiz_id
    JOIN moodle_source.mdl_question_references reference
      ON reference.itemid = source_slot.id
     AND reference.component = 'mod_quiz'
     AND reference.questionarea = 'slot'
    JOIN LATERAL (
        SELECT candidate.questionid
        FROM moodle_source.mdl_question_versions candidate
        WHERE candidate.questionbankentryid = reference.questionbankentryid
          AND (reference.version IS NULL OR candidate.version = reference.version)
        ORDER BY candidate.version DESC
        LIMIT 1
    ) question_version ON TRUE
    JOIN moodle_source.mdl_question source_question
      ON source_question.id = question_version.questionid
    WHERE import.enabled AND source_question.qtype = 'multichoice'
)
INSERT INTO public.mdl_quiz_slots (quizid, slot, page, questionid, maxmark)
SELECT target_quiz.id, source.slot, source.page, target_question.id, source.maxmark
FROM resolved_slots source
JOIN public.mdl_quiz target_quiz ON target_quiz.idnumber = source.target_code
JOIN public.mdl_question target_question
  ON target_question.source_question_id = source.source_question_id
ON CONFLICT (quizid, slot) DO UPDATE
SET page = EXCLUDED.page,
    questionid = EXCLUDED.questionid,
    maxmark = EXCLUDED.maxmark;

COMMIT;

-- Контроль после импорта:
SELECT quiz.idnumber, quiz.name, COUNT(slot.id) question_count
FROM public.mdl_quiz quiz
LEFT JOIN public.mdl_quiz_slots slot ON slot.quizid = quiz.id
GROUP BY quiz.id, quiz.idnumber, quiz.name
ORDER BY quiz.name;
