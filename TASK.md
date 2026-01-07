# Doc-Rocker -> Phoenix LiveView Migration

## Initial Request

- Re-implement the Doc-Rocker (SvelteKit) app as an Elixir Phoenix LiveView app.
- UI must look exactly the same as the current Svelte version.
- Improve streaming response UX using LiveView capabilities.
- Maintain this file as the single source of truth for migration status and project-specific learnings.
- Capture general Elixir/tech-stack learnings in a separate file.

## Context & Key Facts

- We are migrating the **Doc-Rocker** SvelteKit app to Phoenix LiveView.
- UI must be **pixel-identical** to the current Svelte UI.
- `doc-rocker-svelte.md` is the source of truth for UI, CSS, and behavior.
- `static` contains original assets to be reused as-is.
- Feature parity includes all UI and API behavior (including API users).
- Streaming UX should be more professional: show working status and partial updates.
- Keep the stack as native LiveView as possible; minimize changes.
- Target deployment: self-hosted via Docker.
- PWA behavior must be preserved.

## Goal

- Feature-parity LiveView app with identical UI and improved streaming UX.
- Clear migration status and decisions tracked in this file.

## Status

- Current phase: Step 3 - UI parity
- Completed:
  - Read `elixir_phoenix_liveview_guide.md`.
  - Reviewed `doc-rocker-svelte.md` (Svelte structure and behavior notes).
  - Consulted doc expert agent for LiveView UI-heavy component patterns.
  - Static asset folder from original project added to repo (`static`).
  - Extracted source system analysis into `PORTING_OVERVIEW.html`, `PORTING_OVERVIEW.puml`, and `PORTING_OVERVIEW.svg`.
  - Confirmed there is no `/api/mcp` endpoint; MCP is handled via an external stdin wrapper that calls existing APIs.
  - Confirmed there is no `/api/auth` endpoint (not present in `doc-rocker-svelte.md`).
  - Created `README.md` for the Phoenix LiveView port.
  - Added detailed implementation plan in this document.
  - Generated Phoenix scaffold in repo root (app: `doc_rocker`, module: `DocRocker`; no Ecto/mailer/dashboard; deps not installed).
  - Ported app shell metadata, PWA tags, and service worker registration into Phoenix root layout.
  - Replaced base CSS with source `app.html` styles for pixel parity.
  - Copied PWA/static assets from `static/` into `priv/static/`.
  - Added `HomeLive` with main page structure and initial UI state handling.
  - Ported component CSS for LogoGfx, InputField, SendButton, DocumentationPicks, ResponseDisplay, and MarkdownDisplay.
  - Added backend scaffolding for `/api/chat` (SSE) and `/api/rock` endpoints.
  - Implemented SearchService, Perplexity, Tavily, and LLM provider connectors in Elixir.
  - Wired LiveView submit to SearchService with status updates and scroll events.
  - Added JS hooks for scrolling and markdown rendering (marked + highlight.js).
  - Added assets `package.json` with marked/highlight.js dependencies.
  - Restored documentation pick persistence via localStorage.
  - Added Cmd+Enter submit shortcut and guarded double-submit while loading.
  - Removed unused `phoenix-colocated` hook import.
  - Installed JS and Elixir deps and validated asset build.
  - Adjusted asset bundling for marked/highlight and CommonJS topbar.
  - Ported `/markdown-demo` LiveView page.
- Next:
  - Confirm highlight.js CSS output is loaded and markdown rendering matches Svelte output.
  - Confirm remaining LiveView UX parity items (copy buttons, selection persistence, error states).
  - Remove Tailwind/daisyUI from build if they introduce unwanted side effects.

## Plan (stepwise)

1. Source analysis: extract UI states, CSS, routes, streaming behavior, and API contracts. (Complete)
2. Phoenix scaffold:
   - Generate a new Phoenix app at repo root with LiveView enabled.
   - Define app shell HTML to mirror `src/app.html` (meta tags, PWA setup).
   - Wire static assets from `static/` into Phoenix `priv/static`.
