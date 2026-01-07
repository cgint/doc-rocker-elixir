# Bugfix Log

## Issue: LiveView reconnect delay and unresponsive UI after reload

**Observed behavior**
- After page reload, LiveView reconnect takes ~10 seconds.
- Button clicks are slow or unresponsive.
- LiveView crashes on input changes; reconnects via longpoll.

**Console/server log (excerpt)**
```
[info] CONNECTED TO Phoenix.LiveView.Socket ... Transport: :longpoll
[debug] MOUNT DocRockerWeb.HomeLive
[debug] HANDLE EVENT "toggle_pick" in DocRockerWeb.HomeLive
[debug] HANDLE EVENT "validate" in DocRockerWeb.HomeLive
[error] GenServer ... terminating
** (FunctionClauseError) no function clause matching in DocRockerWeb.HomeLive.handle_event/3
    lib/doc_rocker_web/live/home_live.ex:42: DocRockerWeb.HomeLive.handle_event("validate", %{"_target" => ["query"], "query" => "h"}, ...)
Last message: %Phoenix.Socket.Message{event: "validate", value: "query=h", ...}
```

**Additional repro (pick toggle then type, before clicking any button)**
```
[debug] HANDLE EVENT "toggle_pick" in DocRockerWeb.HomeLive
  Parameters: %{"index" => "2", "value" => ""}
[debug] HANDLE EVENT "validate" in DocRockerWeb.HomeLive
  Parameters: %{"_target" => ["query"], "query" => "s"}
[error] GenServer ... terminating
** (FunctionClauseError) no function clause matching in DocRockerWeb.HomeLive.handle_event/3
    lib/doc_rocker_web/live/home_live.ex:42: DocRockerWeb.HomeLive.handle_event("validate", %{"_target" => ["query"], "query" => "s"}, ...)
Last message: %Phoenix.Socket.Message{event: "validate", value: "query=s", ...}
```

**Impact**
- LiveView process terminates on input, causing reconnect delays and stalled UI events.

**Likely cause**
- `handle_event("validate", ...)` expects `%{"chat" => %{"query" => _}}` but the form submits `query` at the root level because the `<textarea>` has `name="query"` explicitly set. This leads to a `FunctionClauseError`.

**Next fix candidate**
- Accept both shapes in `handle_event/3` or align the form field naming with the handler.

**Fix applied**
- `handle_event("validate", ...)` now accepts both `%{"chat" => %{"query" => _}}` and `%{"query" => _}` payloads, falling back to the last assigned query.

**Status after fix**
- User still reported the same `FunctionClauseError` with the old `%{"query" => "s"}` payload, which indicates the running BEAM likely did not reload the updated module. Next check: restart `mix phx.server` (or run `mix clean` then restart) to ensure the new `handle_event/3` clause is loaded.

## Issue: Browser console shows unknown LiveView hooks + service worker Response error

**Observed behavior**
- Browser console logs repeat `unknown hook found for "ScrollHandler"`, `"InputField"`, `"DocumentationPicks"`.
- Service worker throws `Uncaught (in promise) TypeError: Failed to convert value to 'Response'.`
- LiveView falls back to longpoll and UI responsiveness degrades.

**Likely cause**
- Service worker caches stale `app.js` or serves an invalid response when a request fails, so the LiveView JS that defines hooks is not the current one.
- SW `fetch` handler can resolve to `undefined` on non-navigate requests, which triggers the `Failed to convert value to 'Response'` error.

**Fix applied**
- Disable service worker registration on localhost and unregister existing SWs in dev.
- Update SW `fetch` handler to always return a valid `Response` and skip `/live` requests.
- Bump SW cache version to invalidate stale assets.
