# Doc-Rocker -> Phoenix LiveView Migration

## Initial Request
- Re-implement the Doc-Rocker (SvelteKit) app as an Elixir Phoenix LiveView app.
- UI must look exactly the same as the current Svelte version.
- Improve streaming response UX using LiveView capabilities.
- Maintain this file as the single source of truth for migration status and project-specific learnings.
- Capture general Elixir/tech-stack learnings in a separate file.

## Goal
- Feature-parity LiveView app with identical UI and improved streaming UX.
- Clear migration status and decisions tracked in this file.

## Status
- Current phase: Discovery
- Completed:
  - Read `elixir_phoenix_liveview_guide.md`.
  - Reviewed `doc-rocker-svelte.md` (Svelte structure and behavior notes).
  - Consulted doc expert agent for LiveView UI-heavy component patterns.
- Next:
  - Await answers to open questions.
  - Define target Phoenix project structure and assets.

## Open Questions (need answers before implementation)
1. Confirm the correct product name and scope: is this "Doc-Rocker" (documentation search app) or "Dock Rocker" (different UI)?
2. Where should the Phoenix LiveView app live: new Phoenix project or integrate into an existing repo?
3. Are there source assets we must reuse for exact UI parity (logos, icons, fonts, images, CSS)? If yes, where are they?
4. Should we port all Svelte endpoints and features (e.g., `/api/chat`, `/api/rock`, MCP server), or only the main UI flow?
5. Which auth/OAuth flows should be preserved (if any)? The Svelte README mentions Google OAuth.
6. What is the desired "more professional" streaming UX? Examples: partial answer streaming, per-source progress, cancel button, retry, persistent history, etc.
7. Are there preferred Phoenix stack choices (Tailwind vs custom CSS, esbuild vs asset pipeline)?
8. Any target hosting constraints (Fly.io, Render, Gigalixir, self-hosted) that affect config?
9. Should we keep PWA behaviors (manifest, service worker) from Svelte?
10. Are API keys and providers the same (Perplexity/Tavily/Combiner), or should we change integrations?

## Decisions
- None yet.

## Migration Learnings (project-specific)
- None yet.
