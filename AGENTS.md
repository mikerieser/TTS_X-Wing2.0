# Local Codex Guidance — X-Wing Unified Mod

You are working on the **X-Wing Unified Mod** for Tabletop Simulator, including **HotAC** and **FGA**. Treat this as a long-lived extensible codebase, not a script-generation project.

## Environment

* **TTS** = Tabletop Simulator; Lua 5.2 / MoonSharp.
* Main roots: `TTS_xwing/src`, `TTS_lib`.
* Use TTS-compatible APIs and types; use `Vector(...)` where TTS expects vectors.
* Prefer existing module/`require` conventions over embedded code strings or ad-hoc loaders.
* Prefer the existing `Sequence` abstraction for ordered async workflows.
* Preserve LF normalization; `.gitattributes` is authoritative.
* Verify X-Wing/Epic/HotAC/FGA/card/mission rules rather than assuming behavior.

When repo access is available, the **current repo and branch are the source of truth**. Do not rely on remembered code, old handoffs, or previously pasted snippets when the implementation can be inspected.

Task handoff documents describe specific investigations. Treat them as task context, not permanent architecture or global requirements, unless the user explicitly resumes that work.

# Understand Before Designing

Before proposing a change:

1. Establish the actual call path and current behavior.
2. Locate implementation, callers, tests, similar behavior, and extension points.
3. Inspect existing state ownership and module boundaries.
4. Identify what can be reused.
5. Only then design the change.

Search before designing. Do not infer surrounding architecture from an isolated function or file when repo context is available.

Do not invent TTS APIs, object fields, module contracts, or game rules. Verify uncertain behavior using repository usage, authoritative documentation, or supplied rule sources.

# Software Design Framework

Reason from the **smallest applicable scope outward**:

1. **Local code and data flow** — correctness, naming, cohesion, duplication, control flow, and state management.
2. **Object-oriented fundamentals** — encapsulation, abstraction, composition, polymorphism, inheritance, cohesion, coupling, and state ownership.
3. **GRASP** — who knows, creates, coordinates, or owns the behavior?
4. **Principles** — SOLID, information hiding, dependency direction.
5. **Patterns** — GoF, Lua idioms, recurring solutions.
6. **Application architecture** — modules, layers, DDD, hexagonal/clean boundaries, event-driven designs.
7. **System architecture** — subsystem boundaries, bounded contexts, integration patterns.

Adapt this OO-influenced framework naturally to Lua. Modules, tables, functions, closures, first-class functions, metatables, and composition may be better than classes.

**Core rule: Start local. Escalate on evidence.**

Fix problems at the lowest level that addresses the root cause. Do not escalate when responsibility assignment, cohesion/coupling, state ownership, or a local interface is sufficient.

Do not use:

* a pattern when better responsibility assignment is enough;
* an abstraction merely because code looks similar;
* a new module when an existing owner is appropriate;
* architecture to solve a local object/module problem.

Escalate only for concrete evidence or a genuine higher-order constraint. Push higher-level constraints downward only as far as necessary and keep exceptions localized.

Once escalation is justified, evaluate lower-level choices within that broader context.

Recurring local problems are evidence of broader pressure, not proof.

For substantive design recommendations, state the **diagnosed design level**, the **conflict**, and **why escalation is necessary**.

# Refactor-First Stewardship

## Prime Directive

Prefer **surgical changes** to existing code.

Current working behavior and public APIs are the default specification unless a change is explicitly requested.

## Reuse Before Rewrite

Before creating anything new, look for an existing implementation, service, module, helper, strategy, adapter, test fixture, or extension point.

Prefer:

**reuse → adapt → repair → extract → create**

Do not create parallel implementations.

Extract abstractions only when responsibility, repeated behavior, or genuine variation justifies them.

## Preserve Behavior

Refactors preserve observable behavior unless behavior change is explicit and tested.

Do not remove edge cases or simplify code whose purpose is not understood.

Keep refactoring separate from behavior changes unless combining them is explicitly justified.

## Minimal Surface Change

Prefer small patches, focused function changes, responsibility redistribution, adapters, composition, strategies, callbacks, and narrow interfaces.

Avoid broad rewrites, unnecessary moves/renames, speculative frameworks, new layers, and public API changes.

## Repair Before Replace

For bugs:

**reproduce/characterize → understand current path → repair → regression test**

Do not replace a subsystem merely because a cleaner rewrite is possible.

# Responsibilities and Extensibility

Apply **OCP** where real variation exists.

Prefer extension using composition, strategies, callbacks, registration, adapters, mixins, configuration, plugins, or data-driven definitions.

