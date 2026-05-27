# AGENTS.md — TTS X-Wing 2.0

## Repository Purpose

Lua scripts and assets for a Star Wars X-Wing 2.0 implementation on Tabletop Simulator (TTS).
This is a **brownfield / legacy rescue** project. The Hangar AI Constitution governs all
AI-assisted work here.

## Authority

| Priority | Source |
|---|---|
| 1 | AA Hangar AI Constitution (source laws and skills) |
| 2 | This AGENTS.md (project-specific rules) |
| 3 | Local code conventions in this repository |

**Constitution path in workspace:**
```
../American Airlines/Constituion AI/hangar-ai-constitution
```

---

## ⛔ MANDATORY AGENT PROTOCOL (ENG-4.1 — Manual Verify Variant)

**Every coding task MUST follow this exact 8-step cycle. No exceptions.**

> ⚠️ **TTS Constraint:** AI cannot execute in-sandbox tests. All verification steps
> (3, 5, 7) are completed by the human engineer running the checker object in TTS
> and pasting console output. AI MUST NOT proceed past a verify step without
> human-supplied output.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              MANDATORY AGENT PROTOCOL (ENG-4.1 — NON-NEGOTIABLE)            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Step 1 — IDENTIFY   Find the FIRST unchecked task in tasks.md             │
│                       Read the linked spec scenario ID                      │
│                       ↓                                                     │
│  Step 2 — RED        Write EXACTLY ONE failing test                         │
│                       ⛔ DO NOT write production code yet                   │
│                       ↓                                                     │
│  Step 3 — HUMAN      Drop checker in TTS → paste console output            │
│           VERIFY RED  Output MUST show FAILED for this test                 │
│                       ⛔ Ambiguous output = FAILED until clarified           │
│                       ↓                                                     │
│  Step 4 — GREEN      Write MINIMUM code to pass that ONE test               │
│                       ↓                                                     │
│  Step 5 — HUMAN      Rerun checker → paste console output                  │
│           VERIFY GREEN Output MUST show PASSED                              │
│                       ⛔ AI must not proceed without human confirmation      │
│                       ↓                                                     │
│  Step 6 — REFACTOR   Improve structure only — zero behavior changes         │
│                       ↓                                                     │
│  Step 7 — HUMAN      Rerun checker → full suite must stay green            │
│           VERIFY      ⛔ Any regression = FAILED; fix before advancing      │
│           REFACTOR                                                          │
│                       ↓                                                     │
│  Step 8 — UPDATE     Mark task [x] in tasks.md with timestamp              │
│           & COMMIT    Record evidence in verification-log.md (ENG-6.7)     │
│                       git commit with spec scenario ID in message           │
│                       STOP AND REPORT — wait for human before next cycle   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ⛔ PHASE GATE SUB-PROTOCOL (ENG-12.1)

At every phase gate, BEFORE asking human to approve phase advance:

```
1. CITATION AUDIT     aa-citation-audit <phase-artifact.md>
                      Must exit 0. ≥1 FAIL blocks jury. (ENG-14.1)
                      ↓
2. JURY               PRD-2.6 multi-cognition jury on the phase artifact
                      Minimum 4 jurors on DISTINCT LLM models
                      Round 1: deliberate → corrections
                      Round 2: confirm corrections resolved
                      Judicial synthesizer (separate agent) produces synthesis
                      Synthesis committed to hangar-ai-specs/changes/<id>/
                      ↓
3. JURY GATE          aa-jury-gate <synthesis.md>
                      Must exit 0. exit 1 = FAIL, blocks advance. (ENG-12.1)
                      ↓
4. HUMAN REVIEW       Present synthesis to human for approval
                      Agent CANNOT self-declare phase complete (ENG-12.3)
```

> **Brownfield pragmatics:** For this personal project, a 2-model jury (Domain Sceptic +
> Technical Expert) satisfies the intent of PRD-2.6 at minimum viable scale. Record the
> models used in the synthesis artifact.

---

## ⛔ PROHIBITED ACTIONS

| Prohibited Action | Law Violated |
|---|---|
| Writing more than one test method per cycle | ENG-4.1 |
| Writing production code before a failing test exists | ENG-4.1 |
| Skipping the RED step (no failure proof shown) | ENG-4.1 |
| Skipping the VERIFY steps | ENG-4.1, ENG-4.2 |
| Claiming a test passed without human-supplied TTS output | ENG-1.2 |
| Not updating tasks.md after a cycle completes | ENG-6.7 |
| Committing without a spec scenario ID in the message | ENG-6.7 |
| Using `git add -A` during legacy rescue commits | ENG-4.14 |
| Touching files outside the current task scope | ENG-2.3 |
| Advancing to next cycle without human confirmation | ENG-1.2 |
| Rewriting subsystems without explicit human approval | ENG-1.4 |

