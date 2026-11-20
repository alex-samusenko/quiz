#!/usr/bin/env bash
set -euo pipefail
set -a; . /home/samusenko/attestation-service.env; set +a
base='http://127.0.0.1/webservice/rest/server.php'
python3 - <<'PY' > /var/tmp/attestation-quiz-ids
import json
for row in json.load(open('/var/tmp/attestation-quizzes.json'))[:30]:
    print(row['id'])
PY
tested=0
while read -r quizid; do
  curl -sS -H 'Host: oldlms.galaktika.ru' -G "$base" \
    --data-urlencode "wstoken=$TOKEN" --data-urlencode 'moodlewsrestformat=json' \
    --data-urlencode 'wsfunction=local_attestation_get_questions' \
    --data-urlencode "quizid=$quizid" > /var/tmp/attestation-scan-result.json
  summary=$(python3 - <<'PY'
import json
r=json.load(open('/var/tmp/attestation-scan-result.json'))
print(('ERROR:' + r.get('errorcode','unknown')) if isinstance(r,dict) else str(len(r)))
PY
)
  echo "QUIZ=$quizid QUESTIONS=$summary"
  tested=$((tested + 1))
  if [[ "$summary" != "0" && "$summary" != ERROR:* ]]; then exit 0; fi
  [[ $tested -ge 30 ]] && break
done < /var/tmp/attestation-quiz-ids