Create extension points only where concrete pressure demonstrates a need, such as:

* existing variants;
* known upcoming variants with identified requirements;
* demonstrated external-content needs;
* repeated modification of otherwise stable code.

Prefer a narrow seam over a generalized framework.

Use GRASP to place behavior appropriately:

* **UI/TTS callbacks:** display, input, event translation, API invocation.
* **Services/coordinators:** workflow and orchestration.
* **Domain modules:** game rules and behavior.
* **Adapters:** TTS/runtime interaction.

Keep TTS/UI adapters and controllers thin. Place behavior with the object or module that has the information needed to perform it, using a service/coordinator when the responsibility genuinely spans multiple owners.

Do not allow UI objects, controllers, or services to accumulate unrelated behavior merely because they are convenient call sites.

# Lua Style

Prefer idiomatic Lua over Java mechanically translated into Lua.

Prefer cohesive objects or modules that own related state and behavior over procedural functions operating on shared mutable tables or globals.

Use modules, tables, closures, first-class functions, metatables, composition, and mixins where they make responsibilities clearer.

Prefer composition over inheritance unless the relationship is genuinely substitutable.

Classes/prototypes are useful when state and behavior naturally form cohesive instances; they are not the default solution for every responsibility.

Prefer polymorphism/delegation over repeated type-conditionals when actual behavioral variation exists.

Use metaprogramming when it clarifies or removes meaningful duplication; avoid cleverness that obscures behavior.

Keep mutable state ownership explicit. Avoid new globals when an existing object/module can own the state.

Keep TTS callbacks such as `onLoad`, `onDrop`, and `onObject*` thin: translate runtime events, then delegate to the appropriate domain object, module, or coordinator.

Use intention-revealing X-Wing/HotAC/FGA domain names.

Comment constraints, non-obvious decisions, and TTS quirks. Do not use comments to compensate for poor naming or structure.

Use EmmyLua annotations for public APIs, TTS-facing values, and complex table shapes when they materially improve understanding/tooling. Do not annotate trivial private code merely for ceremony.

`TTS_xwing/src/Game/Mechanic/Movement/Maneuver.lua` is a useful local example of metatable-based polymorphism/Strategy **when similar variation exists**. It is an example, not a mandate to model unrelated code the same way.

# Sequence / Async

Before adding nested `Wait` callbacks or a new workflow abstraction, inspect `TTS_lib/Sequence/Sequence.lua`.

Current `Sequence` contracts include:

* `addStep`
* `addTask`
* `usePlugin`
* ordered continuation through `next()`
* `Sequence:new(true)` loading the established Click and Cast plugins

Use `Sequence` for dependent asynchronous operations when it clarifies ordering.

It is not necessary to wrap every isolated callback in a Sequence.

Preserve:

* step ordering;
* TTS frame/timing requirements;
* continuation behavior;
* plugin contracts;
* current timeout and failure behavior.

Avoid callback pyramids and competing async frameworks without compelling evidence.

# Mission Architecture

Mission APIs should express **what the mission requires**, not low-level TTS mechanics.

Reuse existing spawning, geometry, movement, AI, objective, event, phase, token, campaign, and other domain capabilities.

When mission behavior repeats, consider in order:

1. existing service/domain module;
2. reusable mission capability;
3. narrow extension point;
4. new subsystem only when justified.

Do not build a generalized mission framework because one mission is unusual.

Mission-specific behavior should remain mission-specific when no real reusable responsibility exists.

# Rules-Driven Development

**Do not assume behavior — verify it.**

For rules-driven work:

1. identify authoritative source(s);
2. establish applicable base X-Wing/Epic behavior;
3. identify HotAC/FGA modifications;
4. check mission-specific rules;
5. check relevant card/ability text;
6. determine any explicit precedence;
7. map the verified result into code.

Do not silently invent precedence between conflicting sources. Identify ambiguity when the sources do not resolve it.

For rules answers or implementations, cite the rule source and page when available.

# Testing

Use **TDD** where practical with LuaUnit-TTS.

For existing untested behavior, add characterization coverage before risky changes when practical.

For bugs, add regression tests.

For new behavior, add focused behavior tests.

Test externally meaningful behavior rather than implementation details.

As behavior moves to a clearer owner, prefer focused tests at the new boundary while retaining broader integration coverage only where it still proves useful wiring.

Isolate TTS dependencies when that improves cohesion and testability.

## LuaUnit-TTS Conventions

The harness is under `TTS_xwing/src/Test`.

Follow the nearest applicable test example rather than assuming one universal entry point.

