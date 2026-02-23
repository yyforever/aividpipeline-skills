---
name: aivp-ideation
description: Video topic ideation through iterative research — AI capability assessment, trend scanning, community research, competitor analysis, and hook generation. Activate on "video ideas", "trending topics", "content ideas", "what should I make a video about", or any ideation request.
---

# AIVP Ideation — Iterative Topic Research & Selection

Discover video topics through multi-round research and discussion. This is NOT a one-shot idea generator — it's an iterative research process that loops until the user is satisfied.

## Core Process

```
User gives direction
     ↓
 Create plan.md (from assets/plan-template.md)
     ↓
 ┌─ Round N ──────────────────────────────┐
 │  ⓪ AI Capability Baseline (Round 1)    │
 │  ① Research (trends/community/compete) │
 │  ② Analyze (filter + score)            │
 │  ③ Synthesize (brief-v{N}.md)          │
 │  ④ Discuss (decision points → user)    │
 │  ⑤ Update plan.md + save notes         │
 └──── not satisfied → Round N+1 ─────────┘
     ↓ satisfied
 Save brief-final.md → done
```

## Workflow

### Round 1: Initial Research

1. **Understand direction** — Ask user: niche, target audience, platform (default: YouTube), constraints
2. **Create `ideation/plan.md`** — Copy `assets/plan-template.md`, fill in direction, update status
3. **Layer 0: AI Capability Baseline** — Read `references/ai-capability-research.md`, follow its guide. Check `references/freshness-rules.md` for data age requirements. Save output to `ideation/notes/ai-capabilities.md`
4. **Layers 1-3: Research** — Read `references/research-queries.md` for search patterns. Save findings to `ideation/notes/round-1.md`
5. **Score candidates** — Read `references/scoring.md`
6. **Generate hooks** — Read `references/hooks.md`
7. **Write brief** — Read `references/brief-template.md`, produce `ideation/brief-v1.md`
8. **Discuss** — Present findings with decision points (see format below)
9. **Update plan.md** — Mark completed steps, record decisions, set next focus

### Round 2+: Iterate

Based on user feedback, run targeted research → update notes → produce brief-v{N} → discuss → update plan.

### Final: Lock

When user approves → save `ideation/brief-final.md` → mark plan complete.

## Decision Point Format (strict)

Every question to the user must follow this format. Never ask naked questions.

```markdown
### Decision: {What needs to be decided}

| Option | Pros | Cons | Data |
|--------|------|------|------|
| A: {option} | {pros} | {cons} | {data with source} |
| B: {option} | {pros} | {cons} | {data with source} |

**Recommendation:** {Option X} — {reason based on data}
```

❌ Bad: "What language should the videos be in?"
✅ Good: Options table with RPM data, audience size, competition level → recommendation with reasoning.

## Project Output Structure

The skill produces three layers of output:

```
project/ideation/
├── plan.md                ← PLAN: created first, updated every round
├── notes/                 ← NOTES: process materials (not deliverables)
│   ├── ai-capabilities.md   ← Layer 0 output (reusable <30 days)
│   ├── round-1.md            ← R1 searches + findings + sources
│   └── round-2.md            ← R2 searches + findings + sources
├── brief-v1.md            ← Working versions
├── brief-v2.md
└── brief-final.md         ← DELIVERABLE: sole output to aivp-script
```

| Layer | File | Purpose | Updated |
|-------|------|---------|---------|
| Plan | `plan.md` | Track progress, decisions, next steps | Every round |
| Notes | `notes/*.md` | Research data + sources for traceability | Every round (append) |
| Deliverable | `brief-final.md` | Approved brief for downstream | Once (final) |

**Rule:** Research data must be saved to `notes/`, not just exist in chat. If you searched it, log it.

## References (load as needed)

- **AI capability research guide** → `references/ai-capability-research.md` — Layer 0 search queries, capability matrix template, zone classification
- **Research query patterns** → `references/research-queries.md` — Layers 1-4 search patterns by source
- **Scoring framework** → `references/scoring.md` — Topic evaluation criteria and weights
- **Hook generation** → `references/hooks.md` — Hook patterns and rules
- **Brief template** → `references/brief-template.md` — Full brief structure
- **Freshness rules** → `references/freshness-rules.md` — Data shelf life by category
- **Analytics feedback** → `references/analytics.md` — Post-publish performance loop

## Scripts

- `scripts/hn-scan.sh` — Fetch Hacker News top stories (tech/AI niches only)
- `scripts/competitor-scan.sh` — Post-process search results for competitor analysis
- `scripts/brief-manage.sh` — Brief version management and status check

## Integration

- **Input from:** User direction, previous `analytics.json`
- **Output to:** `aivp-script` reads:
  - `ideation/brief-final.md` — confirmed direction, format, genre, model, constraints (see `references/brief-template.md` for final format)
  - `ideation/notes/ai-capabilities.md` — detailed AI model capability matrix (shared reference)
- **Feedback from:** `aivp-publish` (video analytics → next ideation round)

### Project Directory Convention

All skills operate under a shared project root:

```
project/
├── ideation/         ← aivp-ideation owns this
│   ├── plan.md
│   ├── notes/
│   └── brief-final.md
├── script/           ← aivp-script owns this
│   ├── plan.md
│   ├── notes/
│   ├── characters/
│   ├── scenes/
│   ├── script-final.md
│   └── prompts-final.md
├── storyboard/       ← aivp-storyboard owns this
├── image/            ← aivp-image (future)
├── video/            ← aivp-video (future)
└── audio/            ← aivp-audio (future)
```

> **Full pipeline**: `ideation → script → storyboard → {image, video, audio} → edit → publish`

Each skill reads from upstream sibling directories and writes only to its own.
