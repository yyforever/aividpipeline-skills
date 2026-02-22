---
name: aivp-ideation
description: Video topic ideation through iterative research — AI capability assessment, trend scanning, community research, competitor analysis, and hook generation. Activate on "video ideas", "trending topics", "content ideas", "what should I make a video about", or any ideation request.
metadata:
  author: aividpipeline
  version: "0.5.0"
  tags: ideation, trending, topics, research, content-strategy, hooks
---

# AIVP Ideation — Iterative Topic Research & Selection

Discover video topics through multi-round research and discussion. This is NOT a one-shot idea generator — it's an iterative research process that loops until the user is satisfied.

## Core Process

```
User gives direction (can be vague)
     ↓
 ┌─ Round N ──────────────────────────────┐
 │  ⓪ AI Capability Baseline (Round 1)    │
 │  ① Research (trends/community/compete) │
 │  ② Analyze (filter + score)            │
 │  ③ Synthesize (structured doc)         │
 │  ④ Discuss (present + decision points) │
 └──── not satisfied → Round N+1 ─────────┘
     ↓ satisfied
 Final output: ideation-brief.md
```

Each round means **new research** informed by user feedback, **new data**, and **adjusted direction**.

---

## Information Freshness Rules

Different types of information have different shelf lives. Always check and label:

| Category | Shelf Life | Freshness Requirement | Example |
|----------|-----------|----------------------|---------|
| **AI model capabilities** | 1-3 months | Must use data from **last 30 days** | "Kling 3.0 supports X" |
| **Platform policies** | 3-6 months | Must use data from **last 3 months** | "YouTube YPP requires..." |
| **Market trends / niches** | 6-12 months | Last 6 months acceptable | "Short drama is $8B market" |
| **Human psychology / storytelling** | Years | Evergreen, no freshness concern | "Suspense hooks retain attention" |

**Rules:**
- When searching for AI model capabilities, **always add current year+month** to queries
- When a finding could be outdated, cross-check with a second source dated within 30 days
- In the brief, tag each claim with its source date: `(source, Feb 2026)` or `(source, 2025 — verify freshness)`
- **Never assume AI limitations from >3 months ago still apply** — the field moves too fast

---

## Step-by-Step

### Round 1: Initial Research

1. **Understand direction** — Ask user for:
   - Niche / topic area
   - Target audience
   - Platform (default: YouTube)
   - Any constraints

2. **Run Layer 0: AI Capability Baseline** (see Research Layers)

3. **Run Layers 1-3: Trend / Community / Competitor research**

4. **Produce initial brief** with:
   - AI capability summary (what's possible now, what's limited)
   - Research summary (data, not opinions)
   - 3-5 candidate topics ranked by score
   - Decision points with options (see Decision Point Format below)

5. **Discuss** — Present findings, collect feedback

### Round 2+: Iterate

Based on user feedback, run new targeted research and update the brief.

### Final: Lock Topic

When user approves → save `ideation/brief-final.md` → input for `aivp-script`

---

## Decision Point Format

When the brief requires user input, **never ask naked questions**. Every decision point must follow this format:

```markdown
### Decision: {What needs to be decided}

| Option | Pros | Cons | Data |
|--------|------|------|------|
| A: {option} | {pros} | {cons} | {supporting data with source} |
| B: {option} | {pros} | {cons} | {supporting data with source} |
| C: {option} | {pros} | {cons} | {supporting data with source} |

**Recommendation:** {Option X} — {one-sentence reason based on data}
```

The user can then confirm, override, or ask for more research on a specific option.

**Examples of good vs bad:**

❌ Bad: "What language should the videos be in?"
✅ Good:
> **Decision: Video language**
> | Option | Pros | Cons | Data |
> |--------|------|------|------|
> | English | Largest audience pool, highest RPM ($3-6) | Most competitive | YouTube global reach |
> | Chinese | Less competition in AI video niche | Smaller pool, lower RPM | Growing but fragmented |
> | Multi-language | 2x reach via AI dubbing | Requires multiple channels | Case study: creator doubled views |
>
> **Recommendation:** English — largest pool + highest RPM, with multi-language as Phase 2 expansion.

---

## Research Layers

> **Architecture:** All research uses agent-native tools (`web_search`, `web_fetch`).
> Shell scripts are helpers for APIs that work via curl (Hacker News) and data post-processing.
> Do NOT use curl for Reddit or YouTube — they block automated requests.

### Layer 0: AI Capability Baseline (REQUIRED in Round 1)

**This is the foundation. All topic selection depends on knowing what AI can and cannot produce TODAY.**

Before researching trends or topics, research the current state of AI video generation:

