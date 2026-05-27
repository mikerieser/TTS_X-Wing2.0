# Hangar SDD Project Context - TTS X-Wing 2.0

## Overview

This repository contains scripts and assets for a Star Wars X-Wing 2.0 implementation on Tabletop Simulator.

## Runtime and Tooling

- Scripting language: Lua (Tabletop Simulator sandbox)
- Runtime host: Tabletop Simulator (MoonSharp)
- Local editor: VS Code
- In-sandbox tests: TTS-LuaUnit, triggered by a checker object drop
- Spec folder: `hangar-ai-specs/` (ENG-11.1)

## Brownfield Constraints

1. Existing legacy behavior must be preserved unless explicitly changed by spec (ENG-1.3).
2. Integrated runtime tests cannot be executed by AI directly.
3. Test evidence must be human-supplied from TTS console output.

## Test Strategy

- Unit-like behavior tests run inside TTS sandbox via checker suite.
- Characterization tests are required before modifying legacy paths (ENG-4.14).
- Each change follows atomic TDD with manual verification evidence (ENG-4.1).

## Domain Terms

- Checker: TTS object/action that triggers test suite execution.
- Scenario: Player-visible gameplay rule or interaction.
- Baseline behavior: Current behavior captured before making changes.

## Quality Gates (ENG-4.1, ENG-6.7)

1. One test behavior per cycle.
2. RED and GREEN results recorded from TTS output.
3. Refactor step must rerun suite and remain green.
4. `hangar-ai-specs/` tasks.md updated after each completed cycle.
