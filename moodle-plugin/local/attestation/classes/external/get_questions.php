<?php
namespace local_attestation\external;

use core_external\external_function_parameters;
use core_external\external_multiple_structure;
use core_external\external_single_structure;
use core_external\external_value;

class get_questions extends base {
    public static function execute_parameters(): external_function_parameters {
        return new external_function_parameters(['quizid' => new external_value(PARAM_INT, 'Quiz id')]);
    }

    public static function execute(int $quizid): array {
        global $DB;
        ['quizid' => $quizid] = self::validate_parameters(self::execute_parameters(), compact('quizid'));
        self::require_access();
        $quiz = $DB->get_record('quiz', ['id' => $quizid], '*', MUST_EXIST);
        $sql = "SELECT qs.slot, q.id, q.name, q.questiontext, q.questiontextformat, q.qtype,
                       q.defaultmark, qv.version, qv.status, qc.name AS category
                  FROM {quiz_slots} qs
                  JOIN {question_references} qr ON qr.component = 'mod_quiz'
                       AND qr.questionarea = 'slot' AND qr.itemid = qs.id
                  JOIN {question_bank_entries} qbe ON qbe.id = qr.questionbankentryid
                  JOIN {question_versions} qv ON qv.questionbankentryid = qbe.id
                  JOIN {question} q ON q.id = qv.questionid
                  JOIN {question_categories} qc ON qc.id = qbe.questioncategoryid
                 WHERE qs.quizid = :quizid
                   AND qv.version = (SELECT MAX(v2.version) FROM {question_versions} v2
                                      WHERE v2.questionbankentryid = qbe.id AND v2.status = 'ready')
              ORDER BY qs.slot";
        $questions = $DB->get_records_sql($sql, ['quizid' => $quizid]);
        $result = [];
        foreach ($questions as $question) {
            $answers = [];
            if (in_array($question->qtype, ['multichoice', 'truefalse'], true)) {
                foreach ($DB->get_records('question_answers', ['question' => $question->id], 'id') as $answer) {
                    $answers[] = ['id' => (int)$answer->id, 'answer' => $answer->answer,
                        'fraction' => (float)$answer->fraction];
                }
            }
            $result[] = ['slot' => (int)$question->slot, 'id' => (int)$question->id,
                'name' => $question->name, 'text' => $question->questiontext,
                'qtype' => $question->qtype, 'defaultmark' => (float)$question->defaultmark,
                'version' => (int)$question->version, 'status' => $question->status,
                'category' => $question->category, 'answersjson' => json_encode($answers, JSON_UNESCAPED_UNICODE)];
        }
        return $result;
    }

    public static function execute_returns(): external_multiple_structure {
        return new external_multiple_structure(new external_single_structure([
            'slot' => new external_value(PARAM_INT, 'Quiz slot'), 'id' => new external_value(PARAM_INT, 'Question id'),
            'name' => new external_value(PARAM_TEXT, 'Question name'), 'text' => new external_value(PARAM_RAW, 'Question text'),
            'qtype' => new external_value(PARAM_ALPHANUMEXT, 'Question type'), 'defaultmark' => new external_value(PARAM_FLOAT, 'Default mark'),
            'version' => new external_value(PARAM_INT, 'Version'), 'status' => new external_value(PARAM_ALPHA, 'Version status'),
            'category' => new external_value(PARAM_TEXT, 'Category'), 'answersjson' => new external_value(PARAM_RAW, 'JSON encoded answers'),
        ]));
    }
}
