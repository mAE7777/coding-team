---
name: rust
detection: ["Cargo.toml", "*.rs"]
archetype: E
---

# Rust — Stack Knowledge

## Conventions

**Project structure**:
- `src/main.rs` for binaries, `src/lib.rs` for libraries
- Modules: one file per module (`src/config.rs`), or `src/config/mod.rs` + submodules for complex ones
- `tests/` for integration tests (separate compilation units)
- `benches/` for benchmarks, `examples/` for usage examples

**Naming**: snake_case for functions/variables/modules, CamelCase for types/traits, SCREAMING_SNAKE for constants. Acronyms in CamelCase: `HttpClient` not `HTTPClient`.

**Error handling philosophy**: Choose one strategy per crate and stick with it:
- **Libraries**: `thiserror` for typed errors. Every error variant carries context. Return `Result<T, MyError>`.
- **Applications**: `anyhow` for ergonomic error chains. Use `.context("what was being attempted")` on every `?`.
- **Never** mix these in one crate. Libraries should not depend on `anyhow`.

**Import ordering**: std → external crates → internal modules, separated by blank lines.

**Module visibility**: default to private. Use `pub(crate)` before `pub`. Public API surface should be minimal.

## Toolchain

| Action | Command | Notes |
|--------|---------|-------|
| Build | `cargo build` | `--release` for optimized |
| Test | `cargo test` | `-- --nocapture` to see println output |
| Lint | `cargo clippy -- -D warnings` | Treat warnings as errors |
| Format | `cargo fmt` | Check mode: `cargo fmt --check` |
| Audit | `cargo audit` | Security vulnerability scan |
| Doc | `cargo doc --no-deps --open` | Generate and view docs |
| Check | `cargo check` | Fast type-check without codegen |
| Bench | `cargo bench` | Requires `#[bench]` or criterion |

**CI pipeline**: `cargo fmt --check && cargo clippy -- -D warnings && cargo test && cargo audit`

## Safety Patterns

**Ownership**: Prefer borrowing (`&T`, `&mut T`) over cloning. Clone only at ownership boundaries (thread spawn, async task). If you find yourself cloning to satisfy the borrow checker, restructure the code — cloning is a bandaid, not a fix.

**Error propagation**: Use `?` operator everywhere. Never `.unwrap()` in non-test code. Use `.expect("reason")` only for invariants that are genuinely impossible to violate (document why). In tests, `.unwrap()` is fine.

**Concurrency**: Prefer message passing (channels, `mpsc`) over shared state (`Mutex`). If using `Mutex`, wrap in `Arc` for multi-threaded access. Never hold a lock across an `.await` point.

**Async**: Pick one runtime (tokio is standard) and use it exclusively. Don't mix runtimes. Use `tokio::spawn` for concurrent tasks, `tokio::select!` for racing. Every spawned task needs a cancellation path via `CancellationToken` or `tokio::select!` on a shutdown signal.

**Unsafe**: Never in application code. In libraries, every `unsafe` block gets a `// SAFETY: ...` comment explaining why the invariants hold. Minimize unsafe surface — wrap in a safe API.

## Anti-Patterns

**Excessive cloning to avoid borrow checker**:
- BAD: `let name = config.name.clone(); process(name);`
- GOOD: `process(&config.name);` or restructure to avoid overlapping borrows
- WHY: Cloning hides ownership design problems and adds unnecessary allocation

**Unwrap in non-test code**:
- BAD: `let file = File::open(path).unwrap();`
- GOOD: `let file = File::open(path).context("opening config file")?;`
- WHY: Unwrap panics on error — production code should propagate errors

**String instead of &str in function parameters**:
- BAD: `fn greet(name: String) { ... }`
- GOOD: `fn greet(name: &str) { ... }` (or `impl AsRef<str>` for generic)
- WHY: Accepting owned String forces callers to allocate; &str accepts both String and &str

**Returning references to local data**:
- BAD: `fn get_name(s: String) -> &str { &s[..] }` (s dropped, reference dangling)
- GOOD: Accept `&str` input and return a slice of it, or return owned `String`
- WHY: Rust's lifetime system prevents this at compile time — restructure rather than fight

**Ignoring clippy warnings**:
- BAD: `#[allow(clippy::...)]` to silence warnings
- GOOD: Fix the underlying issue. Clippy catches real bugs
- WHY: Clippy's suggestions are almost always correct for idiomatic Rust

**Spawning threads/tasks without shutdown path**:
- BAD: `tokio::spawn(async { loop { ... } });`
- GOOD: `tokio::spawn(async move { loop { tokio::select! { _ = token.cancelled() => break, ... } } });`
- WHY: Orphaned goroutines/tasks leak resources and prevent clean shutdown

## Testing Patterns

**Framework**: Built-in `#[test]` for unit tests. `#[tokio::test]` for async. Integration tests in `tests/` directory (separate compilation unit — tests public API only).

**Table-driven tests** (idiomatic):
```rust
#[test]
fn test_parse_cases() {
    let cases = vec![
        ("valid input", "expected output", false),
        ("", "", true), // should error
    ];
    for (input, expected, should_err) in cases {
        let result = parse(input);
        if should_err {
            assert!(result.is_err(), "expected error for: {input}");
        } else {
            assert_eq!(result.unwrap(), expected);
        }
    }
}
```

**Property testing**: `proptest` crate for generative testing. Good for parsers, serializers, mathematical functions.

**CLI testing**: `assert_cmd` + `predicates` for testing command-line binaries end-to-end.

**Filesystem tests**: `tempfile` crate for temporary directories. Never use hardcoded paths.

**Coverage**: `cargo tarpaulin` or `cargo llvm-cov`. Target 80%+.

## Deploy Patterns

**Library (crates.io)**:
- Pre-publish: `cargo publish --dry-run` (verify contents)
- Publish: `cargo publish`
- Verify: `cargo install {crate} && {crate} --version`

**Binary distribution**:
- Cross-compile: `cross build --target x86_64-unknown-linux-musl --release`
- Or `cargo-zigbuild` for simpler cross-compilation
- GitHub Releases: use `cargo-dist` or `release-plz` for automated releases

**Version management**: `cargo-release` handles version bump + git tag + publish in one command.

**CI verification**: `cargo test && cargo clippy -- -D warnings && cargo fmt --check && cargo audit`