Important existing conventions:

* Use `require("Test.luaunit_tts")`.
* Auto-discovered test classes are globals whose names begin with `Test`.
* Module-local test tables can be assigned into `_G` by a runner.
* Assertions use **expected first, actual second**.
* `TestMain.lua` and `GlobalSuite.lua` represent distinct test paths.
* `LuaUnit:run()` is asynchronous in TTS; do not assume its return means the suite has completed.

## Verification Claims

Never claim a TTS-dependent test passed unless supported by:

* user-provided TTS output; or
* captured output from an automated runner that actually observes suite completion.

A successful bundle, send, reload, command invocation, or printed diagnostic is not by itself proof that TTS tests passed.

State clearly:

* what was verified locally;
* what was verified in TTS;
* what still requires TTS verification.

# Runtime Safety and Performance

Treat frequently invoked callbacks such as `onUpdate` carefully.

Avoid unnecessary:

* repeated searches;
* allocation;
* physics casts;
* object spawning;
* coroutine/yield work;
* TTS API calls.

Optimize in response to demonstrated frequency, cost, or measurement rather than speculation.

Prefer explicit contextual failure over silent failure.

Choose `print`, `log`, `printToAll`, UI feedback, or another reporting mechanism based on the intended audience. Do not expose every internal diagnostic to all players.

# Git and Working-Tree Safety

Treat every repository as a brownfield worktree.

Before modifying files, inspect the current branch/status and preserve all pre-existing changes.

Do not assume an existing dirty file belongs to Codex.

Do not use destructive cleanup commands such as:

* `git reset --hard`
* `git checkout -- <file>`
* broad restore/clean operations

unless the user explicitly requests them.

Do not pull, rebase, merge, push, force-push, create a PR, or create/publish a remote repository without explicit user approval.

For this X-Wing clone:

* `origin` is upstream and is **not** a push target.
* Push only explicitly approved topic branches to the `miker` fork.
* Never push or force-push `master` without explicit authorization.

Stage specific files and inspect the staged diff before committing.

Do not mix unrelated working-tree changes into the task.

Work from current upstream on narrow topic branches. Read-only `git fetch` is allowed when needed to establish current upstream state; pulling, rebasing, or merging remains subject to explicit user approval.

Preserve existing public APIs and extension contracts unless the task explicitly requires changing them.

# Workflow for Substantive Coding Work

Apply this workflow proportionally. Tiny, mechanical, or one-line changes do not require a formal plan or every reporting section.

## Repo Scan

Locate implementation, callers, tests, similar behavior, and extension points. State what will be reused.

## Diagnose

Identify the root issue at the **lowest applicable design level**. Escalate only when necessary.

## Change Plan

For substantive changes, give 3–7 bullets covering what stays, what changes, why, and what existing code will be reused.

## Patch

Prefer minimal diffs or focused replacements with file/function names. Avoid whole-file rewrites unless unavoidable.

## Integration Proof

Show changed call sites, registration, or wiring so it is clear the implementation is actually used.

## Tests

Add/update the smallest meaningful tests for preserved and changed behavior.

## Verification

Separate local/static verification from actual TTS runtime verification.

## Rationale

Briefly identify the relevant design level and explain why the change is sufficient.

# Response Format

For substantive implementation work:

**Change Plan → Patch → Tests → Verification → Rationale → Migration Notes**

Include **Migration Notes** only when public behavior or contracts change.

For design reviews:

**Finding → Design Level → Recommendation → Escalation (if needed) → Example**

Do not force patch format onto conceptual/design discussions.

# Guardrails

Do not:

* rename/move files unnecessarily;
* change public APIs without need;
* duplicate existing capabilities;
* create parallel modules;
* perform sweeping rewrites;
* add architecture for purity;
* remove edge cases without understanding them;
* replace `Sequence` with callback nesting;
* force class hierarchies where simpler Lua constructs fit;
* assume TTS/game behavior that can be verified.

Do:

* preserve compatibility;
* reuse existing abstractions;
* improve cohesion and state ownership;
* reduce inappropriate coupling;
* prefer composition and narrow APIs;
* add tests;
* create extension points only for demonstrated variation;
* leave the code easier to understand than before.

# Core Principles

**Understand before changing. Start local. Escalate on evidence. Repair before replace. Reuse before creating. Preserve behavior unless change is intentional. Put responsibilities where they belong. Prefer idiomatic Lua, composition, and narrow APIs. Use patterns only when the problem earns them. Extend for real variation, not imagined futures. Verify game and TTS behavior rather than assuming it.**
