---
name: aivp-script
description: Generate video scripts with dual output — narrative screenplay and AI-ready technical prompts. Optimized for micro-drama and short-form video. Activate on "write a script", "create video script", "script for video", "write dialogue", "write episode", or any scriptwriting request for video production.
---

# AIVP Script — Dual-Layer Video Script Generation

Generate scripts with two synchronized outputs:
- **Narrative layer** — human-readable screenplay (dialogue, emotion, pacing)
- **Technical layer** — per-shot prompts ready for AI video generation (Kling 3.0 / Seedance 2.0 format)

This is an iterative process: script-v1 → discuss → revise → script-final.

## Core Process

```
Read brief-final.md (from aivp-ideation)
     ↓
Create plan.md (from assets/plan-template.md)
     ↓
 ┌─ Round N ────────────────────────────────┐
 │  ① Define/refine characters               │
 │  ② Write narrative script                  │
 │  ③ Generate technical prompts per shot     │
 │  ④ Run quality checks                      │
 │  ⑤ Present to user with revision notes     │
 │  ⑥ Update plan.md                          │
 └──── revisions needed → Round N+1 ──────────┘
     ↓ approved
 Save script-final.md + prompts-final.md + characters/ → done
```

## Workflow

### Setup

1. **Read input** — Load `ideation/brief-final.md` for direction, tone, genre, audience
2. **Create `script/plan.md`** — Copy `assets/plan-template.md`
3. **Read format references** — Load `references/micro-drama-structure.md` for genre-specific rules

### Step 1: Character Definition

Before writing any scenes, define all characters. Read `references/character-sheet.md` for template.

Save each character to `script/characters/{name}.md`:
- Visual appearance (hair, build, clothing style, distinguishing mark)
- Voice profile (tone, accent, speech pattern)
- Core conflict (4 words: "vengeful bride vs cheating fiancé")
- Visual "tell" (ring, scar, twitch — for instant recognition)

Characters are reused by downstream skills (aivp-image, aivp-video) for consistency.

### Step 2: Narrative Script

Write the human-readable screenplay. Read `references/script-template.md` for structure.

Key rules:
- Each scene has: location, time, characters present, dialogue, action, emotional beat
- Dialogue must advance plot OR reveal character (ideally both)
- Mark emotional pacing: 🔴 hook / 🟡 build / 🟢 peak / 🔵 release
- End every episode/segment with a cliffhanger

### Step 3: Technical Prompts

For each scene in the narrative, generate AI video model prompts. Read `references/prompt-formats.md` for model-specific syntax, shot decomposition, and variation types.

Each shot prompt includes:
- **Variation type** — small/medium/large (determines reference frame count)
- **First-frame description** — static snapshot of scene start (no motion verbs)
- **Last-frame description** — static snapshot of scene end (medium/large only)
- **Motion description** — what changes between first and last frame
- Shot type + framing + camera movement (explicit, not vague)
- Emotional state + lighting / atmosphere
- Duration (≤ 15s per shot)
- Audio/dialogue tags (if native audio)
- Character reference tags (use prompt anchor phrase from character sheet)

### Step 4: Quality Checks

Read `references/quality-checks.md` and verify:
- [ ] Hook window (first 15 seconds grabs attention)
- [ ] Emotional pacing (spike every 40-60 seconds)
- [ ] Cliffhanger strength (each segment ends with unresolved tension)
- [ ] Scene count ≤ 5 locations per episode
- [ ] Dialogue compression (no filler lines)
- [ ] Technical prompts match narrative (1:1 scene coverage)
- [ ] Character consistency (descriptions match character sheets)
- [ ] Total duration within target

### Step 5: Present & Iterate

Show user: narrative script + key technical prompts + quality check results.
Collect feedback → revise → next round.

### Final: Lock

When approved → save `script-final.md` + `prompts-final.md` + `characters/*.md` → mark plan complete.

## Project Output Structure

```
project/script/
├── plan.md                    ← PLAN: track progress + decisions
├── notes/                     ← NOTES: revision feedback, research
│   └── round-1.md
├── characters/                ← DELIVERABLE: character definitions
│   ├── character-a.md
│   └── character-b.md
├── script-v1.md               ← Working versions (narrative)
├── prompts-v1.md              ← Working versions (technical)
├── script-final.md            ← DELIVERABLE: approved narrative script
└── prompts-final.md           ← DELIVERABLE: approved technical prompts
```

| Layer | Files | Purpose |
|-------|-------|---------|
| Plan | `plan.md` | Track rounds, decisions, revision notes |
| Notes | `notes/*.md` | User feedback, research for revisions |
| Deliverables | `script-final.md`, `prompts-final.md`, `characters/` | Downstream input |

## References (load as needed)

- **Micro-drama structure** → `references/micro-drama-structure.md` — Hook window, pacing rules, cliffhanger patterns, scene constraints
- **Prompt formats** → `references/prompt-formats.md` — Kling 3.0 and Seedance 2.0 prompt syntax with examples
- **Character sheet template** → `references/character-sheet.md` — Visual/voice/conflict definition
- **Script template** → `references/script-template.md` — Full narrative script structure
- **Quality checks** → `references/quality-checks.md` — Pre-delivery validation checklist

## Integration

- **Input from:** `aivp-ideation` → `ideation/brief-final.md`
- **Output to:**
  - `aivp-storyboard` → `script-final.md` (scene breakdown)
  - `aivp-image` → `characters/*.md` (character reference generation)
  - `aivp-video` → `prompts-final.md` (per-shot generation prompts)
  - `aivp-audio` → `script-final.md` (narration/dialogue text + voice profiles)
