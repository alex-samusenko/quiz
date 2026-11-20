<?php
namespace local_attestation\external;

use core_external\external_function_parameters;
use core_external\external_multiple_structure;
use core_external\external_single_structure;
use core_external\external_value;

class get_quizzes extends base {
    public static function execute_parameters(): external_function_parameters {
        return new external_function_parameters([]);
    }

    public static function execute(): array {
        global $DB;
        self::require_access();
        $sql = "SELECT q.id, q.course, q.name, q.intro, q.timelimit, q.timeopen, q.timeclose,
                       cm.id AS coursemoduleid, c.fullname AS coursename
                  FROM {quiz} q
                  JOIN {course} c ON c.id = q.course
                  JOIN {modules} m ON m.name = 'quiz'
                  JOIN {course_modules} cm ON cm.module = m.id AND cm.instance = q.id
                 WHERE cm.visible = 1 AND q.course <> 1
              ORDER BY c.fullname, q.name";
        return array_values($DB->get_records_sql($sql));
    }

    public static function execute_returns(): external_multiple_structure {
        return new external_multiple_structure(new external_single_structure([
            'id' => new external_value(PARAM_INT, 'Quiz id'), 'course' => new external_value(PARAM_INT, 'Course id'),
            'name' => new external_value(PARAM_TEXT, 'Quiz name'), 'intro' => new external_value(PARAM_RAW, 'Description'),
            'timelimit' => new external_value(PARAM_INT, 'Time limit'), 'timeopen' => new external_value(PARAM_INT, 'Open time'),
            'timeclose' => new external_value(PARAM_INT, 'Close time'), 'coursemoduleid' => new external_value(PARAM_INT, 'Course module id'),
            'coursename' => new external_value(PARAM_TEXT, 'Course name'),
        ]));
    }
}
