<?php
define('CLI_SCRIPT', true);
require('/opt/moodle/public/config.php');
global $DB;

$cmid = 5890;
$contextid = 11520;
$categoryids = [1166, 1170];

$cm = $DB->get_record_sql("SELECT cm.id, cm.course, cm.instance, cm.visible, m.name AS modulename
                              FROM {course_modules} cm
                              JOIN {modules} m ON m.id = cm.module
                             WHERE cm.id = ?", [$cmid]);
$context = $DB->get_record('context', ['id' => $contextid]);
$categories = [];
foreach ($categoryids as $categoryid) {
    $category = $DB->get_record('question_categories', ['id' => $categoryid]);
    if (!$category) {
        $categories[] = ['id' => $categoryid, 'missing' => true];
        continue;
    }
    $total = $DB->count_records('question_bank_entries', ['questioncategoryid' => $categoryid]);
    $ready = $DB->count_records_sql("SELECT COUNT(DISTINCT qbe.id)
                                      FROM {question_bank_entries} qbe
                                      JOIN {question_versions} qv ON qv.questionbankentryid = qbe.id
                                     WHERE qbe.questioncategoryid = ? AND qv.status = 'ready'", [$categoryid]);
    $categories[] = ['id' => (int)$category->id, 'name' => $category->name,
        'parent' => (int)$category->parent, 'contextid' => (int)$category->contextid,
        'entries' => $total, 'readyentries' => $ready];
}

echo json_encode([
    'coursemodule' => $cm ? ['id' => (int)$cm->id, 'course' => (int)$cm->course,
        'instance' => (int)$cm->instance, 'visible' => (bool)$cm->visible,
        'module' => $cm->modulename] : null,
    'context' => $context ? ['id' => (int)$context->id, 'contextlevel' => (int)$context->contextlevel,
        'instanceid' => (int)$context->instanceid, 'path' => $context->path] : null,
    'categories' => $categories,
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . PHP_EOL;
