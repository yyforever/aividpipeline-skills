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

## Brief-Final

When user approves the last version, save as `brief-final.md`. This is the sole deliverable passed to `aivp-script`.
