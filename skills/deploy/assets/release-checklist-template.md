# Release Checklist — {version or date}

**Project:** {project name}
**Target:** {deployment target}
**Date:** {YYYY-MM-DD}

---

## Build & Test

- [ ] Build: {command} → {PASS/FAIL}
- [ ] Tests: {command} → {PASS/FAIL} ({passed}/{total})
- [ ] Typecheck: {command} → {PASS/FAIL}

## Code Quality

- [ ] No debug artifacts: {PASS / N items found}
- [ ] No hardcoded dev values: {PASS / N items found}
- [ ] TODO/FIXME items: {N items} (informational)

## AI Traces

- [ ] No `.claude/` in local `.gitignore`: {PASS/FAIL}
- [ ] No AI attribution in tracked files: {PASS / N items found}
- [ ] No AI co-author lines in git log: {PASS / N found}

## Security

- [ ] Security audit: {PASS / N findings by severity}
- [ ] Dependency audit: {PASS / N vulnerabilities}
- [ ] Env vars documented: {PASS / N undocumented}
- [ ] Secrets excluded from git: {PASS/FAIL}

## Legal

- [ ] LICENSE file exists: {PASS / MISSING}
- [ ] License matches package.json: {PASS / MISMATCH / N/A}
- [ ] README license matches: {PASS / MISMATCH / N/A (no license section in README)}
- [ ] Copyright holder specified: {PASS / MISSING NAME}

## Package Metadata Consistency

- [ ] Version consistent across all files: {PASS / MISMATCH — list stale files}
- [ ] Changelog entry exists for current version: {PASS / MISSING}
- [ ] Package/bin name consistent across all files: {PASS / N stale references found}

## Environment

- [ ] Env var coverage: {PASS / N missing}
- [ ] Platform config valid: {PASS/FAIL}

## Product Readiness

{Include this section when product-readiness-report.md exists}

- [ ] Performance: {Good/Needs Work/Poor} — LCP {X}s, CLS {X}, JS {X}KB
- [ ] User Journeys: {N}/5 passed
- [ ] Accessibility: {N}/5 areas clear
- [ ] Resilience: {N}/6 tests passed
- [ ] Content & Polish: {N}/10 items checked
- [ ] Production Config: {N}/8 items verified
- [ ] Overall Verdict: {READY / NOT READY / READY WITH CAVEATS}

{If NOT READY and user proceeded: "User acknowledged {N} critical issues and chose to proceed."}

## Pipeline Status

- [ ] All phases complete
- [ ] All qa reports: PASS or CONDITIONAL PASS

## Outstanding Items

{Items from CONDITIONAL PASS qa reports, if any}

## Fixes Included

{Entries from fix-log.md since last deploy, if any}

---

**Overall Status:** {READY / NOT READY — {reason}}
