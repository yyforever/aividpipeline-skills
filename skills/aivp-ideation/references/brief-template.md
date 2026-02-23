# Brief Template

Use this structure for every `brief-v{N}.md`.

```markdown
# Video Ideation Brief — v{N}

## Changes from v{N-1}
(What changed and why, skip for v1)

## AI Capability Baseline (as of {date})
### Green Zone (AI excels)
{content types that work well}
### Yellow Zone (possible with effort)
{content types that need workarounds}
### Red Zone (not yet feasible)
{content types to avoid}

### Recommended Model Stack
- **Primary video model:** {model name + version}
- **Backup video model:** {model name + version}
- **Key capabilities:** {what the primary model does well}
- **Key limitations:** {what to avoid}
- **Detail source:** `notes/ai-capabilities.md`

## Research Summary
### Trends
- {data point} (source, date)
### Community Signals
- {what people are asking} (source, date)
### Competitor Landscape
- {what's working, what's missing}
### Platform & Monetization
- {policy constraints, RPM data}

## Candidate Topics (ranked)

### 1. {Title}
- **Type:** Searchable / Shareable
- **AI Feasibility:** Green / Yellow — {why, referencing capability matrix}
- **Hook variants:**
  1. "{hook 1}"
  2. "{hook 2}"
  3. "{hook 3}"
- **Target audience:** {who}
- **Data backing:** {evidence (source, date)}
- **Shelf life:** Evergreen / Trending
- **Score:** {weighted}/5.0

## Decision Points

### Decision: {What needs to be decided}
| Option | Pros | Cons | Data |
|--------|------|------|------|
| A: {option} | {pros} | {cons} | {data with source} |
| B: {option} | {pros} | {cons} | {data with source} |
**Recommendation:** {Option X} — {reason based on data}
```

---

## Brief-Final Format

When user approves the last version, save as `brief-final.md` using this **confirmed** format (not the ranked-candidates format above):

```markdown
# Brief Final — Locked

## Core Concept
- **Title:** {confirmed title}
- **Logline:** {one-sentence story/concept summary}

## Format
- **Platform:** {YouTube / TikTok / etc}
- **Duration:** {e.g., 8-12 minutes per episode + 60s Shorts}
- **Episodes:** {Pilot / Series of N}
- **Language:** {English / Chinese / etc}

## Genre & Tone
- **Primary:** {genre}
- **Sub-genre:** {if any}
- **Tone:** {3-4 adjectives}
- **Reference vibes:** {e.g., "Black Mirror meets The Social Dilemma"}

## Target Audience
- {age range, interests, platform behavior}

## Production Approach
- **Primary video model:** {from AI Capability Baseline}
- **Backup video model:** {from AI Capability Baseline}
- **Workflow:** {Full AI / Hybrid}
- **Budget:** {per episode estimate}
- **Production time:** {per episode estimate}
- **AI capability detail:** see `notes/ai-capabilities.md`

## Hook Strategy
- {opening hook description}
- {title/thumbnail angle}
- {Shorts teaser moment}

## Key Constraints
- Max {N} locations per episode
- Max {N} main characters
- {other constraints from AI capabilities / budget}

## Confirmed Technical Settings
- {model-specific settings — max duration, multi-shot support, etc.}
- {character consistency approach}
- {pacing rules}
```

**This is the sole deliverable passed to `aivp-script`.** The script skill reads this file to extract direction, tone, genre, audience, model choice, and production constraints.

**Important:** `notes/ai-capabilities.md` is a shared reference — both ideation and script may read it for detailed model capabilities beyond what brief-final summarizes.
