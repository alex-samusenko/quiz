<?php
define('CLI_SCRIPT', true);
require('/opt/moodle/public/config.php');
global $DB;
$user = $DB->get_record('user', ['username' => 'attestation_service', 'mnethostid' => $CFG->mnet_localhost_id], '*', MUST_EXIST);
$DB->set_field('user', 'auth', 'manual', ['id' => $user->id]);
$DB->set_field('user', 'password', hash_internal_user_password(random_string(64)), ['id' => $user->id]);
echo "Service user authentication repaired.\n";
