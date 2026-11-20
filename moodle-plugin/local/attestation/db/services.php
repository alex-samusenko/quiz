<?php
defined('MOODLE_INTERNAL') || die();

$functions = [
    'local_attestation_ping' => [
        'classname' => 'local_attestation\\external\\ping',
        'description' => 'Checks the attestation integration and Moodle version.',
        'type' => 'read',
        'capabilities' => 'local/attestation:read',
    ],
    'local_attestation_search_users' => [
        'classname' => 'local_attestation\\external\\search_users',
        'description' => 'Searches active confirmed Moodle users by name, username, or email prefix.',
        'type' => 'read',
        'capabilities' => 'local/attestation:read',
    ],
    'local_attestation_get_quizzes' => [
        'classname' => 'local_attestation\\external\\get_quizzes',
        'description' => 'Returns visible Moodle quizzes.',
        'type' => 'read',
        'capabilities' => 'local/attestation:read',
    ],
    'local_attestation_get_questions' => [
        'classname' => 'local_attestation\\external\\get_questions',
        'description' => 'Returns the latest ready questions referenced by a quiz.',
        'type' => 'read',
        'capabilities' => 'local/attestation:read',
    ],
    'local_attestation_get_banks' => [
        'classname' => 'local_attestation\\external\\get_banks',
        'description' => 'Returns qbank activities explicitly marked as attestation banks.',
        'type' => 'read',
        'capabilities' => 'local/attestation:read',
    ],
    'local_attestation_get_bank_questions' => [
        'classname' => 'local_attestation\\external\\get_bank_questions',
        'description' => 'Returns latest ready questions from an attestation qbank context.',
        'type' => 'read',
        'capabilities' => 'local/attestation:read',
    ],
];

$services = [
    'Attestation integration' => [
        'functions' => array_keys($functions),
        'restrictedusers' => 1,
        'enabled' => 1,
        'shortname' => 'local_attestation_service',
    ],
];
