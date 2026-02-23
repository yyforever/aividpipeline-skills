---
name: aivp-storyboard
description: Convert scripts into production-ready storyboards with camera tree, frame generation plan, and visual continuity. Activate on "create storyboard", "shot breakdown", "visual plan", "scene breakdown", "storyboard from script", or any visual planning request after script is written.
metadata:
  author: aividpipeline
  version: "0.5.0"
  tags: storyboard, camera-tree, shot-decomposition, frame-plan, visual-continuity
---

# AIVP Storyboard — Camera-Aware Visual Production Planning

Transform scripts into production-ready storyboards. The core innovations beyond simple shot lists:

1. **Camera Tree** — spatial hierarchy of camera positions for visual consistency (from ViMax)
2. **3-tuple shot decomposition** — first-frame + last-frame + motion per shot (from ViMax/STAGE)
3. **Frame generation plan** — ordered instructions for aivp-image with reference image selection
4. **Visual continuity validation** — cross-shot character/environment consistency checks

This is an iterative process: storyboard-v1 → discuss → revise → storyboard-final.

## Core Process

```
Read script outputs (script-final + prompts-final + characters/ + scenes/)
     ↓
Create plan.md (from assets/plan-template.md)
     ↓
 ┌─ Round N ──────────────────────────────────┐
 │  ① Audit & refine shot decompositions       │
 │  ② Build camera tree                        │
 │  ③ Plan frame generation order + references │
 │  ④ Write production specs per shot          │
 │  ⑤ Run quality checks                       │
 │  ⑥ Present to user with revision notes      │
 │  ⑦ Update plan.md                           │
 └──── revisions needed → Round N+1 ───────────┘
     ↓ approved
 Save storyboard-final/ → done
```

## Workflow

### Setup

1. **Read script outputs** — Load from sibling `script/` directory:
   - `script/script-final.md` — narrative screenplay
   - `script/prompts-final.md` — per-shot technical prompts with structured metadata
   - `script/characters/*.md` — character sheets (static/dynamic features, prompt anchors)
   - `script/scenes/*.md` — scene sheets (background prompts, lighting)
2. **Read AI capabilities** — Load `ideation/notes/ai-capabilities.md` for model limits
3. **Create `storyboard/plan.md`** — Copy `assets/plan-template.md`

### Step 1: Audit & Refine Shot Decompositions

Read `references/shot-decomposition.md` for rules.

For each shot in `prompts-final.md`, validate and refine:

- **First-frame description** — Must be a pure static snapshot (no motion verbs)
- **Last-frame description** — Must reflect final state after all motion (medium/large variation only)
- **Motion description** — Must use visual appearance, never character names
- **Variation type** — Classify as small/medium/large per `references/variation-system.md`
- **Audio layer** — dialogue + bgm + sfx all present

Save refined decompositions to `storyboard/shots/shot-{NN}.md` using format from `references/shot-spec-format.md`.

### Step 2: Build Camera Tree

Read `references/camera-tree-guide.md`.

The Camera Tree is a spatial hierarchy of camera positions. Key concepts:

- **Camera position** = a unique combination of location + framing + angle
- **Parent-child** = parent camera's frame spatially contains child camera's content
- **Reuse cameras** — only introduce new position when framing differs significantly

Process:
1. Group shots by scene location
2. Within each scene, identify distinct camera positions
3. Assign `cam_idx` to each shot
4. Build parent-child relationships (wider shot → tighter shot)
5. Mark `is_parent_fully_covers_child` and `missing_info` per relationship

Save to `storyboard/camera-tree.md`.

### Step 3: Frame Generation Plan

Read `references/frame-planning.md`.

Plan the order and method for generating each frame image:

1. **Generation order** follows Camera Tree (parent cameras first, then children)
2. **Reference image selection** per frame:
   - Character portraits (front/side/back based on facing direction)
   - Scene background (from scene sheets)
   - Prior frames from same camera position (temporal consistency)
   - Parent camera frames (spatial consistency via transition)
3. **Variation-based strategy**:
   - `small` → generate first-frame only (video model interpolates)
   - `medium/large` → generate first-frame + last-frame

Save to `storyboard/frame-plan.md`.

### Step 4: Production Specs

Read `references/production-specs.md`.

