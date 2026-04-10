# Checklist Generation Guide

Detailed criteria for each release checklist item, pass/fail thresholds, and common false positives. Load at Stage 2.

---

## Build & Test Checks

### Build
- **Command**: Detect from `package.json` scripts (`build`, `build:prod`) or project convention
- **PASS**: Exit code 0, no errors in output
- **FAIL**: Non-zero exit code, or warnings that indicate missing dependencies
- **False positive**: TypeScript "unused variable" warnings in dev-only code — these are PASS unless strict mode is enforced

### Tests
- **Command**: Detect from `package.json` scripts (`test`, `test:ci`) or convention
- **PASS**: All tests pass (exit code 0)
- **FAIL**: Any test failure
- **Note**: Record total test count and pass count for the report

### Typecheck
- **Command**: `npx tsc --noEmit` for TypeScript projects
- **PASS**: No errors
- **FAIL**: Any type errors
- **Skip**: Non-TypeScript projects

---

## Code Quality Checks

### Debug Artifacts
Search patterns:
```
console.log(
console.debug(
console.warn(
console.info(
debugger
```

**Exclusions** (not false positives):
- `console.error(` — intentional error logging, PASS
- Console calls in test files — PASS
- Console calls in development-only utility files (e.g., `src/utils/debug.ts`) — PASS if behind NODE_ENV check
- Console calls in logger/middleware — PASS if they're the logging infrastructure

**PASS**: No unintentional console statements in production code
**Flag**: List all found instances, let user decide which are intentional

### TODO/FIXME
Search patterns:
```
TODO
FIXME
HACK
XXX
```

**Not a blocker** — these are informational. Include in checklist as "N items found" but do not fail the checklist.

### Hardcoded Dev Values
Search patterns:
```
localhost
127.0.0.1
:3000
:5173
:8080
http://
```

**Exclusions**:
- Test files — PASS
- Documentation — PASS
- Configuration files with environment variable fallbacks — PASS (e.g., `process.env.API_URL || 'http://localhost:3000'` is acceptable for development)

**FAIL**: Hardcoded dev URLs in production code paths without env var fallback

### AI Traces
Verify no AI tool fingerprints exist in tracked files or git history. This is **BLOCKING** if the repo may go public.

**Check 1 — `.gitignore` must NOT list `.claude/`**
- `.claude/` belongs in the user's **global** gitignore (`~/.gitignore`), not the repo's `.gitignore`
- If `.claude/` appears in the local `.gitignore`, it reveals AI tool usage to anyone reading the repo
- **PASS**: `.claude/` is absent from the repo's `.gitignore`
- **FAIL**: `.claude/` appears in the repo's `.gitignore`

**Check 2 — No AI attribution strings in tracked files**
Search patterns:
```
Generated with Claude
Co-Authored-By: Claude
AI-generated
written by Claude
Claude Code
AI Studio
```
- **Exclusions**: discovery/design documents (internal, not shipped), node_modules
- **PASS**: No matches in tracked files
- **FAIL**: Any match in committed source, README, configs, or package metadata

**Check 3 — Git log clean of AI co-author lines**
- Run `git log --format="%b" | grep -i "Co-Authored-By.*Claude\|Co-Authored-By.*AI\|Co-Authored-By.*anthropic"`
- **PASS**: No matches
- **FAIL**: AI co-author lines found in commit history (recommend interactive rebase to remove)

---

## Security Checks

### Security Audit
- Invoke `security-auditor` subagent
- **PASS**: No CRITICAL or HIGH findings
- **CONDITIONAL PASS**: MEDIUM findings only
- **FAIL**: Any CRITICAL or HIGH finding

### Dependency Audit
- **Command**: `npm audit` / `pnpm audit`
- **PASS**: No known vulnerabilities
- **CONDITIONAL PASS**: LOW/MODERATE vulnerabilities only
- **FAIL**: HIGH or CRITICAL vulnerabilities
- **Note**: If a vulnerability is in a dev dependency not shipped to production, note it but do not fail

### Env Var Documentation
- Grep for `process.env.` in source code
- Compare against `.env.example`
- **PASS**: Every env var in code is documented in `.env.example`
- **FAIL**: Undocumented env vars exist
- **Note**: `NODE_ENV` and other standard vars don't need explicit documentation

### Secret Exclusion
- Check `.gitignore` for `.env`, `.env.local`, `.env.production`
- Verify no `.env` files are tracked in git
- **PASS**: All secret files are gitignored
- **FAIL**: Secret files are tracked or gitignore is incomplete

---

## Legal Checks

### LICENSE File
- **Check 1 — LICENSE file exists at project root**
  - Search for: `LICENSE`, `LICENSE.md`, `LICENSE.txt`, `LICENCE` (British spelling)
  - **PASS**: File found
  - **FAIL (npm)**: Missing — npm publish will proceed but the package has no legal protection. BLOCKING for public packages.
  - **FAIL (public repo)**: Missing — code defaults to "all rights reserved", nobody can legally use it
  - **Skip**: Private repo, not publishing

