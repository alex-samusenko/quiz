<?php
namespace local_attestation\external;

use core_external\external_function_parameters;
use core_external\external_multiple_structure;
use core_external\external_single_structure;
use core_external\external_value;

class search_users extends base {
    public static function execute_parameters(): external_function_parameters {
        return new external_function_parameters([
            'query' => new external_value(PARAM_TEXT, 'Name, username, or email prefix'),
            'limit' => new external_value(PARAM_INT, 'Maximum number of rows', VALUE_DEFAULT, 20),
        ]);
    }

    public static function execute(string $query, int $limit = 20): array {
        global $DB;
        ['query' => $query, 'limit' => $limit] = self::validate_parameters(self::execute_parameters(), compact('query', 'limit'));
        self::require_access();
        $query = trim($query);
        if (\core_text::strlen($query) < 2) return [];
        $limit = max(1, min(50, $limit));
        $like = $DB->sql_like('LOWER(' . $DB->sql_concat('firstname', "' '", 'lastname') . ')', ':fullname', false)
            . ' OR ' . $DB->sql_like('LOWER(' . $DB->sql_concat('lastname', "' '", 'firstname') . ')', ':reverse', false)
            . ' OR ' . $DB->sql_like('LOWER(username)', ':username', false)
            . ' OR ' . $DB->sql_like('LOWER(email)', ':email', false);
        $prefix = \core_text::strtolower($query) . '%';
        $sql = "SELECT id, username, firstname, lastname, email, institution, department, timezone
                  FROM {user}
                 WHERE deleted = 0 AND suspended = 0 AND confirmed = 1 AND ($like)
              ORDER BY lastname, firstname, username";
        return array_values($DB->get_records_sql($sql, ['fullname' => $prefix, 'reverse' => $prefix,
            'username' => $prefix, 'email' => $prefix], 0, $limit));
    }

    public static function execute_returns(): external_multiple_structure {
        return new external_multiple_structure(new external_single_structure([
            'id' => new external_value(PARAM_INT, 'User id'), 'username' => new external_value(PARAM_RAW, 'Username'),
            'firstname' => new external_value(PARAM_TEXT, 'First name'), 'lastname' => new external_value(PARAM_TEXT, 'Last name'),
            'email' => new external_value(PARAM_RAW, 'Email'), 'institution' => new external_value(PARAM_TEXT, 'Institution', VALUE_OPTIONAL),
            'department' => new external_value(PARAM_TEXT, 'Department', VALUE_OPTIONAL), 'timezone' => new external_value(PARAM_TEXT, 'Timezone'),
        ]));
    }
}
