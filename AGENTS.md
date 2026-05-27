# AGENTS.md - TTS X-Wing 2.0

## Authority

This project adopts the AA Hangar AI Constitution for governance.

Authority order:
1. AA Hangar AI Constitution (source laws and skills)
2. This AGENTS.md (project-specific operating rules)
3. Local code conventions in this repository

Constitution path in workspace:
- `../American Airlines/Constituion AI/hangar-ai-constitution`

---

## Project Context

- Product: Star Wars X-Wing 2.0 on Tabletop Simulator
- Runtime: Tabletop Simulator Lua (MoonSharp / Lua 5.2 constraints)
- Test framework: TTS-LuaUnit (executed in TTS sandbox)
- Spec folder: `hangar-ai-specs/` (ENG-11.1)
- **AI constraint:** AI agent cannot execute sandbox-integrated tests directly — all verification is human-supplied from TTS console output

---

## ⛔ MANDATORY AGENT PROTOCOL (ENG-4.1 — Manual Verify Variant)

**Every coding task MUST follow this 8-step cycle. No exceptions.**

```
Step 1 — IDENTIFY   Find the FIRST unchecked task in tasks.md
                     Read the linked spec scenario ID
                     ↓
Step 2 — RED        Write EXACTLY ONE failing test
                     ⛔ DO NOT write production code yet
                     ↓
Step 3 — HUMAN      Human drops checker in TTS and pastes console output
         VERIFY RED  Output must confirm FAILED for this test
                     ⛔ AI must not proceed if output is ambiguous
                     ↓
Step 4 — GREEN      Write MINIMUM code to make that ONE test pass
                     ↓
Step 5 — HUMAN      Human reruns checker; output must confirm PASSED
         VERIFY GREEN ⛔ AI must not proceed until human confirms
                     ↓
Step 6 — REFACTOR   Improve structure only — no behavior changes
                     ↓
Step 7 — HUMAN      Human reruns checker; full suite must stay green
         VERIFY      ⛔ AI must not proceed if any test regresses
         REFACTOR
                     ↓
Step 8 — UPDATE     Mark task [x] in tasks.md with timestamp
                     Record evidence in verification-log.md
                     Commit with spec scenario ID in message (ENG-6.7)
                     STOP AND REPORT — wait for human before next cycle
```

---

## Evidence Requirements (ENG-6.7)

For each cycle, record in `hangar-ai-specs/changes/<change-id>/verification-log.md`:

| Field | Required |
|---|---|
| Test name | ✓ |
| Timestamp | ✓ |
| RED output summary | ✓ |
| GREEN output summary | ✓ |
| REFACTOR verification summary | ✓ |
| Human verifier initials | ✓ |

---

## Brownfield Defaults (skill-12-legacy-refactor-rhythm)

Per ENG-4.14 and ENG-1.3:

1. **Preserve stack** — No language rewrite without explicit human approval.
2. **Characterize first** — Add characterization tests before changing any legacy behavior.
3. **Vertical slices** — One player-visible behavior per change (ENG-1.4).
4. **Atomic commits** — One test OR one violation per commit; no `git add -A` (ENG-4.14).
5. **Evidence-backed** — Never claim a test passed without human-provided TTS output.

---

## AI + Human Pairing Rules (ENG-1.2)

1. AI proposes tests and code; human runs all in-sandbox verification.
2. AI does not claim tests passed unless human-provided console output confirms it.
3. If output is ambiguous, treat as failed until clarified.
4. Every recommendation MUST cite a relevant law ID.
5. Human confirmation required before advancing to the next cycle.

---

## Scope Guardrails (ENG-2.3)

1. Do not rewrite whole subsystems in one change.
2. Do not touch files outside the current task scope.
3. Keep task slicing aligned with player-visible behavior.
4. Large changes MUST be broken into vertical slices before starting.

---

## Hangar SDD Structure (ENG-11.1)

```
hangar-ai-specs/
├── changes/          # Active proposals (PROPOSE → IMPLEMENT)
│   └── <verb-noun-id>/
│       ├── PROPOSAL.md   # Must include ≥1 law citation (ENG-11.2)
│       ├── tasks.md
│       └── verification-log.md
├── specs/            # Current system truth documents (ENG-11.3)
└── project.md        # Project context
```

Lifecycle: `PROPOSE → IMPLEMENT → ARCHIVE`
Completed changes move to `hangar-ai-specs/archive/YYYY-MM-DD-<id>/`

---

## Relevant Skills

| Skill | Use When |
|---|---|
| `skill-06-atomic-tdd` | Writing any new test or production code |
| `skill-12-legacy-refactor-rhythm` | Characterizing or refactoring legacy Lua code |
| `skill-09-refactoring` | Extracting classes / reducing complexity |
| `skill-spec-governance` | Scaffolding a new `hangar-ai-specs/changes/` entry |
