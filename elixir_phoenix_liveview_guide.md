# Elixir, Phoenix, and LiveView: Production Architecture Guide (2025)

This guide outlines the "Golden Path" for building production-ready Elixir applications using Phoenix, LiveView, and GenServer, based on modern BEAM ecosystem patterns.

---

## 1. Application Architecture: The "Context" Pattern

The core philosophy of a Phoenix application is the strict separation of **Business Logic (Core)** from the **Web Interface (Boundary)**.

### Standard Directory Structure (Phoenix 1.7+)

```text
lib/
├── my_app/                # THE CORE: Pure business logic & Data
│   ├── accounts/          # Context: User, Session, Registration
│   │   ├── user.ex        # Ecto Schema
│   │   └── accounts.ex    # Public API for this context (Public functions)
│   ├── orders/            # Context: Cart, Checkout, Pricing
│   ├── repo.ex            # Database wrapper (Ecto)
│   └── application.ex     # Supervision Tree (The heart of the app)
└── my_app_web/            # THE BOUNDARY: UI & External Interface
    ├── components/        # Reusable HEEx components (CoreComponents.ex)
    ├── controllers/       # Standard REST/HTTP controllers
    ├── live/              # LiveView modules
    │   ├── order_live/    # Grouped by domain/resource
    │   │   ├── index.ex   # LiveView (Stateful process)
    │   │   └── index.html.heex # Template (Can also be inline)
    ├── router.ex          # Routes & Pipelines
    └── endpoint.ex        # Plug pipeline & WebSocket entry
```

### Best Practices
- **Contexts as APIs**: `MyAppWeb` should never call `MyApp.Repo` directly. It should call `MyApp.Accounts.get_user!(id)`.
- **Fat Contexts, Skinny LiveViews**: Keep LiveViews focused on UI state and event handling. Move business logic, complex queries, and external API integrations into Context modules.

---

## 2. LiveView Management

LiveView processes are stateful Elixir processes (GenServers) that manage a specific user's connection.

### State Management in LiveView
- **Socket Assigns**: Use `assign(socket, :key, value)` for UI-specific state (e.g., `is_loading`, `form_errors`).
- **`assign_async/3`**: Critical for responsiveness. Fetch data in the background without blocking the initial page mount.
- **`on_mount` Hooks**: Use for cross-cutting concerns like Authentication, Authorization, or Analytics.

### Components
- **Function Components**: Use for stateless, reusable UI (buttons, inputs, cards).
- **LiveComponents**: Use when a part of the UI has complex **internal state** (e.g., a multi-step modal) that shouldn't clutter the parent LiveView.

---

## 3. Process Management with GenServer

In Elixir, **GenServers** are used for state that needs to live outside a single user session or for background coordination.

### Common Production Use Cases
1.  **Shared State**: Global caches, rate-limiters, or game lobby states.
2.  **Concurrency Bottlenecks**: Serializing access to a single resource (e.g., a specific hardware device or a rate-limited external API).
3.  **Background Work**: Long-running tasks (though for mission-critical jobs, `Oban` is the standard).

### The Supervision Tree
Processes must always be supervised to ensure fault tolerance.

```elixir
# lib/my_app/application.ex
def start(_type, _args) do
  children = [
    MyApp.Repo,                          # Database
    {Phoenix.PubSub, name: MyApp.PubSub},# Messaging
    MyAppWeb.Endpoint,                   # Web Server
    MyApp.Caches.UserCache,              # Custom GenServer
    {DynamicSupervisor, name: MyApp.OrderSupervisor, strategy: :one_for_one}
  ]
  Supervisor.start_link(children, strategy: :one_for_one)
end
```

**Key Patterns:**
- **DynamicSupervisor**: For starting processes on-demand (e.g., one process per active "Streaming Session").
- **Registry**: For looking up dynamic processes by name/id rather than PID.

---

## 4. State Management Strategy: Where does it go?

