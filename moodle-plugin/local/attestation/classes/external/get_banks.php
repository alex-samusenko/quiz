<?php
namespace local_attestation\external;

use core_external\external_function_parameters;
use core_external\external_multiple_structure;
use core_external\external_single_structure;
use core_external\external_value;

class get_banks extends base {
    public static function execute_parameters(): external_function_parameters {
        return new external_function_parameters([]);
    }

    public static function execute(): array {
        global $DB;
        self::require_access();
        $sql = "SELECT cm.id AS coursemoduleid, cm.idnumber, cm.course, qb.id AS qbankid,
                       qb.name, c.fullname AS coursename, ctx.id AS contextid
                  FROM {course_modules} cm
                  JOIN {modules} m ON m.id = cm.module AND m.name = 'qbank'
                  JOIN {qbank} qb ON qb.id = cm.instance
                  JOIN {course} c ON c.id = cm.course
                  JOIN {context} ctx ON ctx.contextlevel = :modulelevel AND ctx.instanceid = cm.id
                 WHERE " . $DB->sql_like('cm.idnumber', ':prefix', false) . "
              ORDER BY c.fullname, qb.name";
        $rows = $DB->get_records_sql($sql, [
            'modulelevel' => CONTEXT_MODULE,
            'prefix' => 'attestation-bank:%',
        ]);
        return array_values(array_map(static function($row) {
            $row->code = substr($row->idnumber, strlen('attestation-bank:'));
            return $row;
        }, $rows));
    }

    public static function execute_returns(): external_multiple_structure {
        return new external_multiple_structure(new external_single_structure([
            'coursemoduleid' => new external_value(PARAM_INT, 'Qbank course module id'),
            'idnumber' => new external_value(PARAM_RAW, 'Integration marker'),
            'code' => new external_value(PARAM_ALPHANUMEXT, 'Stable attestation bank code'),
            'course' => new external_value(PARAM_INT, 'Course id'),
            'qbankid' => new external_value(PARAM_INT, 'Qbank instance id'),
            'name' => new external_value(PARAM_TEXT, 'Qbank name'),
            'coursename' => new external_value(PARAM_TEXT, 'Course name'),
            'contextid' => new external_value(PARAM_INT, 'Module context id'),
        ]));
    }
}
