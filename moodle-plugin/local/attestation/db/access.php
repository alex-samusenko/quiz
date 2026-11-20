<?php
defined('MOODLE_INTERNAL') || die();

$capabilities = [
    'local/attestation:read' => [
        'captype' => 'read',
        'contextlevel' => CONTEXT_SYSTEM,
        'archetypes' => ['manager' => CAP_ALLOW],
    ],
];
