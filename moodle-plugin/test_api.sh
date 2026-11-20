#!/usr/bin/env bash
set -euo pipefail
set -a
. /home/samusenko/attestation-service.env
set +a
base='http://127.0.0.1/webservice/rest/server.php'
call_api() {
  curl -sS -H 'Host: oldlms.galaktika.ru' -G "$base" \
    --data-urlencode "wstoken=$TOKEN" \
    --data-urlencode 'moodlewsrestformat=json' "$@"
}
call_api --data-urlencode 'wsfunction=local_attestation_ping' > /var/tmp/attestation-ping.json
call_api --data-urlencode 'wsfunction=local_attestation_search_users' \
  --data-urlencode 'query=zzzznotfound' --data-urlencode 'limit=5' > /var/tmp/attestation-users.json
call_api --data-urlencode 'wsfunction=local_attestation_get_quizzes' > /var/tmp/attestation-quizzes.json
python3 - <<'PY'
import json
from pathlib import Path
p = json.loads(Path('/var/tmp/attestation-ping.json').read_text())
u = json.loads(Path('/var/tmp/attestation-users.json').read_text())
q = json.loads(Path('/var/tmp/attestation-quizzes.json').read_text())
print('PING', p)
print('USERS_EMPTY', len(u) if isinstance(u, list) else u)
print('QUIZZES', len(q) if isinstance(q, list) else q)
if isinstance(q, list) and q:
    Path('/var/tmp/attestation-first-quiz-id').write_text(str(q[0]['id']))
PY
if [[ -f /var/tmp/attestation-first-quiz-id ]]; then
  quizid="$(cat /var/tmp/attestation-first-quiz-id)"
  call_api --data-urlencode 'wsfunction=local_attestation_get_questions' \
    --data-urlencode "quizid=$quizid" > /var/tmp/attestation-questions.json
  python3 - <<'PY'
import json
from pathlib import Path
q = json.loads(Path('/var/tmp/attestation-questions.json').read_text())
print('QUESTIONS', len(q) if isinstance(q, list) else q)
PY
fi
