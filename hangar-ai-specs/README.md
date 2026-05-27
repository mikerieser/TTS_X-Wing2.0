# Hangar SDD — TTS X-Wing 2.0

Spec-Driven Development proposals for TTS X-Wing 2.0.
Governed by **ENG-11.1** (NON-NEGOTIABLE). Lifecycle: `PROPOSE → IMPLEMENT → ARCHIVE`.

See `agent-skills/skills-by-domain/discovery-research/spec-governance.md`
(`skill-spec-governance`) for full lifecycle guidance.

---

## Active Proposals

| Proposal | Phase | Status |
|---|---|---|
| [tts-lua-brownfield-adoption](changes/tts-lua-brownfield-adoption/) | IMPLEMENT | 🔵 IN PROGRESS — Task 3 (GREEN) active |

---

## Archived Proposals

| Proposal | Archived |
|---|---|
| *(none yet)* | — |

---

## Creating a New Proposal

```bash
mkdir -p hangar-ai-specs/changes/<verb-noun-id>
# Create PROPOSAL.md — must cite ≥1 law (ENG-11.2)
# Create tasks.md — checkbox list
# Create PROGRESS.md — phase status and gate log
```

## Archiving a Completed Proposal

```bash
mv hangar-ai-specs/changes/<id> hangar-ai-specs/archive/$(date +%Y-%m-%d)-<id>
# Update this README to move row to Archived Proposals
```
