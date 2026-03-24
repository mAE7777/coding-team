# Sensitivity Verification Heuristics

Domain-specific checks for HIGH-sensitivity tasks. Load at Stage 4 when `sensitivity: HIGH`.

| Domain Keywords | Verify |
|----------------|--------|
| auth, token, session, credential, password | Token expiry enforced, session invalidation on logout, CSRF protection, no secrets in client bundles, failed auth rate-limited |
| permission, role | Default-deny, privilege escalation paths tested, role checks on both client and server |
| payment, billing | Idempotency keys on charges, amount validation server-side, partial failure handling, no price from client |
| delete (destructive) | Soft-delete or confirmation flow, cascade effects documented, undo path if specified |
| migrate (data) | Rollback plan exists, data integrity check post-migration, no silent data loss |
| encrypt, decrypt, secret | No hardcoded keys, key rotation path, encryption at rest + transit |
| CORS | Allowlist-based origins, no wildcard in production, preflight cached |
