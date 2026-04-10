# Port Registry

Central tracking of dev server port assignments across all active projects. Prevents port conflicts when multiple projects run concurrently in different sessions.

---

## Port Assignments

| Project | Path | Port | Status | Assigned |
|---------|------|------|--------|----------|
| (your-project) | ~/Projects/your-project | 3000 | active | YYYY-MM-DD |

Status values: `active` (in development) | `released` (deploy completed or manually freed)

---

## Assignment Rules

1. **Framework defaults**: Next.js projects start from port 3000, Vite projects from 5173, other frameworks from 3000.
2. **Conflict avoidance**: Read this table before assigning. Skip any port with `active` status.
3. **Lowest available**: Assign the lowest unused port in the framework's range.
4. **Recording**: /plan writes both this file AND the pipeline-state.md `Dev Port` header field.
5. **Release**: /deploy marks the port as `released` when archiving pipeline-state.md.
6. **Cleanup**: Ports for abandoned projects (no deploy) can be manually released.
7. **Runtime check**: /dev verifies port availability via `lsof -i :{port}` before starting the server.
