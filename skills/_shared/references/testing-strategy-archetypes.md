# Testing Strategy Archetypes

Different project types need fundamentally different testing approaches. This
reference helps /plan detect the right archetype and size phases/tasks accordingly.
Loaded by /plan at Phase 1c and by /dev at Stage 1.

---

## Archetypes

### Archetype A: Test-After-Phase (Standard Software)

**Pattern**: Build a complete feature, then run automated tests.

**Signals**: Conventional web framework (Next.js, Rails, Django, Express),
CRUD operations, REST/GraphQL APIs, standard UI components, database with ORM.

**Phase size**: 3-6 tasks, 1-4 hours implementation per task.
**Verification**: Automated tests after each task, validation gates after phase.
**Phase boundary**: When a user-visible feature is complete.

### Archetype B: Test-Every-Step (Hardware/Sensor/IoT)

**Pattern**: Each change is deployed to hardware and manually verified.

**Signals**: Serial, GPIO, I2C, SPI, UART imports/dependencies. File types:
.ino, .elf, .hex, .bin. Tools: platformio, arduino-cli, openocd. Keywords:
sensor, actuator, motor, servo, pin, relay, voltage, interrupt. Python packages:
RPi.GPIO, smbus, pyserial, machine (MicroPython).

**Phase size**: 2-4 tasks, 30min-2hr per task MAX.
**Verification**: Flash/deploy and test on hardware after EVERY task.
**Phase boundary**: When a single hardware interaction works correctly.
**Key rule**: Never proceed to next hardware interaction without physical
verification. Simulation passing is necessary but insufficient (sim-to-real gap).

### Archetype C: Test-At-Perception-Points (UI/Animation/Audio)

**Pattern**: Build to next visible/audible change, then verify with human senses.

**Signals**: Animation libraries (framer-motion, GSAP, react-spring, CSS
animations), audio libraries (Web Audio API, Tone.js, ffmpeg bindings),
WebGL/Canvas/SVG manipulation, .glsl/.shader files. Keywords: animation,
transition, easing, timing, micro-interaction, sound design, haptic, gesture.

**Phase size**: 2-4 tasks, 30min-1hr per task MAX.
**Verification**: Human visual/auditory review after EVERY change.
**Phase boundary**: When a single interaction or animation feels correct.
**Key rule**: Batch-writing 10 animations and reviewing all at once leads
to cascading rework. One perception change at a time.

### Archetype D: Test-At-Boundaries (Data Pipelines)

**Pattern**: Verify intermediate outputs at each transformation step.

**Signals**: ETL tools, pandas, dbt, Airflow, Spark, streaming frameworks.
Multiple sequential transformations, schema definitions. Keywords: pipeline,
transform, extract, load, normalize, aggregate, deduplicate.

**Phase size**: 3-5 tasks, 1-2 hours per transformation step.
**Verification**: Schema check + spot-check values after each transformation.
**Phase boundary**: When a transformation produces correct output.

### Archetype E: Build-Then-Test (Compiled Systems)

**Pattern**: Compilation is a meaningful quality gate. Build must succeed before tests run.

