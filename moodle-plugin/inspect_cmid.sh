#!/usr/bin/env bash
set -euo pipefail
set -a; . /home/samusenko/attestation-service.env; set +a
base='http://127.0.0.1/webservice/rest/server.php'
curl -sS -H 'Host: oldlms.galaktika.ru' -G "$base" \
  --data-urlencode "wstoken=$TOKEN" --data-urlencode 'moodlewsrestformat=json' \
  --data-urlencode 'wsfunction=local_attestation_get_quizzes' > /var/tmp/attestation-cmid-quizzes.json
python3 - <<'PY'
import json
rows=json.load(open('/var/tmp/attestation-cmid-quizzes.json'))
matched=[r for r in rows if r.get('coursemoduleid') == 5890]
for r in matched:
    print(json.dumps({k:r.get(k) for k in ('id','course','name','coursemoduleid','coursename')}, ensure_ascii=False))
if not matched:
    print('CMID_NOT_FOUND')
PY
