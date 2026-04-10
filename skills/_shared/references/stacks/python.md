---
name: python
detection: ["pyproject.toml", "requirements.txt", "setup.py", "setup.cfg", "Pipfile", "*.py"]
archetype: A
---

# Python — Stack Knowledge

## Conventions

**Package manager**: uv (preferred) > poetry > pip. Never `pip install` directly — use `uv add` or `uv pip install` in a virtual environment. Check `pyproject.toml` for existing tooling before assuming.

**Project structure**:
- `src/{package_name}/` layout (src-layout, PEP 517)
- `tests/` at root, mirroring source structure
- `pyproject.toml` as single config file (not setup.py + setup.cfg + requirements.txt)
- `__init__.py` in every package directory

**Python version**: Target 3.10+ for new projects (match expressions, union type syntax `X | Y`, ParamSpec). Check `pyproject.toml` `requires-python` for existing projects.

**Type hints**: Mandatory on all function signatures. Use modern syntax:
- `list[str]` not `List[str]` (Python 3.9+)
- `str | None` not `Optional[str]` (Python 3.10+)
- `from __future__ import annotations` for forward references

**Naming**: snake_case everything except classes (PascalCase). Constants: UPPER_SNAKE_CASE. Private: single underscore prefix `_internal`. No double underscore name mangling unless you know why.

**Error handling**: EAFP (Easier to Ask Forgiveness than Permission) — try/except over if/else for existence checks. Always catch specific exceptions, never bare `except:` or `except Exception:` without re-raising.

**String formatting**: f-strings exclusively. No `.format()`, no `%` formatting.

## Toolchain

| Action | Command | Notes |
|--------|---------|-------|
| Install deps | `uv sync` | Or `pip install -e ".[dev]"` |
| Add dep | `uv add {package}` | Or `poetry add` |
| Test | `uv run pytest` | Or `python -m pytest` |
| Lint | `uv run ruff check .` | `--fix` for auto-fix |
| Format | `uv run ruff format .` | Check mode: `ruff format --check .` |
| Typecheck | `uv run pyright` | Or `mypy` |
| Audit | `pip-audit` | Or `safety check` |
| Doc | `uv run pdoc {package}` | Or sphinx |

**CI pipeline**: `ruff format --check . && ruff check . && pyright && pytest && pip-audit`

## Safety Patterns

**Mutable defaults**: Never use mutable default arguments:
```python
# BAD
def add_item(item, items=[]):  # shared across calls!
    items.append(item)

# GOOD
def add_item(item, items: list | None = None):
    if items is None:
        items = []
    items.append(item)
```

**Async discipline**: Don't block in async functions. Use `asyncio.to_thread()` for CPU-bound or blocking I/O work. Never call `time.sleep()` in async code — use `await asyncio.sleep()`. Every `async with` and `async for` should have proper cleanup.

**Resource management**: Always use context managers (`with` / `async with`) for files, connections, locks. Never rely on garbage collection for cleanup:
```python
# BAD
f = open("file.txt")
data = f.read()

# GOOD
with open("file.txt") as f:
    data = f.read()
```

**Path handling**: Use `pathlib.Path` exclusively. Never `os.path.join()`. Paths are objects, not strings.

**Data modeling**: Use `dataclasses` for internal data structures, `pydantic` for validation at boundaries (API input, config files). Never use raw dicts for structured data.

## Anti-Patterns

**Bare except clauses**:
- BAD: `except:` or `except Exception:`
- GOOD: `except ValueError as e:` (catch specific) or `except Exception: logger.exception("..."); raise`
- WHY: Bare except catches KeyboardInterrupt and SystemExit — hiding real bugs

**os.path instead of pathlib**:
- BAD: `os.path.join(base_dir, "config", "settings.json")`
- GOOD: `Path(base_dir) / "config" / "settings.json"`
- WHY: Path objects are composable, cross-platform, and have rich methods

**Dict for structured data**:
- BAD: `user = {"name": "Alice", "age": 30}` then `user["naem"]` (typo, no error)
- GOOD: `@dataclass class User: name: str; age: int` then `user.naem` (AttributeError)
- WHY: Dicts have no schema — typos in keys are silent, no autocomplete, no type checking

**Missing type hints**:
- BAD: `def process(data, config):` (what types? what returns?)
- GOOD: `def process(data: list[str], config: AppConfig) -> ProcessResult:`
- WHY: Type hints enable editor support, catch bugs early, document intent

**Global state / singletons**:
- BAD: `db = Database()` at module level
- GOOD: Pass `db` as parameter, use dependency injection
- WHY: Global state makes testing impossible without monkeypatching

**Blocking in async code**:
- BAD: `async def fetch(): response = requests.get(url)`
- GOOD: `async def fetch(): async with httpx.AsyncClient() as client: response = await client.get(url)`
- WHY: `requests.get` blocks the event loop — all other coroutines starve

## Testing Patterns

**Framework**: pytest exclusively. No `unittest.TestCase` in new code.

**Fixtures**: Use `@pytest.fixture` for setup/teardown. Prefer `tmp_path` (built-in) for filesystem tests. Use `monkeypatch` for environment variable mocking.

**Parametrize** for table-driven tests:
```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("", ""),
    ("123", "123"),
])
def test_upper(input, expected):
    assert upper(input) == expected
```

**Async testing**: Use `anyio` backend, not `asyncio` directly:
```python
import pytest

@pytest.mark.anyio
async def test_async_fetch():
    result = await fetch_data()
    assert result.status == 200
```

**Mocking**: `unittest.mock.patch` or `pytest-mock`'s `mocker` fixture. Mock at the boundary (where imported), not at definition.

**Coverage**: `pytest --cov={package} --cov-report=term-missing`. Target 80%+.

## Deploy Patterns

**PyPI (library)**:
- Build: `uv run python -m build` (or `python -m build`)
- Check: `twine check dist/*`
- Upload: `twine upload dist/*`
- Verify: `uv pip install {package}=={version} && python -c "import {package}"`

**Docker (application)**:
- Multi-stage build: builder stage installs deps, runtime stage copies only venv
- Use `uv` in Docker: `COPY --from=ghcr.io/astral-sh/uv /uv /bin/uv`
- Pin Python version in Dockerfile: `FROM python:3.12-slim`

**CLI distribution**:
- `pipx` for user-facing CLI tools
- `pyinstaller` or `nuitka` for standalone executables
- Entry points in `pyproject.toml`: `[project.scripts]`

**CI verification**: `ruff format --check . && ruff check . && pyright && pytest --cov && pip-audit`