**Signals**: Cargo.toml (Rust), go.mod (Go), CMakeLists.txt (C/C++), *.csproj (C#).
Compiled binaries, static linking. Keywords: build, compile, link, binary, target.

**Phase size**: 3-5 tasks, 30min-2hr per task.
**Verification**: Build + lint + test + sanitizers after each task. Build failure
is a hard gate — do not proceed until it compiles.
**Phase boundary**: When a module compiles, passes tests, and passes linter.
**Key rule**: The compiler is the first reviewer. Compiler warnings treated as errors
(`-D warnings` for clippy, `-Werror` for GCC/clang). Run race detectors where
available (`go test -race`, `cargo test` with ASAN).

### Archetype F: Simulator-Verified (Mobile Apps)

**Pattern**: Each UI change must be verified on simulator/emulator. Screenshots
for visual regression.

**Signals**: .xcodeproj, Package.swift, build.gradle, build.gradle.kts,
AndroidManifest.xml. Keywords: iOS, Android, SwiftUI, Jetpack Compose, UIKit,
storyboard, simulator, emulator.

**Phase size**: 2-4 tasks, 30min-1hr per task.
**Verification**: Build + run on simulator/emulator + visual check after each task.
Human review required for UI changes (screenshots, not just test pass).
**Phase boundary**: When a single screen or interaction flow works correctly on simulator.
**Key rule**: Never batch-write UI components. Build one view, verify on simulator,
then build the next. Layout bugs compound — catching them early saves 10x rework.
Platform-specific concerns: permissions, app lifecycle, background/foreground
transitions must be tested explicitly, not assumed from unit tests.

---

## Detection Algorithm

Score each archetype (highest wins; mixed projects get multiple):

```
HARDWARE (Archetype B):
  +3 if hardware dependencies detected (serial, GPIO, I2C, etc.)
  +2 if physical deploy target (microcontroller, SBC, FPGA)
  +1 if keywords: sensor, actuator, motor, pin, relay, voltage

PERCEPTION (Archetype C):
  +2 if animation/audio libraries detected
  +2 if primary output is visual/auditory experience
  +1 if keywords: animation, easing, timing, micro-interaction, sound

DATA PIPELINE (Archetype D):
  +2 if ETL patterns detected
  +2 if sequential transformation chains
  +1 if schema definitions present

COMPILED (Archetype E):
  +3 if Cargo.toml, go.mod, or CMakeLists.txt detected
  +2 if compiled binary output (no interpreted runtime)
  +1 if keywords: build, compile, link, binary, static

MOBILE (Archetype F):
  +3 if .xcodeproj, Package.swift, build.gradle detected
  +2 if iOS/Android target (simulator/emulator in workflow)
  +1 if keywords: SwiftUI, Jetpack Compose, UIKit, storyboard

STANDARD (Archetype A — default):
  +1 if web framework detected
  +1 if CRUD patterns
  (Archetype A is default when no other scores above threshold of 2)
```

**Mixed projects**: A robotics project with a web dashboard has both B (firmware)
and A (dashboard). Assign archetypes per subsystem. Use the most conservative
archetype for cross-subsystem integration points.

---

## Task Sizing by Archetype

| Archetype | Max Task Duration | Verification Cost | Force Human Review |
|-----------|-------------------|-------------------|--------------------|
| A (Standard) | 4 hours | Low (automated) | Only on security/auth |
| B (Hardware) | 2 hours | High (physical) | Always |
| C (Perception) | 1 hour | Medium (human senses) | Always |
| D (Data Pipeline) | 2 hours | Medium (data inspection) | On schema changes |
| E (Compiled) | 2 hours | Low (compiler + tests) | Only on unsafe/FFI |
| F (Mobile) | 1 hour | High (simulator) | Always for UI |

Risk multipliers (divide max duration by):
- 1.5x if security-sensitive
- 1.5x if concurrency involved
- 2.0x if no existing tests
- 1.3x if unfamiliar library/framework

---

## Verification Point Rules

### Rule 1: Verify at domain boundaries
Every time code crosses domains (backend→frontend, software→hardware,
one schema→another), insert a verification point.

### Rule 2: Verify at irreversibility points
Before: database migration dropping data, hardware flash changing boot,
deployment to production, data transformation discarding source.

### Rule 3: Verify after AI-generated complexity
Insert verification when AI generates:
- >200 lines in a single generation
- Concurrency, security, or financial code
- External service integration
- Complex state management

### Rule 4: The compounding error rule
- Independent operations: verify after groups of 3-5
- Sequential/dependent operations: verify after each one
- Branching operations: verify at each branch point

---

## Phases.md Integration

When /plan detects a non-standard archetype, it adds metadata to phases.md:

```markdown
## Project Strategy
| Field | Value |
|-------|-------|
| Testing Archetype | A (Standard) / B (Hardware) / C (Perception) / D (Data Pipeline) / E (Compiled) / F (Mobile) |
| Verification Mode | incremental / per-phase |
| Max Task Duration | {from sizing table} |
```

This metadata is consumed by /dev to adjust task execution:
- **incremental**: After every task, run verification before proceeding.
  Present manual verification instructions to user when needed.
- **per-phase**: Standard flow — validate at phase end via gates.

For Archetype B, C, E, and F, /plan should also:
- Size tasks smaller (2-4 per phase, shorter duration)
- Add manual verification gates between tasks, not just at phase end
- Include "flash and test" or "visual check" as task-level ACs
- For E: Build verification after every task
- For F: Simulator verification after every task
- Ask user at Phase 3: "This project involves hardware/perception. Should
  I design phases for incremental testing (recommended) or batch testing?"

---

## The AI-Specific Factor

AI-generated code has a unique failure mode: it looks correct and may pass
superficial tests while being subtly wrong. This means:
- Verification density should INCREASE as AI-generated code accumulates
- Tests themselves should be reviewed (AI can write tests that pass trivially)
- Negative test cases matter more (AI handles happy path well, misses edges)
- After context compaction, first task should be verification, not new code