**Search queries (use current month/year):**
- `AI video generation capabilities {current_month} {current_year}`
- `best AI video model comparison {current_year}`
- `{latest_model} review capabilities limitations {current_month} {current_year}`
- `AI video character consistency {current_year}` (verify — do NOT assume this is still a problem)
- `AI video generation audio dialogue {current_year}`
- `AI video length duration limit {current_year}`

**Output a capability matrix:**

| Capability | Status | Best Model(s) | Notes | Source Date |
|------------|--------|--------------|-------|-------------|
| Max resolution | ? | ? | | |
| Max duration per clip | ? | ? | | |
| Character consistency | ? | ? | | |
| Lip sync / dialogue | ? | ? | | |
| Camera motion control | ? | ? | | |
| Multi-scene coherence | ? | ? | | |
| Audio generation | ? | ? | | |
| Emotional expression | ? | ? | | |
| Action / movement | ? | ? | | |
| Text rendering in video | ? | ? | | |
| Style consistency | ? | ? | | |

**Then derive:**
- **"Green zone"** — content types that current AI does WELL (lean into these for topic selection)
- **"Yellow zone"** — possible with effort/workarounds
- **"Red zone"** — still not feasible (avoid these content types)

**This matrix directly constrains topic scoring** — a topic that falls in the Red zone gets Producibility = 1 regardless of demand.

### Layer 1: Trend Scanning (fast, every round)

**Primary method: `web_search`**

| What | Search Query Pattern | Extract |
|------|---------------------|---------|
| YouTube trending | `"{niche}" trending video {current_year} site:youtube.com` | Titles, view counts, patterns |
| Rising topics | `"{niche}" trending topic this week` | What's getting attention now |
| Google Trends proxy | `"{niche}" google trends rising` | Rising search terms via reports |
| Industry news | `"{niche}" news this week {current_year}` | Recent developments, launches |
| Viral content | `"{niche}" viral went viral {current_year}` | What blew up recently |

**Secondary method: `scripts/hn-scan.sh`** (for tech/AI/startup niches only)

```bash
bash scripts/hn-scan.sh --niche "AI" --limit 10
```

### Layer 2: Community Research (targeted, when deeper insight needed)

**Method: `web_search` + `web_fetch`**

| Source | How | What to Extract |
|--------|-----|----------------|
| Reddit | `web_search` for `site:reddit.com "{niche}" {question}` | Hot discussions, pain points |
| YouTube comments | `web_search` for top videos → `web_fetch` pages | Audience requests, questions |
| Forums / Q&A | `web_search` for `site:quora.com` or `site:stackexchange.com` | Unanswered questions |

### Layer 3: Competitor Analysis (deep dive, when needed)

**Method: `web_search` + `web_fetch`**

| What | How | Output |
|------|-----|--------|
| Top channels | `web_search` for `best {niche} YouTube channels {current_year}` | Channel names, sizes |
| Recent videos | `web_search` for `site:youtube.com @{channel}` | Title patterns |
| Content gaps | Compare catalog vs community questions | Underserved topics |

**Script helper:** `scripts/competitor-scan.sh` (post-processes search results)

### Layer 4: Platform Policy & Monetization (when relevant)

Research platform-specific rules that affect topic viability:

| What | Search Query Pattern |
|------|---------------------|
| Monetization rules | `{platform} monetization policy AI content {current_year}` |
| Content restrictions | `{platform} demonetization AI generated {current_year}` |
| Algorithm changes | `{platform} algorithm update {current_year}` |

---

## Topic Selection Framework

Every candidate topic must answer these questions:

| # | Question | Options |
|---|----------|---------|
| 1 | **Search or Viral?** | Searchable / Shareable / Both |
| 2 | **Who watches?** | Specific audience segment |
| 3 | **What's the hook?** | One sentence that stops the scroll |
| 4 | **Data backing?** | Trend data, search volume, community demand |
| 5 | **AI feasibility?** | Green / Yellow / Red (from Layer 0 matrix) |
| 6 | **Shelf life?** | Evergreen / Trending (weeks) / Time-sensitive (days) |

### Scoring

| Dimension | Weight | 1 (Low) | 5 (High) |
|-----------|:------:|---------|----------|
| Demand signal | 25% | No data | Strong trend + community demand |
| Competition gap | 20% | Saturated | Few good videos exist |
| Audience fit | 20% | Tangential | Core audience |
| AI feasibility | 20% | Red zone | Green zone, plays to AI strengths |
| Monetization safety | 15% | High demonetization risk | Clearly policy-compliant |

> **Note:** "AI feasibility" replaces the old "Producibility" dimension and is scored based on the Layer 0 capability matrix, not assumptions.

---

## Hook Generation

