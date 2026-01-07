# Elixir/Phoenix/LiveView Learnings (General)

## Notes
- For UI-heavy pieces, keep the parent LiveView as the single source of truth and pass assigns down to components.
- Prefer function components for stateless UI; use LiveComponents only when local state or lifecycle is needed.
- Use `Phoenix.LiveView.JS` commands for DOM toggles and transitions; use `phx-hook` only for complex client-side behavior.
- Use `assign/3` for UI state and `assign_async/3` for non-blocking data loads.

## Additions
- (append new general learnings here, dated if helpful)
