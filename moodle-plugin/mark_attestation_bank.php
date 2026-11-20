<?php
define('CLI_SCRIPT', true);
require('/opt/moodle/public/config.php');
global $DB;

$cmid = 5890;
$idnumber = 'attestation-bank:erp-hr-personnel';
$cm = $DB->get_record_sql("SELECT cm.id, cm.idnumber, m.name AS modulename
                             FROM {course_modules} cm
                             JOIN {modules} m ON m.id = cm.module
                            WHERE cm.id = ?", [$cmid], MUST_EXIST);
if ($cm->modulename !== 'qbank') {
    throw new moodle_exception('Course module 5890 is not qbank');
}
$DB->set_field('course_modules', 'idnumber', $idnumber, ['id' => $cmid]);
rebuild_course_cache($DB->get_field('course_modules', 'course', ['id' => $cmid]), true);
echo "Marked qbank cmid={$cmid} as {$idnumber}.\n";