For each selected topic, generate 3-5 hook variants. Style: **clear and concise**.

| Type | Pattern | Example |
|------|---------|---------|
| Direct | State the value plainly | "3 AI tools that actually save time" |
| Data | Lead with a number | "87% of startups fail at this one thing" |
| Contrast | Set up a reversal | "Everyone uses ChatGPT wrong. Here's why." |
| Story | Tease a narrative | "I automated my entire workflow. Here's what happened." |
| Question | Ask what they're thinking | "Is your morning routine actually making you less productive?" |

Rules:
- No clickbait that doesn't deliver
- No emoji spam
- Every hook must be defensible by the video content
- Under 15 words preferred

---

## Output Format

### ideation-brief.md structure

```markdown
# Video Ideation Brief — v{N}

## AI Capability Baseline
### Current Capabilities (as of {date})
{capability matrix}
### Green Zone (AI excels)
{content types that work well}
### Yellow Zone (possible with effort)
{content types that need workarounds}
### Red Zone (not yet feasible)
{content types to avoid}

## Research Summary
### Trends
- [data point (source, date)]
### Community Signals
- [what people are asking (source, date)]
### Competitor Landscape
- [what's working, what's missing]
### Platform & Monetization
- [policy constraints, RPM data]

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
- **Shelf life:** Evergreen
- **Score:** {weighted score}/5.0
- **Reference videos:** [{title}]({url})

## Decision Points
### Decision: {topic}
| Option | Pros | Cons | Data |
|--------|------|------|------|
| A | ... | ... | ... |
| B | ... | ... | ... |
**Recommendation:** ...

## Changes from v{N-1}
(What changed and why)
```

---

## Performance Feedback Loop

After a video is published, feed analytics back:

| Signal | Meaning | Action |
|--------|---------|--------|
| High CTR | Hook worked | Use similar hook pattern |
| Low CTR | Hook missed | Try different hook type |
| High retention | Topic + pacing right | Repeat format |
| Drop-off at X:XX | Section too slow | Note for script pacing |
| Comment requests | Audience wants more | Add to topic queue |

Store in `ideation/analytics.json` for reference in future rounds.

---

## Artifacts & Documentation

Every round of research must produce **persistent artifacts**, not just chat output. If the session ends, anyone picking up should be able to reconstruct the full context from files alone.

### Required artifacts (save after each round)

| Artifact | Path | Format | When |
|----------|------|--------|------|
| AI capability baseline | `ideation/research/ai-capabilities.md` | Capability matrix + Green/Yellow/Red zones | Round 1, update if models change |
| Research raw data | `ideation/research/round-{N}.md` | Searches performed, key findings with source+date, quotes | Every round |
| Decision log | `ideation/decision-log.md` | Each decision: options presented → user choice → reasoning | Append after each user confirmation |
| Brief versions | `ideation/brief-v{N}.md` | Full brief per SKILL format | Every round |
| Final brief | `ideation/brief-final.md` | Locked version | After user final approval |

### AI Capability Baseline persistence
The Layer 0 output (`ai-capabilities.md`) is reusable across ideation sessions. **Check its date before re-researching** — if < 30 days old, reuse; if > 30 days, refresh.

### Decision Log format
```markdown
# Ideation Decision Log

## Round 1 — {date}
### Direction
- User input: {what they said}

### Decision: {topic}
- Options presented: A / B / C
- User chose: {X}
- Reasoning: {why}

## Round 2 — {date}
### Decision: {topic}
...
```

### Research data format (`round-{N}.md`)
```markdown
# Research Round {N} — {date}

## Searches Performed
1. `{query}` → {N results}, top findings: ...
2. `{query}` → ...

## Key Findings
- {finding} (source, date)
- {finding} (source, date)

## Sources Consulted
- [{title}]({url}) — {date} — {what was extracted}
```

**Rule: No research should exist only in chat.** If you searched it, log it. If you cited it, save the source.

## Project Directory

```
project/
├── ideation/
│   ├── brief-v1.md              ← Round 1 output
│   ├── brief-v2.md              ← Round 2 output
│   ├── brief-final.md           ← Approved final brief
│   ├── decision-log.md          ← All decisions with context
│   ├── research/
│   │   ├── ai-capabilities.md   ← Layer 0 (reusable <30 days)
│   │   ├── round-1.md           ← Round 1 searches & findings
│   │   ├── round-2.md           ← Round 2 searches & findings
│   │   └── ...
│   └── analytics.json           ← Post-publish performance data
└── ...
```

## Integration

- **Input from:** User direction, previous analytics data
- **Output to:** `aivp-script` (approved brief → script writing)
- **Feedback from:** `aivp-publish` (published video analytics → next ideation round)
