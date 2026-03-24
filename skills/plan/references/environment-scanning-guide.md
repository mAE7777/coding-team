# Environment Scanning Guide

Command matrix and strategy for detecting tools, runtimes, and versions during the feat workflow.

---

## Three-Layer Scanning Strategy

### Layer 1: Design-Driven Scan
Scan for every tool, runtime, framework, and service explicitly mentioned in the user's design document. This is the primary scan — if the design says "Next.js", check for Next.js.

### Layer 2: Project-Driven Scan
If the project directory already exists, examine manifest files for existing dependencies:

| Manifest File | Ecosystem | Parse For |
|--------------|-----------|-----------|
| `package.json` | Node.js | dependencies, devDependencies, engines, scripts |
| `requirements.txt` | Python | Package names and version pins |
| `pyproject.toml` | Python | dependencies, build system |
| `Cargo.toml` | Rust | dependencies, dev-dependencies |
| `go.mod` | Go | require directives |
| `Gemfile` | Ruby | gem declarations |
| `composer.json` | PHP | require, require-dev |

### Layer 3: Common Tools Scan
Always check these regardless of design content:

- **Git**: Required for virtually all projects
- **OS info**: macOS version, architecture (arm64/x86_64)
- **Primary runtime**: Node.js for JS/TS projects, Python for Python projects, etc.
- **Primary package manager**: npm/yarn/pnpm for Node, pip for Python, etc.

---

## Detection Command Matrix

### Runtimes

| Tool | Detection Command | Version Command | Notes |
|------|-------------------|-----------------|-------|
| Node.js | `which node` | `node -v` | Output: `v20.11.0` |
| Python 3 | `which python3` | `python3 --version` | Output: `Python 3.12.0` |
| Bun | `which bun` | `bun --version` | Output: `1.0.25` |
| Deno | `which deno` | `deno --version` | Multi-line output |
| Ruby | `which ruby` | `ruby --version` | Output: `ruby 3.2.0` |
| Go | `which go` | `go version` | Output: `go version go1.21.0 darwin/arm64` |
| Rust | `which rustc` | `rustc --version` | Output: `rustc 1.75.0` |
| Java | `which java` | `java --version` | Multi-line output |
| PHP | `which php` | `php --version` | Multi-line output |

### Package Managers

| Tool | Detection Command | Version Command | Notes |
|------|-------------------|-----------------|-------|
| npm | `which npm` | `npm -v` | Output: `10.2.4` |
| yarn | `which yarn` | `yarn -v` | Classic: `1.22.x`, Berry: `4.x` |
| pnpm | `which pnpm` | `pnpm -v` | Output: `8.14.0` |
| pip | `which pip3` | `pip3 --version` | Output includes path |
| cargo | `which cargo` | `cargo --version` | Output: `cargo 1.75.0` |
| composer | `which composer` | `composer --version` | Output: `Composer version 2.x` |
| bundler | `which bundle` | `bundle --version` | Output: `Bundler version 2.x` |

### Version Control

| Tool | Detection Command | Version Command | Notes |
|------|-------------------|-----------------|-------|
| Git | `which git` | `git --version` | Output: `git version 2.43.0` |
| Git LFS | `which git-lfs` | `git-lfs --version` | For large file support |

### Package Name Availability (npm)

If the project will be published to npm (detected by: `"bin"`, `"main"`, `"exports"` in package.json, or design document mentions npm publish), validate the package name **before any code is written**:

| Check | Command | Notes |
|-------|---------|-------|
| Name taken? | `npm view {name}` | 404 = possibly available, but NOT guaranteed |
| Similarity rejection? | `npm publish --dry-run` | Catches npm's typosquatting protection (e.g., `reviewkit` rejected because `review-kit` exists). This is the only reliable check. |
| Scoped alternative | `@{scope}/{name}` | Scoped names avoid similarity conflicts entirely |

**Why this matters early**: Package name appears in `package.json`, CLI bin name, README install instructions, config/cache directory paths, SARIF tool identifiers, and documentation. Discovering a name conflict at deploy time forces a rename across all of these — a multi-file, multi-commit pain that is entirely avoidable.

**If name is rejected**: Resolve immediately with `AskUserQuestion` — present the rejection reason and ask for an alternative name before proceeding with phase planning. All downstream phases will use the validated name.

---

### Deployment & Infrastructure