3. UI parity:
   - Build LiveView for `/` with identical layout and spacing.
   - Port styles from Svelte components into LiveView CSS (global + component-level).
   - Implement UI state: loading, errors, status messages, results.
4. Streaming UX:
   - Implement SSE-style streaming via LiveView assigns and progressive updates.
   - Maintain status message sequence (start -> search complete -> final).
   - Preserve scroll behavior on start and finish.
5. Backend parity:
   - Implement `/api/chat` streaming endpoint in Phoenix controller/LiveView channel.
   - Implement `/api/rock` JSON endpoint with User-Agent validation.
   - Implement search pipeline modules: Perplexity, Tavily, LLM combiner.
6. Search pipeline details:
   - Preserve domain handling (worldwide vs restricted).
   - Preserve combined answer formatting and warnings.
   - Preserve error handling behavior.
7. Markdown rendering + copy actions:
   - Implement markdown rendering and code highlighting in LiveView templates.
   - Provide copy-as-markdown and copy-as-rich-text actions.
8. PWA:
   - Serve `manifest.json` and `sw.js` unchanged.
   - Register service worker in app shell.
9. Docker:
   - Add Dockerfile and docker-compose for self-hosted deployment.
   - Ensure env variable mapping and secrets are documented.
10. Verification:
   - UI parity checklist (layout, spacing, colors, animations, responsive).
   - API parity checklist (chat SSE, rock validation).
   - PWA check (manifest, SW cache, offline page).
   - Streaming UX review (status message cadence and content).

## Implementation Inputs (answered)

1. Confirm the correct product name and scope: is this "Doc-Rocker" (documentation search app) or "Dock Rocker" (different UI)?
   Answer: Correct
2. Where should the Phoenix LiveView app live: new Phoenix project or integrate into an existing repo?
   Answer: new phoenix project within the root dir of this repo
3. Are there source assets we must reuse for exact UI parity (logos, icons, fonts, images, CSS)? If yes, where are they?
   Answer: see dir 'static' and for html, css  and original logic and behaviour see doc-rocker-svelte.md
4. Should we port all Svelte endpoints and features (e.g., `/api/chat`, `/api/rock`, MCP server), or only the main UI flow?
   Answer: all of it (from a users perspective nothing is allowed to change) and api-users are included here
5. Which auth/OAuth flows should be preserved (if any)? The Svelte README mentions Google OAuth.
   Answer: same as now - do not add (simple to none)
6. What is the desired "more professional" streaming UX? Examples: partial answer streaming, per-source progress, cancel button, retry, persistent history, etc.
   Answer: Working-Status and partial, separate answer information (checking ..., ) not too detailed just to keep the user interested
7. Are there preferred Phoenix stack choices (Tailwind vs custom CSS, esbuild vs asset pipeline)?
   Answer: most native LiveView as possible - no actual change - take it as it is and change minimal - the UI/UX has to be the same
8. Any target hosting constraints (Fly.io, Render, Gigalixir, self-hosted) that affect config?
   Answer: Self hosted in docker
9. Should we keep PWA behaviors (manifest, service worker) from Svelte?
   Answer: yes keep
10. Are API keys and providers the same (Perplexity/Tavily/Combiner), or should we change integrations?
    Answer: exactly same services are to be used - therefore also api keys

## Decisions

- No `/api/mcp` endpoint exists; MCP support is via an external stdin wrapper that calls the normal API.
- No `/api/auth` endpoint exists in the source.
- Phoenix app name: `doc_rocker` (module `DocRocker`).

## Migration Learnings (project-specific)

- Original project static assets are now available in `static`.
- `doc-rocker-svelte.md` is the authoritative reference for UI/CSS/behavior.
- Source system analysis artifacts are available in `PORTING_OVERVIEW.html` and `PORTING_OVERVIEW.puml` (diagram in `PORTING_OVERVIEW.svg`).
- MCP support is external (stdin wrapper), not an in-app HTTP endpoint.
- If something is not present in `doc-rocker-svelte.md`, treat it as non-existent.
