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
 │  ① Define/refine characters & scenes      │
 │  ② Write narrative script                  │
 │  ③ Generate technical prompts per shot     │
 │  ④ Run quality checks                      │
 │  ⑤ Present to user with revision notes     │
 │  ⑥ Update plan.md                          │
 └──── revisions needed → Round N+1 ──────────┘
     ↓ approved
 Save script-final + prompts-final + characters/ + scenes/ → done
```

## Workflow

### Setup

1. **Read input** — Load `ideation/brief-final.md` for direction, tone, genre, audience, model choice, constraints
2. **Read AI capabilities** — Load `ideation/notes/ai-capabilities.md` for detailed model limits (max duration, character consistency, etc.)
3. **Create `script/plan.md`** — Copy `assets/plan-template.md`
4. **Read format references** — Load `references/micro-drama-structure.md` for genre-specific rules

### Step 1: Characters & Scenes

Define all characters and scene locations before writing. Read `references/character-sheet.md` and `references/scene-sheet.md`.

**Characters** → save to `script/characters/{name}.md`:
- Static features (face, build, hair — immutable) vs dynamic features (outfit, accessories — per-scene)
- Voice profile, core conflict (4 words), visual tell
- Multi-angle portrait guide (front/side/back generation order for aivp-image)
- Prompt anchor phrase (static features only)

**Scenes** → save to `script/scenes/{location-slug}.md`:
- Environment, lighting, atmosphere, color palette
- Scene background prompt (no people — character-free for compositing)

Characters and scenes are reused by downstream skills (aivp-image, aivp-video, aivp-audio).

### Step 2: Narrative Script

Write the human-readable screenplay. Read `references/script-template.md` for structure.

Key rules:
- Each scene has: location, time, characters present, dialogue, action, emotional beat
- Dialogue must advance plot OR reveal character (ideally both)
- Mark emotional pacing: 🔴 hook / 🟡 build / 🟢 peak / 🔵 release
- End every episode/segment with a cliffhanger

### Step 3: Technical Prompts

For each scene, generate AI video model prompts. Read `references/prompt-formats.md` for syntax and `references/storyboard-guidelines.md` for the 10 composition rules.

Each shot has **structured metadata** (not buried in prose):
- `variation` (small/medium/large), `shot_type`, `angle`, `movement`, `duration`, `emotion`
- `characters` with facing direction — tracked per first-frame and last-frame
- `scene_ref` linking to scene sheet
- Frame decomposition: first-frame (static) + last-frame (static, medium/large only) + motion
- **Motion text uses visual descriptions, not character names** (video models don't know names)

Each shot has **three-layer audio**:
- `dialogue`: `[Name, tone]: "text"` or `(none)`
- `bgm`: music cue or `(continue)`
- `sfx`: concrete sound effects or `(none)`

### Step 4: Quality Checks

Read `references/quality-checks.md` and verify. Save results to `script/notes/round-{N}.md`.
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

When approved → save `script-final.md` + `prompts-final.md` + `characters/*.md` + `scenes/*.md` → mark plan complete.

## Project Output Structure

```
project/script/
├── plan.md                    ← PLAN: track progress + decisions
├── notes/                     ← NOTES: revision feedback, research
│   └── round-1.md
├── characters/                ← DELIVERABLE: character definitions
│   ├── character-a.md
│   └── character-b.md
├── scenes/                    ← DELIVERABLE: scene/location definitions
│   ├── location-a.md
│   └── location-b.md
├── script-v1.md               ← Working versions (narrative)
├── prompts-v1.md              ← Working versions (technical)
├── script-final.md            ← DELIVERABLE: approved narrative script
└── prompts-final.md           ← DELIVERABLE: approved technical prompts
```

| Layer | Files | Purpose |
|-------|-------|---------|
| Plan | `plan.md` | Track rounds, decisions, revision notes |
| Notes | `notes/*.md` | User feedback, research for revisions |
| Deliverables | `script-final.md`, `prompts-final.md`, `characters/`, `scenes/` | Downstream input |

## References (load as needed)

- **Micro-drama structure** → `references/micro-drama-structure.md` — Hook window, pacing rules, cliffhanger patterns
- **Prompt formats** → `references/prompt-formats.md` — Model syntax, structured metadata, shot decomposition, audio layers
- **Storyboard guidelines** → `references/storyboard-guidelines.md` — 10 composition rules, shot type selection, angle psychology
- **Character sheet** → `references/character-sheet.md` — Static/dynamic features, multi-angle portraits, prompt anchor
- **Scene sheet** → `references/scene-sheet.md` — Location definition, background prompts, lighting
- **Script template** → `references/script-template.md` — Full narrative script structure with annotations
- **Quality checks** → `references/quality-checks.md` — 30+ validation items across 6 categories

## Integration

- **Input from:** `aivp-ideation` →
  - `ideation/brief-final.md` — confirmed direction, format, genre, model, constraints
  - `ideation/notes/ai-capabilities.md` — detailed AI model capability matrix (shared reference)
- **Output to:**
  - `aivp-storyboard` → `script-final.md` + `scenes/*.md` (scene breakdown + location visuals)
  - `aivp-image` → `characters/*.md` + `scenes/*.md` (character portraits + scene backgrounds)
  - `aivp-video` → `prompts-final.md` (per-shot generation prompts with structured metadata)
  - `aivp-audio` → `script-final.md` (dialogue + BGM cues + SFX descriptions + voice profiles)
