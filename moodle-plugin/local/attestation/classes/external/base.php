<?php
namespace local_attestation\external;

defined('MOODLE_INTERNAL') || die();

abstract class base extends \core_external\external_api {
    protected static function require_access(): void {
        $context = \context_system::instance();
        self::validate_context($context);
        require_capability('local/attestation:read', $context);
    }
}
