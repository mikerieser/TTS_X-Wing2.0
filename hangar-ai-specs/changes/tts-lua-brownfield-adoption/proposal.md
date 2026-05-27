# Proposal: TTS Lua Brownfield Adoption Bootstrap

## Problem

Current workflow lacks standardized constitutional artifacts and repeatable evidence capture for atomic TDD cycles. The Hangar SDD spec folder (`hangar-ai-specs/`) and verification log did not exist.

## Solution

Adopt the Hangar AI Constitution workflow in a Lua/TTS brownfield repository where test execution is available only inside the TTS sandbox, using manual verification evidence supplied by the human engineer.

## Deliverables

1. Root `AGENTS.md` for project governance.
2. `hangar-ai-specs/` folder with project context and baseline runtime spec (ENG-11.1).
3. Initial task list and verification log template.

## Non-Goals

1. No gameplay logic rewrite.
2. No migration away from Lua/TTS runtime.
3. No large-scale test framework replacement.

## Brownfield Safeguards

1. Preserve-stack default — no rewrite (ENG-1.3).
2. Characterize first, then modify (ENG-4.14).
3. One test behavior per cycle (ENG-4.1).

## Success Criteria

1. Governance artifacts exist at required paths (`hangar-ai-specs/`, `AGENTS.md`).
2. At least one complete RED/GREEN/REFACTOR manual-evidence cycle is recorded.
3. Human and AI can coordinate reliably on checker-triggered test runs.

## References

- ENG-4.1: Atomic TDD Law — one test per cycle, RED before GREEN
- ENG-4.14: Legacy Rescue Commit Rhythm Law — atomic commits during brownfield rescue
- ENG-6.7: Audit Trail Law — evidence recorded in verification-log.md
- ENG-11.1: Hangar SDD Law — `hangar-ai-specs/` folder required
- ENG-11.2: Proposal Completeness Law — this proposal satisfies required sections
- ENG-1.3: Continuous Refactoring Law — leave code cleaner than found
