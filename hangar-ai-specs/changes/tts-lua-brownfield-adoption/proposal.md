# PROPOSAL: TTS Lua Brownfield Adoption Bootstrap

**Changeset ID:** `tts-lua-brownfield-adoption`
**SDD Phase:** IMPLEMENT
**Authority:** ENG-11.1 ⛔ (NON-NEGOTIABLE)
**Status:** IN PROGRESS — Task 3 (GREEN) active
**Workflow:** `legacy-rescue-refactor`

---

## Problem

The TTS X-Wing 2.0 repository has no constitutional governance scaffolding and no
repeatable AI + human pairing workflow. Test execution is locked inside the Tabletop
Simulator sandbox — AI agents cannot run tests directly. Without explicit structure,
each AI session starts blind: no evidence trail, no task continuity, no law citations
to guide decisions.

Additionally, the Bomb subsystem has an active test failure:
`TestBombRangeRuler.test_toggle_twice_does_not_clear_other_buttons` — RED evidence
captured (Cycle 1), GREEN not yet implemented.

## Solution

Bootstrap the Hangar AI Constitution workflow for this project using the
`legacy-rescue-refactor` track's Manual Verify Variant:

1. Establish `hangar-ai-specs/` with proper PROPOSE → IMPLEMENT → ARCHIVE structure.
2. Write `AGENTS.md` with the 8-step manual-verify protocol.
3. Record baseline checker execution as RED evidence.
4. Complete one full RED → GREEN → REFACTOR cycle for the BombRangeRuler behavior.

## Deliverables

| # | Deliverable | Status |
|---|---|---|
| 1 | `AGENTS.md` at repo root with 8-step manual-verify protocol | ✅ Complete |
| 2 | `hangar-ai-specs/` folder with full structure (ENG-11.1) | ✅ Complete |
| 3 | `specs/tts-lua-runtime/spec.md` — baseline runtime scenarios | ✅ Complete |
| 4 | `verification-log.md` with Cycle 1 RED evidence captured | ✅ Complete |
| 5 | GREEN: minimal code to pass `test_toggle_twice_does_not_clear_other_buttons` | ⏳ Active |
| 6 | REFACTOR: verify full suite stays green after structural pass | ⏳ Pending |
| 7 | Archive this change and record next highest-priority behavior | ⏳ Pending |

## Success Criteria

1. All files exist at required paths per ENG-11.1.
2. One complete RED/GREEN/REFACTOR cycle is recorded with human-supplied TTS output.
3. Human and AI can coordinate reliably on checker-triggered test runs.
4. This change is archived at `hangar-ai-specs/archive/YYYY-MM-DD-tts-lua-brownfield-adoption/`.

## Out of Scope

- No gameplay logic rewrite (ENG-1.4).
- No migration away from Lua/TTS runtime.
- No large-scale test framework changes.

## References

- **ENG-4.1** — Atomic TDD Law: one test per cycle, RED before GREEN
- **ENG-4.14** — Legacy Rescue Commit Rhythm: atomic commits, no `git add -A`
- **ENG-6.7** — Audit Trail Law: evidence recorded in `verification-log.md`
- **ENG-11.1** — Hangar SDD Law: `hangar-ai-specs/` required ⛔
- **ENG-11.2** — Proposal Completeness Law: this proposal satisfies required sections
- **ENG-12.1** — Agentic Phase Gate Law: human approval at gates ⛔
- **ENG-1.3** — Continuous Refactoring Law: leave code cleaner than found
- **ENG-1.4** — Incremental Improvement Law: vertical slices only