| Data Type | Recommended Location | Reason |
| :--- | :--- | :--- |
| **User Inputs / UI Toggles** | `LiveView.assigns` | Local to the user, ephemeral. |
| **Global Config / Cache** | `GenServer` | Shared across all users and processes. |
| **Persistent Data** | `PostgreSQL / Ecto` | Must survive application restarts. |
| **Real-time Updates** | `Phoenix.PubSub` | Decouples the data source from the UI. |

---

## 5. The "Golden Rule" of Elixir Processes

> **"Do not use a GenServer for code organization; use it for runtime requirements."**

If your code is just a collection of functions, put it in a module. Only use a GenServer if you need to:
1.  Maintain state over time.
2.  Provide a centralized point of contact (concurrency control).
3.  Handle asynchronous operations.

---

---

## 7. Rapid Prototyping: Phoenix Playground

For single-file applications, demos, or rapid prototyping without a full project structure, use `phoenix_playground`.

### Usage Pattern
Create a single `.exs` file and run it with `iex`:

```elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.8"}
])

defmodule MyAppLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: "Hello from Playground!")}
  end

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <h1 class="text-2xl font-bold">{@message}</h1>
    </div>
    """
  end
end

PhoenixPlayground.start(live: MyAppLive)
```

**Pros:** No boilerplate, single file, instant startup.
**Cons:** Not suitable for large-scale production, no built-in Ecto management by default.

---

## 8. Real-time File System Watching

To monitor file changes (e.g., for a "Filesystem as SSOT" architecture), use the `file_system` library.

### Implementation Pattern

1. **Add Dependency**:
   ```elixir
   {:file_system, "~> 1.0"}
   ```

2. **Create a Watcher GenServer**:
   ```elixir
   defmodule MyApp.FileWatcher do
     use GenServer

     def start_link(args) do
       GenServer.start_link(__MODULE__, args, name: __MODULE__)
     end

     def init(args) do
       # args usually contains :dirs to watch
       {:ok, watcher_pid} = FileSystem.start_link(args)
       FileSystem.subscribe(watcher_pid)
       {:ok, %{watcher_pid: watcher_pid}}
     end

     def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
       # path is the absolute path to the file
       # events is a list like [:modified, :closed]
       if String.ends_with?(path, "target_file.json") and :modified in events do
         # Take action (e.g., broadcast update)
       end
       {:noreply, state}
     end
   end
   ```

3. **Supervise It**:
   ```elixir
   children = [
     {MyApp.FileWatcher, dirs: ["./data"]}
   ]
   ```

## 9. Executing External Commands (Ports)

For running shell commands while maintaining responsiveness and persistence.

### Implementation Pattern

1. **Use a Dedicated GenServer**: Offload command execution to a separate process to avoid blocking the LiveView.
2. **Handle Output Asynchronously**:
   - Use `Port.open({:spawn, command}, [:binary, :exit_status, :stderr_to_stdout])` to start the process.
   - Buffer output to avoid overwhelming the UI with high-frequency updates.
   - Periodic "flushing" (e.g., every 100ms) to the global state/PubSub is recommended.
3. **Shell Safety**: Use absolute paths for wrappers/executables and be cautious with user input interpolation.

### Persistence Strategy
- **GenServer Lifetime**: Since GenServers live in the application supervision tree, they survive client disconnections.
- **State Serialization**: Save command output to a persistent store (JSON, Database, etc.) so it can be recovered when a client reconnects.

---

## 10. Background Processing & PubSub Integration

| Feature | Pattern | Benefit |
| :--- | :--- | :--- |
| **Long-running Task** | GenServer + Ports | Decouples UI from execution; survives browser close. |
| **Real-time Sync** | PubSub Broadcast | Updates all connected clients when background state changes. |
| **Buffered Updates** | `Process.send_after` | Prevents UI flickering/flooding during high-output tasks. |
