## Project Rules (User-Provided)

- Re-implement Doc-Rocker/Dock Rocker in Elixir Phoenix LiveView.
- Product name confirmed: Doc-Rocker (documentation search app).
- UI must match the existing Svelte UI exactly.
- Improve streaming response UX using LiveView capabilities (more professional experience).
- Create a new Phoenix project in the repo root.
- Reuse original assets from `static` and UI/CSS/behavior from `doc-rocker-svelte.md`.
- If something is not present in `doc-rocker-svelte.md`, treat it as non-existent.
- Full feature parity, including all API endpoints and API users.
- No new auth flows; keep simple/none as current.
- Streaming UX: show working status and partial/segmented updates (high-level, not too detailed).
- Prefer native LiveView defaults; minimize tech changes to preserve UX/UI.
- Target hosting: self-hosted via Docker.
- Preserve PWA behavior (manifest + service worker).
- Use the same external providers and API keys (Perplexity/Tavily/Combiner).
- Maintain `TASK.md` as the migration status file, including open questions and migration learnings.
- Capture general Elixir/tech-stack learnings in a separate markdown file.
- Commit to git at milestones (frequent, especially during bootstrap) using concise one-line commit messages.
- Persist all user requirements and guidelines in `AGENTS.md` when provided.
- Do not ask whether to persist important information; decide and persist autonomously.
- Do not repeatedly ask for confirmation once instructions are recorded; follow the agreed rules.

---
- DO NOT CHANGE THE PART - STARTING FROM HERE -
---

## Path of See, think, act

Please always follow the path: **See, think, act!**

To put it in different words:

- First analyse the situation
- Understand the situation
- Make a plan
- Revise the plan
- In case of any unclarities please ask for clarification
- ... and when those points are clear then then act

Do **NOT** do workarounds or hacks just to get things done. We are working professionally here.
You may experiment to find new ways but have to come back to the path of sanity in the end ;)

## Trust But Verify - Avoiding Overconfident Speculation

Don't get trapped by your own reasoning! When analyzing problems:

- **Gather Evidence Before Concluding**: Every claim about system behavior must be backed by actual data - logs, code inspection, or test runs. Avoid pure speculation.
- **Make Hypotheses Explicit**: State assumptions clearly ("Hypothesis: callback wasn't called → Need evidence: check logs/code"). This prevents tunnel vision.
- **Verify Each Assertion**: Before finalizing any explanation, ensure every key claim has supporting evidence from tool calls, file reads, or direct observation.
- **Flag Confidence Levels**: Mark uncertain statements as speculative and immediately seek verification through available tools rather than building elaborate theories.
- **Question Your Assumptions**: If you find yourself explaining complex behavior without direct evidence, step back and gather data first.

## Complexity

If the request is a bit more challenging or you seem stuck use the MCP sequential-thinking.

## Need more information ?

- Think first
- if still questions are open then collect information at your hand
- if still questions are open then ask in a structured way

# Guidelines for planning/architect

Let's stay in discussion before switching to 'Code' longer as we have to make sure things are clear before starting the implementation:

Stick to the architect mode (or talk mode or ask mode) until the following is clear:

- Make sure the topic is understood by you
- Make sure all aspects of the change are tackled like UI, Backend, data storing - whatever applies for the task at hand
- Think about a good solution while keeping it simple
- We want to start implementing when things are clear
- Ask question if you think something could be unclear
- Do not overshoot though - keep it rather simple and ask if unsure
- We want to make sure that we talk about the same thing that lies in the task description
- Stay on a short, concise and to the point level of detail
- Let's talk about behaviour and the big picture.
  - Code should only be used to communicate if it is the cleares way to agree on the specification
  - If you think that a code change is necessary, make sure to explain why it is necessary and how it should look like

## The Architect Handshake Protocol

Keep in mind: We are partners and do pairing here so I am not your boss.
But pairing needs both of us to be on the same page before changing any system.

  To maintain architectural integrity and ensure mutual alignment, strictly separate investigation, planning, and action:

1. Investigation Phase: When asked to "analyze" or "investigate," provide a report based on evidence (logs, code inspection). STOP after delivering findings. Do not propose or execute a fix in this turn.
2. The Handshake (RFC): Before any modification, present a "Design Proposal" including:
   * Evidence: The specific findings that necessitate the change.
   * Logic: The conceptual "Why" and "How" of the solution.
   * Impact: Potential side effects or risks to the system.
   * Implementation: The exact files and functions to be modified.
   * WAIT: Do not call modification tools (e.g., replace, write_file) in the same turn as the proposal. Await explicit user approval (e.g., "Go", "Approved", "Proceed").
3. Surgical Implementation: After approval, execute the plan with the minimal changes necessary. Do not deviate from the approved plan without returning to the Handshake phase.

# Guidelines for coding

It is important to follow these guidelines when creating or adapting code:

- Create structured code that is easy to understand and maintain
- Make classes where possible instead of simple functions
- Structure the code in files according to their purpose / intent
- How to ideally approach the task:
  - Understand the task
  - Understand the codebase
  - Create a plan
  - Create classes and interfaces
  - Write the specification as test code
  - Implement the code and iterate until the tests pass
  - If you find more specification to be written as useful during implementation, write it as test code
  - In case you change existing code, adapt the specification first

## When running python code in a UV project (uv.lock)

- Run `uv run python <file>.py` to run the code

# Web Research

When the user requests web research, always use both the built-in web search to gather comprehensive,
up-to-date information for the year 2025 while never including sensitive data in search queries.

# What some short instructions actually mean

- "go" ==> actually means "go ahead and continue"
- "do web research" or "conduct web research" ==> use whatever you have at hand to do proper web research matching the topic at hand
- "analyse" ==> means "ANALYSE and do not edit files in the project"
  - I am serious about this.
  - When I want you to analyse then I want you to get familiar and create yourself a full picture
  - Might include web research from your side if it helps to analyse a situation

# More of important rules

## When asked to analyse something

When asked to analyse something then do so with oversight and use of different sources like documentation, description files and source code that seems relavant for the investigation.

Do not call modification tools (e.g., replace, write_file) in the same turn as the proposal. Await explicit user approval (e.g., "Go", "Approved", "Proceed")

## When asked to fix something

When asked to fix something, or add a feature always make minimal changes necessary like a surgeon
to get it done without changing existing code that is not related to the request.
If you are unsure please ask.

---
- DO NOT CHANGE THE PART - ENDING HERE -
---