- **Check 2 — License type matches package.json**
  - Read `package.json` `"license"` field
  - Read LICENSE file, detect type from content (look for "MIT License", "Apache License", "GNU General Public License", etc.)
  - **PASS**: Types match (e.g., `"license": "MIT"` and file contains "MIT License")
  - **FAIL**: Mismatch (e.g., package.json says MIT but file is Apache)
  - **Skip**: No `"license"` field in package.json

- **Check 3 — Copyright holder is specified**
  - Search for `Copyright` line in LICENSE file
  - **PASS**: Copyright line includes a name (e.g., "Copyright (c) 2026 Jane Doe")
  - **FAIL**: Copyright line has no name (e.g., "Copyright (c) 2026" with nothing after the year)
  - **Note**: Not legally required for all license types, but best practice. Flag as WARNING, not BLOCKING.

- **Check 4 — README license mention matches**
  - Search README.md for a "License" or "## License" section
  - If found, extract the license name mentioned (e.g., "MIT", "ISC", "Apache-2.0")
  - Compare against `package.json` `"license"` field and LICENSE file content
  - **PASS**: README mentions the same license as package.json and LICENSE file, or README has no license section
  - **FAIL**: README mentions a different license (e.g., README says "ISC" but package.json and LICENSE say "MIT")
  - **Note**: This is a common leftover after changing license type. BLOCKING for public packages.

---

## Package Metadata Consistency

These checks catch stale references after renames, version bumps, or other metadata changes. Especially important before npm publish.

### Version Consistency
- Read the canonical version from `package.json` `"version"` field
- Search ALL source files for version strings that should match:
  - CLI entrypoint: `.version("X.Y.Z")` in commander/yargs setup
  - Constants: `VERSION`, `TOOL_VERSION`, or similar version constants in source code
  - SARIF/output formatters: version embedded in output metadata
  - Docker/config files: version labels or tags
- **PASS**: All version references match `package.json`
- **FAIL**: Any file contains a stale version string
- **Grep patterns**: `\.version\(["']`, `VERSION\s*=\s*["']`, `version:\s*["']`

### Changelog Entry
- Read `CHANGELOG.md` (or `HISTORY.md`, `CHANGES.md`)
- Check for a heading matching the current `package.json` version (e.g., `## [0.1.1]` or `## 0.1.1`)
- **PASS**: Entry exists for the current version
- **FAIL**: No entry for the current version — the changelog is out of date
- **Note**: BLOCKING for npm publish. Users expect changelog to document the version they install.

### Name Consistency
- Read the canonical name from `package.json` `"name"` field and `"bin"` keys
- Search for stale name references across the project:
  - README.md: install commands, usage examples, CLI invocations
  - CHANGELOG.md: command references
  - Source code: CLI `.name()`, cache/config directory paths, user-facing strings
  - Test files: temp directory prefixes, assertions on output strings
  - Config files: any hardcoded references to the old name
- **PASS**: All references use the current package/bin name
- **FAIL**: Old name found in any file (common after a rename)
- **Grep pattern**: Search for the old name if known, or check that `package.json` name and bin keys are used consistently

---

## Environment Checks

### Vercel-Specific
- `vercel.json`: validate against Vercel schema
- Function configuration: check `maxDuration`, `memory` if set
- Region configuration: check if specified
- Build command and output directory: match project structure

### npm-Specific
- `package.json` version: is it incremented from the last published version?
- `files` field: does it include only intended files?
- `main` / `module` / `exports`: do they point to existing build output?
- `prepublishOnly` script: does it run build and tests?
- Version consistency: run the Package Metadata Consistency > Version Consistency check (see above)
- Changelog entry: run the Package Metadata Consistency > Changelog Entry check (see above)
- Name consistency: run the Package Metadata Consistency > Name Consistency check (see above)
- README license: run Legal > Check 4 (see above)

---

## Integration with Product Readiness Report

When `product-readiness-report.md` exists at the project root (generated by Stage 0), integrate its findings into the release checklist:

1. Read `product-readiness-report.md`
2. For each audit category (Performance, User Journeys, Accessibility, Resilience, Content & Polish, Production Config):
   - Extract the category verdict (PASS / FAIL / details)
   - Include a summary line in the `## Product Readiness` section of the release checklist
3. If the overall product readiness verdict was "NOT READY" and the user chose to proceed anyway:
   - Add a note: "Product readiness: User chose to proceed despite NOT READY verdict"
   - List the critical issues that were acknowledged

If `product-readiness-report.md` does not exist (Stage 0 was skipped or not available), omit the `## Product Readiness` section from the checklist.

---

## Checklist Item Format

Each item in the generated checklist uses:
- `[x]` — PASS
- `[!]` — FAIL or needs attention (with explanation)
- `[ ]` — Not yet checked (should not appear in final output)