---

## Self-Check Before Each Step

1. Have I found the FIRST unchecked task in `tasks.md`?
2. Am I writing exactly ONE test — not a class, not a file, ONE test method?
3. Have I confirmed the test FAILS (human-supplied TTS output) before writing code?
4. Have I confirmed ALL tests PASS after the GREEN step (human-supplied output)?
5. Have I updated `tasks.md`, recorded evidence in `verification-log.md`, and committed with a scenario ID?

---

## Project Context

| Property | Value |
|---|---|
| Runtime | Tabletop Simulator Lua (MoonSharp / Lua 5.2) |
| Test framework | TTS-LuaUnit, triggered by checker object drop |
| Test execution | In-sandbox only — AI cannot run tests directly |
| Mode | Brownfield / legacy rescue |
| Spec folder | `hangar-ai-specs/` (ENG-11.1) |
| Workflow | `legacy-rescue-refactor` |

---

## Brownfield Defaults (ENG-4.14, ENG-1.3)

Per `skill-12-legacy-refactor-rhythm`:

1. **Preserve stack** — No Lua rewrite without explicit human approval.
2. **Characterize first** — Add characterization tests before modifying any legacy behavior.
3. **Vertical slices** — One player-visible behavior per change (ENG-1.4).
4. **Atomic commits** — One test OR one violation per commit. Stage specific files; no `git add -A` (ENG-4.14).
5. **Evidence-backed** — Never claim a test passed without human-provided TTS console output.

### Commit message formats

```bash
# Characterization test
test(char): capture <behavior> in <component>

# Refactor
refactor(<violation-id>): <what-changed>

# Both MUST include spec scenario ID in body
Scenario: <BASE-001 or equivalent>
```

---

## Relevant Skills

| Skill | When to use |
|---|---|
| `skill-06-atomic-tdd` | Writing any new test or production code |
| `skill-12-legacy-refactor-rhythm` | Characterizing or refactoring legacy Lua |
| `skill-09-refactoring` | Extracting modules / reducing complexity |
| `skill-spec-governance` | Scaffolding a new `hangar-ai-specs/changes/` entry |
| `skill-08-code-review` | Reviewing completed slices |

---

## Hangar SDD Structure (ENG-11.1)

```
hangar-ai-specs/
├── README.md             ← active proposal index
├── changes/              ← in-flight work (PROPOSE → IMPLEMENT)
│   └── <verb-noun-id>/
│       ├── PROPOSAL.md   ← problem, solution, deliverables, law citations (ENG-11.2)
│       ├── tasks.md      ← checkbox task list
│       ├── PROGRESS.md   ← phase status and gate log
│       └── verification-log.md  ← TTS evidence per cycle
├── archive/              ← completed changes: mv changes/<id> archive/YYYY-MM-DD-<id>
├── evidence/             ← phase gate artifacts (jury synthesis, citation audit results)
├── specs/                ← current system truth (ENG-11.3)
└── templates/            ← jury synthesis template
```

---

## Non-Negotiable Laws

| Law | Title |
|---|---|
| ENG-4.1 | Atomic TDD Law |
| ENG-6.7 | Audit Trail Law — evidence in verification-log.md |
| ENG-11.1 | Hangar SDD Law — `hangar-ai-specs/` required |
| ENG-12.1 | Agentic Phase Gate Law — human approval required at gates |
| ENG-14.1 | Citation Audit Gate Law — aa-citation-audit before jury |

---

## Quick Reference

```bash
# Start a new change (ENG-11.1)
mkdir -p hangar-ai-specs/changes/<verb-noun-id>
# → skill-spec-governance

# Atomic TDD cycle
# → skill-06-atomic-tdd

# Legacy rescue commit (after GREEN or REFACTOR)
git add <specific-files-only>           # Never git add -A
git diff --cached --stat                # ENG-4.14 checkpoint
git commit -m "test(char): ..."

# Archive completed change
mv hangar-ai-specs/changes/<id> hangar-ai-specs/archive/$(date +%Y-%m-%d)-<id>

# Phase gate tools (ENG-14.1 → ENG-12.1)
aa-citation-audit <phase-artifact.md>
aa-jury-gate <synthesis.md>
```