Generate two output formats per shot:

**For aivp-image** (keyframe generation):
- Frame description (ff_desc / lf_desc) — self-contained, no cross-references
- Reference image list with roles (character portrait, scene bg, prior frame)
- Target resolution and aspect ratio

**For aivp-video** (clip generation):
- Motion prompt (model-specific: Kling 3.0 / Seedance 2.0 format)
- Input frames (first-frame only for small; first + last for medium/large)
- Duration, camera movement keywords
- Audio cues (dialogue timing, bgm, sfx)

Save combined specs to `storyboard/storyboard-v{N}.md`.

### Step 5: Quality Checks

Read `references/quality-checks.md` and verify. Save results to `storyboard/notes/round-{N}.md`.

### Step 6: Present & Iterate

Show user: visual summary (shot count, camera positions, duration) + key shots + quality results.
Collect feedback → revise → next round.

### Final: Lock

When approved → save all to `storyboard/storyboard-final/` directory:
- `storyboard-final/storyboard.md` — complete storyboard document
- `storyboard-final/camera-tree.md` — finalized camera tree
- `storyboard-final/frame-plan.md` — finalized generation plan
- `storyboard-final/shots/shot-{NN}.md` — per-shot production specs

Mark plan complete.

## Project Output Structure

```
project/storyboard/
├── plan.md                          ← PLAN: track progress + decisions
├── notes/                           ← NOTES: revision feedback
│   └── round-1.md
├── camera-tree.md                   ← Working camera tree
├── frame-plan.md                    ← Working frame generation plan
├── shots/                           ← Per-shot specs (working)
│   ├── shot-01.md
│   └── shot-02.md
├── storyboard-v1.md                 ← Working version
└── storyboard-final/                ← DELIVERABLE: approved output
    ├── storyboard.md
    ├── camera-tree.md
    ├── frame-plan.md
    └── shots/
        ├── shot-01.md
        └── shot-02.md
```

| Layer | Files | Purpose |
|-------|-------|---------|
| Plan | `plan.md` | Track rounds, decisions, revision notes |
| Notes | `notes/*.md` | Quality check results, user feedback |
| Deliverables | `storyboard-final/` | Complete production specs for downstream |

## References (load as needed)

- **Camera tree guide** → `references/camera-tree-guide.md` — Spatial hierarchy construction, parent-child relationships, transition generation
- **Shot decomposition** → `references/shot-decomposition.md` — 3-tuple rules (ff/lf/motion), static snapshot requirements, motion description conventions
- **Variation system** → `references/variation-system.md` — small/medium/large classification, generation strategy per type
- **Frame planning** → `references/frame-planning.md` — Generation order, reference image selection, character portrait angle matching
- **Production specs** → `references/production-specs.md` — Output formats for aivp-image and aivp-video, model-specific prompt syntax
- **Visual continuity** → `references/visual-continuity.md` — Cross-shot consistency checks, character tracking, environment consistency
- **Quality checks** → `references/quality-checks.md` — Storyboard-specific validation checklist

## Integration

- **Input from:** `aivp-script` →
  - `script/script-final.md` — narrative screenplay
  - `script/prompts-final.md` — per-shot technical prompts with structured metadata
  - `script/characters/*.md` — character sheets (static/dynamic features, multi-angle portrait guide)
  - `script/scenes/*.md` — scene sheets (background prompts, lighting)
  - `ideation/notes/ai-capabilities.md` — AI model capability matrix (shared reference)
- **Output to:**
  - `aivp-image` → `storyboard-final/frame-plan.md` + `storyboard-final/shots/*.md` (what to generate, in what order, with what references)
  - `aivp-video` → `storyboard-final/shots/*.md` (motion prompts, input frames, duration, audio cues)
  - `aivp-audio` → `storyboard-final/storyboard.md` (dialogue timing, BGM transitions, SFX placement)

### Project Directory Convention

```
project/
├── ideation/          ← aivp-ideation owns
├── script/            ← aivp-script owns
├── storyboard/        ← aivp-storyboard owns (this skill)
├── image/             ← aivp-image (future)
├── video/             ← aivp-video (future)
└── audio/             ← aivp-audio (future)
```

Each skill reads from upstream sibling directories and writes only to its own.
