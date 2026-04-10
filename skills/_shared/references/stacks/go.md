---
name: go
detection: ["go.mod", "go.sum", "*.go"]
archetype: E
---

# Go — Stack Knowledge

## Conventions

**Module path**: Match the repository URL: `module github.com/user/project`. For internal tools: `module {org}/internal/{tool}`.

**Project structure**:
- `cmd/{appname}/main.go` for entry points (multiple binaries = multiple cmd/ subdirs)
- `internal/` for application code (compiler-enforced private)
- `pkg/` only if you explicitly want external consumers (rare — prefer internal/)
- No `util/`, `helpers/`, `common/` packages — ever. If you can't name it, it shouldn't exist.
- Flat is better: don't create a package for 1-2 files

**Naming**: Short, lowercase, single-word package names. No underscores, no mixedCase in package names. Exported = CamelCase, unexported = camelCase. Acronyms: `HTTP`, `URL`, `ID` (all caps). Interface names: `-er` suffix for single-method (`Reader`, `Writer`).

**Error handling philosophy**: Errors are values, not exceptions. Handle every error explicitly. Wrap with context using `fmt.Errorf("doing X: %w", err)`. Never return bare `err` — always add what was being attempted.

**Go version**: Target Go 1.22+ for new projects (loop variable fix, enhanced routing, rangefunc).

## Toolchain

| Action | Command | Notes |
|--------|---------|-------|
| Build | `go build ./...` | `./cmd/{app}` for specific binary |
| Test | `go test ./...` | `-race` for race detection, `-count=1` to disable cache |
| Lint | `golangci-lint run` | Preferred over standalone `go vet` |
| Format | `gofmt -w .` | Or `goimports -w .` (also organizes imports) |
| Vet | `go vet ./...` | Built-in static analysis |
| Tidy | `go mod tidy` | Clean up go.mod and go.sum |
| Vuln | `govulncheck ./...` | Official vulnerability scanner |
| Doc | `go doc {package}` | Or `pkgsite` for web view |

**CI pipeline**: `go vet ./... && golangci-lint run && go test -race -count=1 ./... && govulncheck ./...`

## Safety Patterns

**Error handling**: Always handle errors. Never `_` an error return unless you've documented why it's safe. Always wrap: `fmt.Errorf("creating user %s: %w", name, err)`.

**Context**: Pass `context.Context` as the first parameter to any function that does I/O or may block. Never store Context in a struct — pass it through the call chain. Use `context.WithTimeout` for deadlines, `context.WithCancel` for manual cancellation.

**Goroutine lifecycle**: Every goroutine needs a shutdown path. Use `context.Done()` channel or explicit done channel:
```go
func worker(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return
        case item := <-work:
            process(item)
        }
    }
}
```

**Race conditions**: Use `go test -race` in CI always. Shared state: prefer channels for communication, `sync.Mutex` for pure state protection. Never hold a lock across channel operations.

**Goroutine coordination**: Use `errgroup.Group` (golang.org/x/sync/errgroup) for groups of goroutines that return errors. Use `sync.WaitGroup` for fire-and-forget goroutines.

**Nil safety**: Zero values are useful — design around them. A nil map is readable (returns zero value) but panics on write. Always `make(map[K]V)` or `map[K]V{}` before writing.

## Anti-Patterns

**Discarding errors**:
- BAD: `result, _ := doSomething()`
- GOOD: `result, err := doSomething(); if err != nil { return fmt.Errorf("doing something: %w", err) }`
- WHY: Ignored errors cause silent failures — the hardest bugs to diagnose

**Bare error return**:
- BAD: `return err`
- GOOD: `return fmt.Errorf("creating order for user %s: %w", userID, err)`
- WHY: Without wrapping, error messages like "connection refused" give no context about which operation failed

**Context in structs**:
- BAD: `type Service struct { ctx context.Context }`
- GOOD: `func (s *Service) Do(ctx context.Context) error { ... }`
- WHY: Context represents request scope — storing it in a struct conflates object lifetime with request lifetime

**Large interfaces**:
- BAD: `type Storage interface { Get(); Set(); Delete(); List(); Count(); Migrate(); Backup(); }`
- GOOD: `type Getter interface { Get(key string) (string, error) }` — define where used
- WHY: Large interfaces couple consumers to implementations; small interfaces are satisfied by more types

**Using fmt.Println for logging**:
- BAD: `fmt.Println("processing request")`
- GOOD: `slog.Info("processing request", "user_id", userID, "method", r.Method)`
- WHY: fmt.Println has no levels, no structure, no fields — useless in production

**Spawning unmanaged goroutines**:
- BAD: `go process(item)` (no way to know when it finishes, no error handling)
- GOOD: Use `errgroup.Go()` or track with `sync.WaitGroup` + error channels
- WHY: Orphaned goroutines leak resources and prevent clean shutdown

**Naked returns in complex functions**:
- BAD: `func parse(s string) (result int, err error) { ... return }` (what's returned?)
- GOOD: `return result, nil` or `return 0, err` (explicit)
- WHY: Naked returns hide what's being returned — acceptable only in very short functions

## Testing Patterns

**Table-driven tests** (idiomatic Go):
```go
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int
        wantErr bool
    }{
        {"valid", "42", 42, false},
        {"empty", "", 0, true},
        {"negative", "-1", -1, false},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if (err != nil) != tt.wantErr {
                t.Fatalf("Parse(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
            }
            if got != tt.want {
                t.Fatalf("Parse(%q) = %d, want %d", tt.input, got, tt.want)
            }
        })
    }
}
```

**Test helpers**: Use `t.Helper()` in helper functions so failure messages report the caller's line.

**Assertions**: Standard library (`t.Fatal`, `t.Error`) or `testify/require` (fatal) + `testify/assert` (soft). Pick one and be consistent.

**Integration tests**: Use `//go:build integration` build tag. Run separately: `go test -tags=integration ./...`

**Coverage**: `go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out`. Target 80%+.

**Race detection**: Always `go test -race` in CI. No exceptions.

## Deploy Patterns

**Go modules (library)**:
- Tag: `git tag v1.0.0 && git push origin v1.0.0` (that's it — Go uses git tags as versions)
- Verify: `go get github.com/user/module@v1.0.0`
- No build, no publish, no registry. Semantic versioning enforced by Go tooling.

**Binary distribution**:
- Cross-compile: `GOOS=linux GOARCH=amd64 go build -o app ./cmd/app`
- Automated releases: `goreleaser release` (builds + publishes to GitHub Releases)
- Docker: `FROM golang:1.22 AS builder` → `FROM gcr.io/distroless/static-debian12`

**CI verification**: `go vet ./... && golangci-lint run && go test -race -count=1 ./... && govulncheck ./...`
