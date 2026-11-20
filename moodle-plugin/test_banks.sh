#!/usr/bin/env bash
set -euo pipefail
set -a; . /home/samusenko/attestation-service.env; set +a
base='http://127.0.0.1/webservice/rest/server.php'
call_api() {
  curl -sS -H 'Host: oldlms.galaktika.ru' -G "$base" \
    --data-urlencode "wstoken=$TOKEN" --data-urlencode 'moodlewsrestformat=json' "$@"
}
call_api --data-urlencode 'wsfunction=local_attestation_get_banks' > /var/tmp/attestation-banks.json
call_api --data-urlencode 'wsfunction=local_attestation_get_bank_questions' \
  --data-urlencode 'bankcode=erp-hr-personnel' > /var/tmp/attestation-bank-questions.json
python3 - <<'PY'
import collections, json
banks=json.load(open('/var/tmp/attestation-banks.json'))
questions=json.load(open('/var/tmp/attestation-bank-questions.json'))
if isinstance(banks, dict):
    print('BANK_ERROR', banks)
else:
    print('BANKS', len(banks), [(b.get('code'), b.get('coursemoduleid'), b.get('contextid')) for b in banks])
if isinstance(questions, dict):
    print('QUESTION_ERROR', questions)
else:
    print('QUESTIONS', len(questions))
    print('CATEGORIES', dict(collections.Counter(q.get('category') for q in questions)))
    print('MARKS', dict(collections.Counter(str(q.get('defaultmark')) for q in questions)))
    print('STATUSES', dict(collections.Counter(q.get('status') for q in questions)))
    print('QTYPES', dict(collections.Counter(q.get('qtype') for q in questions)))
    markers=collections.Counter()
    for q in questions:
        name=(q.get('name') or '').lower().replace('ё','е')
        found=False
        for marker in ('легкий','средний','сложный'):
            if marker in name:
                markers[marker]+=1; found=True
        if not found: markers['без маркера']+=1
    print('NAME_MARKERS', dict(markers))
PY
rm -f /var/tmp/attestation-banks.json /var/tmp/attestation-bank-questions.json
