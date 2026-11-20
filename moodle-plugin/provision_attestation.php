<?php
define('CLI_SCRIPT', true);
require('/opt/moodle/public/config.php');
require_once($CFG->dirroot . '/user/lib.php');
require_once($CFG->libdir . '/accesslib.php');

global $DB, $USER;
$USER = get_admin();
$context = context_system::instance();

set_config('enablewebservices', 1);
$protocols = array_filter(explode(',', (string)get_config('core', 'webserviceprotocols')));
if (!in_array('rest', $protocols, true)) {
    $protocols[] = 'rest';
    set_config('webserviceprotocols', implode(',', $protocols));
}

$username = 'attestation_service';
$user = $DB->get_record('user', ['username' => $username, 'mnethostid' => $CFG->mnet_localhost_id]);
if (!$user) {
    $record = (object)[
        'auth' => 'manual',
        'confirmed' => 1,
        'mnethostid' => $CFG->mnet_localhost_id,
        'username' => $username,
        'firstname' => 'Attestation',
        'lastname' => 'Service',
        'email' => 'attestation-service@localhost.invalid',
        'lang' => 'ru',
        'timezone' => 'Europe/Moscow',
    ];
    $record->password = random_string(64);
    $record->id = user_create_user($record, true, false);
    $user = $DB->get_record('user', ['id' => $record->id], '*', MUST_EXIST);
}
$DB->set_field('user', 'auth', 'manual', ['id' => $user->id]);
if (empty($user->password) || $user->password === 'not cached') {
    $DB->set_field('user', 'password', hash_internal_user_password(random_string(64)), ['id' => $user->id]);
}

$roleshortname = 'attestation_service';
$role = $DB->get_record('role', ['shortname' => $roleshortname]);
if (!$role) {
    $roleid = create_role('Attestation service', $roleshortname,
        'Read-only role for the external attestation application.');
    $role = $DB->get_record('role', ['id' => $roleid], '*', MUST_EXIST);
}
assign_capability('local/attestation:read', CAP_ALLOW, $role->id, $context->id, true);
role_assign($role->id, $user->id, $context->id);

$service = $DB->get_record('external_services', ['shortname' => 'local_attestation_service'], '*', MUST_EXIST);
if (!$DB->record_exists('external_services_users', ['externalserviceid' => $service->id, 'userid' => $user->id])) {
    $DB->insert_record('external_services_users', (object)[
        'externalserviceid' => $service->id,
        'userid' => $user->id,
        'iprestriction' => '',
        'validuntil' => 0,
        'timecreated' => time(),
    ]);
}

$existing = $DB->get_record('external_tokens', [
    'externalserviceid' => $service->id,
    'userid' => $user->id,
    'tokentype' => EXTERNAL_TOKEN_PERMANENT,
]);
if ($existing) {
    echo "Token already exists for {$username}. Revoke it in Moodle before generating another.\n";
    exit(2);
}

$token = \core_external\util::generate_token(
    EXTERNAL_TOKEN_PERMANENT,
    $service,
    $user->id,
    $context,
    0,
    '',
    'Attestation application'
);

echo "SERVICE_USER={$username}\n";
echo "SERVICE_ID={$service->id}\n";
echo "TOKEN={$token}\n";
