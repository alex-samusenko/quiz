# local_attestation

Read-only Moodle 5.1 integration plugin for the external attestation application.

It exposes a restricted custom web service with four functions:

- `local_attestation_ping`
- `local_attestation_search_users`
- `local_attestation_get_quizzes`
- `local_attestation_get_questions`

The service user must receive the `local/attestation:read` capability and be added to the
`Attestation integration` external service. Do not use an administrator token in production.
