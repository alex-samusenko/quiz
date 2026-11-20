<?php
namespace local_attestation\external;

use core_external\external_function_parameters;
use core_external\external_single_structure;
use core_external\external_value;

class ping extends base {
    public static function execute_parameters(): external_function_parameters {
        return new external_function_parameters([]);
    }

    public static function execute(): array {
        global $CFG;
        self::require_access();
        return ['status' => 'ok', 'release' => $CFG->release, 'branch' => $CFG->branch];
    }

    public static function execute_returns(): external_single_structure {
        return new external_single_structure([
            'status' => new external_value(PARAM_ALPHA, 'Integration status'),
            'release' => new external_value(PARAM_TEXT, 'Moodle release'),
            'branch' => new external_value(PARAM_ALPHANUM, 'Moodle branch'),
        ]);
    }
}
