<?php
namespace local_attestation\external;

use core_external\external_function_parameters;
use core_external\external_multiple_structure;
use core_external\external_single_structure;
use core_external\external_value;

class get_bank_questions extends base {
    public static function execute_parameters(): external_function_parameters {
        return new external_function_parameters([
            'bankcode' => new external_value(PARAM_ALPHANUMEXT, 'Code after attestation-bank prefix'),
        ]);
    }

    public static function execute(string $bankcode): array {
        global $DB;
        ['bankcode' => $bankcode] = self::validate_parameters(self::execute_parameters(), compact('bankcode'));
        self::require_access();
        $sql = "SELECT cm.id, ctx.id AS contextid
                  FROM {course_modules} cm
                  JOIN {modules} m ON m.id = cm.module AND m.name = 'qbank'
                  JOIN {context} ctx ON ctx.contextlevel = :modulelevel AND ctx.instanceid = cm.id
                 WHERE cm.idnumber = :idnumber";
        $bank = $DB->get_record_sql($sql, ['modulelevel' => CONTEXT_MODULE,
            'idnumber' => 'attestation-bank:' . $bankcode], MUST_EXIST);
        $categories = $DB->get_records('question_categories', ['contextid' => $bank->contextid], 'id');
        if (!$categories) return [];
        [$insql, $params] = $DB->get_in_or_equal(array_keys($categories), SQL_PARAMS_NAMED, 'cat');
        $questionsql = "SELECT q.id, q.name, q.questiontext, q.questiontextformat, q.qtype,
                              q.defaultmark, qv.version, qv.status, qc.id AS categoryid,
                              qc.name AS category, qc.parent AS categoryparent
                         FROM {question_bank_entries} qbe
                         JOIN {question_categories} qc ON qc.id = qbe.questioncategoryid
                         JOIN {question_versions} qv ON qv.questionbankentryid = qbe.id
                         JOIN {question} q ON q.id = qv.questionid
                        WHERE qc.id $insql AND qv.status = 'ready'
                          AND qv.version = (SELECT MAX(v2.version) FROM {question_versions} v2
                                             WHERE v2.questionbankentryid = qbe.id AND v2.status = 'ready')
                     ORDER BY qc.name, q.name, q.id";
        $questions = $DB->get_records_sql($questionsql, $params);
        $result = [];
        foreach ($questions as $question) {
            $answers = [];
            if (in_array($question->qtype, ['multichoice', 'truefalse'], true)) {
                foreach ($DB->get_records('question_answers', ['question' => $question->id], 'id') as $answer) {
                    $answers[] = ['id' => (int)$answer->id, 'answer' => $answer->answer,
                        'fraction' => (float)$answer->fraction];
                }
            }
            $result[] = ['id' => (int)$question->id, 'name' => $question->name,
                'text' => $question->questiontext, 'qtype' => $question->qtype,
                'defaultmark' => (float)$question->defaultmark, 'version' => (int)$question->version,
                'status' => $question->status, 'categoryid' => (int)$question->categoryid,
                'category' => $question->category, 'categoryparent' => (int)$question->categoryparent,
                'tagsjson' => json_encode(array_values(array_map(
                    static fn($tag) => $tag->rawname ?: $tag->name,
                    \core_tag_tag::get_item_tags('core_question', 'question', $question->id)
                )), JSON_UNESCAPED_UNICODE),
                'answersjson' => json_encode($answers, JSON_UNESCAPED_UNICODE)];
        }
        return $result;
    }

    public static function execute_returns(): external_multiple_structure {
        return new external_multiple_structure(new external_single_structure([
            'id' => new external_value(PARAM_INT, 'Question id'), 'name' => new external_value(PARAM_TEXT, 'Question name'),
            'text' => new external_value(PARAM_RAW, 'Question text'), 'qtype' => new external_value(PARAM_ALPHANUMEXT, 'Question type'),
            'defaultmark' => new external_value(PARAM_FLOAT, 'Default mark'), 'version' => new external_value(PARAM_INT, 'Version'),
            'status' => new external_value(PARAM_ALPHA, 'Version status'), 'categoryid' => new external_value(PARAM_INT, 'Category id'),
            'category' => new external_value(PARAM_TEXT, 'Category'), 'categoryparent' => new external_value(PARAM_INT, 'Parent category id'),
            'tagsjson' => new external_value(PARAM_RAW, 'JSON encoded question tags'),
            'answersjson' => new external_value(PARAM_RAW, 'JSON encoded answers'),
        ]));
    }
}
