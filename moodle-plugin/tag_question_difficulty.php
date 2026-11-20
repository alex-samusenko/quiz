<?php
define('CLI_SCRIPT', true);
require('/opt/moodle/public/config.php');

global $DB, $USER;
$USER = get_admin();
$apply = in_array('--apply', $argv, true);
$idnumber = 'attestation-bank:erp-hr-personnel';
$mapping = ['5.0000000' => 'difficulty:easy', '7.0000000' => 'difficulty:medium',
    '10.0000000' => 'difficulty:hard'];

$bank = $DB->get_record_sql("SELECT cm.id, ctx.id AS contextid
                               FROM {course_modules} cm
                               JOIN {modules} m ON m.id = cm.module AND m.name = 'qbank'
                               JOIN {context} ctx ON ctx.contextlevel = ? AND ctx.instanceid = cm.id
                              WHERE cm.idnumber = ?", [CONTEXT_MODULE, $idnumber], MUST_EXIST);
$context = context::instance_by_id($bank->contextid, MUST_EXIST);
$categories = $DB->get_records('question_categories', ['contextid' => $bank->contextid]);
[$insql, $params] = $DB->get_in_or_equal(array_keys($categories), SQL_PARAMS_NAMED, 'cat');
$questions = $DB->get_records_sql("SELECT q.id, q.defaultmark, q.name
                                      FROM {question_bank_entries} qbe
                                      JOIN {question_categories} qc ON qc.id = qbe.questioncategoryid
                                      JOIN {question_versions} qv ON qv.questionbankentryid = qbe.id
                                      JOIN {question} q ON q.id = qv.questionid
                                     WHERE qc.id $insql AND qv.status = 'ready'
                                       AND qv.version = (SELECT MAX(v2.version) FROM {question_versions} v2
                                                          WHERE v2.questionbankentryid = qbe.id
                                                            AND v2.status = 'ready')", $params);

$counts = ['difficulty:easy' => 0, 'difficulty:medium' => 0, 'difficulty:hard' => 0];
$already = 0;
$unknown = [];
$conflicts = [];
$changes = [];
foreach ($questions as $question) {
    $mark = number_format((float)$question->defaultmark, 7, '.', '');
    if (!isset($mapping[$mark])) {
        $unknown[] = ['id' => (int)$question->id, 'mark' => $mark];
        continue;
    }
    $expected = $mapping[$mark];
    $counts[$expected]++;
    $tags = core_tag_tag::get_item_tags('core_question', 'question', $question->id);
    $names = array_values(array_map(static fn($tag) => $tag->rawname ?: $tag->name, $tags));
    $difficulty = array_values(array_filter($names, static fn($name) => str_starts_with($name, 'difficulty:')));
    if (in_array($expected, $difficulty, true)) {
        $already++;
        continue;
    }
    if ($difficulty) {
        $conflicts[] = ['id' => (int)$question->id, 'expected' => $expected, 'actual' => $difficulty];
        continue;
    }
    $changes[] = ['question' => $question, 'tags' => array_merge($names, [$expected])];
}

echo json_encode(['mode' => $apply ? 'apply' : 'dry-run', 'questions' => count($questions),
    'distribution' => $counts, 'alreadyTagged' => $already, 'toTag' => count($changes),
    'unknownMarks' => $unknown, 'conflicts' => $conflicts], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . PHP_EOL;

if (!$apply) exit(0);
if ($unknown || $conflicts) {
    fwrite(STDERR, "Aborted: unknown marks or conflicting difficulty tags found.\n");
    exit(2);
}
foreach ($changes as $change) {
    core_tag_tag::set_item_tags('core_question', 'question', $change['question']->id,
        $context, $change['tags'], $USER->id);
}
echo "Tagged " . count($changes) . " questions.\n";