| Tool | Detection Command | Version Command | Notes |
|------|-------------------|-----------------|-------|
| Docker | `which docker` | `docker --version` | Output: `Docker version 24.0.7` |
| Docker Compose | `which docker-compose` | `docker-compose --version` | May be `docker compose` (v2) |
| Vercel CLI | `which vercel` | `vercel --version` | Output: `33.0.0` |
| Netlify CLI | `which netlify` | `netlify --version` | Output: `netlify-cli/17.x` |
| Firebase CLI | `which firebase` | `firebase --version` | Output: `13.x.x` |
| AWS CLI | `which aws` | `aws --version` | Output: `aws-cli/2.x.x` |
| Fly.io | `which fly` | `fly version` | Output: `flyctl v0.x.x` |
| Railway | `which railway` | `railway --version` | Output: `3.x.x` |
| Terraform | `which terraform` | `terraform --version` | Multi-line output |
| kubectl | `which kubectl` | `kubectl version --client` | JSON output |

### Databases

| Tool | Detection Command | Version Command | Notes |
|------|-------------------|-----------------|-------|
| PostgreSQL | `which psql` | `psql --version` | Client version |
| MySQL | `which mysql` | `mysql --version` | Client version |
| MongoDB | `which mongosh` | `mongosh --version` | Modern shell |
| Redis | `which redis-cli` | `redis-cli --version` | Output: `redis-cli 7.x.x` |
| SQLite | `which sqlite3` | `sqlite3 --version` | Usually pre-installed on macOS |

### Frameworks (Project-Local)

These are typically installed per-project, not globally. Check via `npx` or project manifests.

| Tool | Detection Approach | Version Command | Notes |
|------|-------------------|-----------------|-------|
| Next.js | Check `package.json` | `npx next --version` | Only in project dir |
| Vite | Check `package.json` | `npx vite --version` | Only in project dir |
| Remix | Check `package.json` | Check `package.json` version | No CLI version command |
| Astro | Check `package.json` | `npx astro --version` | Only in project dir |
| SvelteKit | Check `package.json` | Check `package.json` version | No CLI version command |
| Django | Check `requirements.txt` | `python3 -m django --version` | Only in venv |
| Flask | Check `requirements.txt` | `python3 -c "import flask; print(flask.__version__)"` | Only in venv |
| Rails | Check `Gemfile` | `rails --version` | Only with bundler |

### OS & System

| Info | Command | Notes |
|------|---------|-------|
| macOS version | `sw_vers -productVersion` | Output: `14.2.1` |
| Architecture | `uname -m` | Output: `arm64` or `x86_64` |
| Hostname | `hostname` | For environment identification |
| Shell | `echo $SHELL` | `/bin/zsh` or `/bin/bash` |
| Xcode CLT | `xcode-select -p` | Required for many tools on macOS |

---

## Scan Execution Guidelines

### Order of Operations
1. Always scan OS and architecture first (needed for compatibility checks)
2. Scan the primary runtime next (Node, Python, etc.)
3. Scan package managers
4. Scan frameworks and libraries
5. Scan deployment tools
6. Scan databases

### Error Handling
- If `which` returns non-zero exit code: tool is not installed → Status: MISSING
- If version command fails but `which` succeeds: tool may be broken → Status: CHECK_MANUALLY
- If version is below required minimum: → Status: WRONG_VERSION
- If no version requirement specified in design: use "any" and report found version → Status: OK

### Performance
- Run independent detection commands in parallel where possible
- Group related checks (e.g., all Node.js ecosystem checks together)
- Cache results — don't re-run detection if already checked

### Reporting Format

Present results grouped by category:

```markdown
### Environment Scan Results

**OS & System**
| Info | Value |
|------|-------|
| macOS | 14.2.1 |
| Architecture | arm64 |
| Shell | /bin/zsh |

**Runtimes & Package Managers**
| Tool | Required | Found | Status |
|------|----------|-------|--------|
| Node.js | >=18 | v20.11.0 | OK |
| pnpm | >=8 | 8.14.0 | OK |

**Frameworks & Libraries**
| Tool | Required | Found | Status |
|------|----------|-------|--------|
| Next.js | >=14 | 14.1.0 | OK |

**Missing Tools**
| Tool | Required By | Action Needed |
|------|-------------|---------------|
| Docker | Deployment | Install or defer |
```
