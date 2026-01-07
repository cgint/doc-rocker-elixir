# Doc-Rocker (Phoenix LiveView)

Doc-Rocker is a documentation search assistant. This repo is a port of the original SvelteKit app to Phoenix LiveView with **pixel-identical UI** and **full feature parity**. The UI, behavior, and API contracts are strictly derived from `doc-rocker-svelte.md`.

## Scope and Constraints

- Product: Doc-Rocker (documentation search app).
- UI must look exactly the same as the Svelte version.
- Full feature parity, including all API behavior and API users.
- Streaming UX should be more professional (working status + partial/segmented updates), while keeping UX consistent.
- Stack: prefer native LiveView defaults; minimal tech changes.
- Hosting: self-hosted via Docker.
- PWA behavior must be preserved.
- If something is **not** present in `doc-rocker-svelte.md`, it is treated as **non-existent**.

## Current Status

- Step 1 analysis complete.
- Source system overview is in `PORTING_OVERVIEW.html` with diagram in `PORTING_OVERVIEW.svg`.
- Migration status and decisions live in `TASK.md`.

## Core UI (Source Behavior)

Main page composition and behavior are defined in `doc-rocker-svelte.md` and captured in `PORTING_OVERVIEW.html`.

Key UI elements:
- Logo (animated while loading).
- Input field with 400 character limit and validation.
- Send button with loading state.
- Documentation picks (single selection, optional custom domain).
- Streaming status message.
- Response display with combined result, citations, and raw results.

## Streaming Behavior (SSE)

Client calls `POST /api/chat` and expects `text/event-stream` with messages:

- `type: status` — a short status line appended to the UI.
- `type: final` — contains the combined response and raw results.

## API Endpoints

- `POST /api/chat` (SSE) — streaming search response.
- `POST /api/rock` (JSON) — search endpoint with User-Agent validation.

No `/api/mcp` endpoint exists in-app. MCP is handled externally by an stdin wrapper that calls the normal API.

## Routes

- `/` — main Doc-Rocker UI.
- `/markdown-demo` — MarkdownDisplay demo page (parity with Svelte source).

## Development

```
mix setup
cp dev.env.example dev.env
# edit dev.env with your API keys
./start_dev.sh
```

## Docker

```
docker compose up --build
```

Set `SECRET_KEY_BASE` and the `VITE_*` API keys in your environment (see `docker-compose.yml`).

## Search Pipeline

- Perplexity + Tavily searches run in parallel.
- Results are combined by an LLM into a unified answer.
- Combined answer format includes warning and model info.

## PWA Assets

Static assets live in `static/`:
- `manifest.json`
- `sw.js`
- icons and logo

PWA meta tags and service worker registration are required in the app shell.

## Environment Variables (Source Names)

- `VITE_PERPLEXITY_API_KEY`
- `VITE_PERPLEXITY_MODEL`
- `VITE_TAVILY_API_KEY`
- `VITE_COMBINER_PROVIDER`
- `VITE_COMBINER_PROVIDER_MODEL`
- `VITE_COMBINER_API_KEY`

## References

- `doc-rocker-svelte.md` — authoritative UI/API behavior reference
- `PORTING_OVERVIEW.html` — extracted spec summary
- `PORTING_OVERVIEW.svg` — system diagram
- `TASK.md` — migration status, decisions, and project learnings
- `TECH_LEARNINGS.md` — general Elixir/LiveView learnings
