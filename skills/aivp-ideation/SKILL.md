---
name: aivp-ideation
description: Video topic ideation through iterative research — trend scanning, community research, competitor analysis, and hook generation. Activate on "video ideas", "trending topics", "content ideas", "what should I make a video about", or any ideation request.
metadata:
  author: aividpipeline
  version: "0.3.0"
  tags: ideation, trending, topics, research, content-strategy, hooks
---

# AIVP Ideation — Iterative Topic Research & Selection

Discover video topics through multi-round research and discussion. This is NOT a one-shot idea generator — it's an iterative research process that loops until the user is satisfied.

## Core Process

```
User gives direction (can be vague)
     ↓
 ┌─ Round N ──────────────────────┐
 │  ① Research (trends/community) │
 │  ② Analyze (filter + score)    │
 │  ③ Synthesize (structured doc) │
 │  ④ Discuss (present → feedback)│
 └──── not satisfied → Round N+1 ─┘
     ↓ satisfied
 Final output: ideation-brief.md
```

Each round means **new research** informed by user feedback, **new data**, and **adjusted direction**.

## Step-by-Step

### Round 1: Initial Research

1. **Understand direction** — Ask user for:
   - Niche / topic area (e.g., "AI tools", "cooking", "fitness")
   - Target audience (who watches)
   - Platform (YouTube, TikTok, etc. — default: YouTube)
   - Any constraints (length, style, existing channel context)

2. **Run research** — Execute the research layers below

3. **Produce initial brief** — Write `ideation/brief-v1.md` with:
   - Research summary (data, not opinions)
   - 3-5 candidate topics ranked by priority
   - Hook variants for top picks
   - Open questions for user

4. **Discuss** — Present findings, ask for feedback

### Round 2+: Iterate

Based on user feedback:
- **"Go deeper on topic X"** → More targeted research on that topic
- **"Wrong direction"** → Pivot research to new area
- **"Too broad"** → Narrow down with specific sub-topics
- **"Add more options"** → Expand search to adjacent areas
- **"I like #2 but change the angle"** → Rework that specific topic

Each round updates the brief: `ideation/brief-v{N}.md`

### Final: Lock Topic

When user approves:
- Save final brief as `ideation/brief-final.md`
- This becomes input for `aivp-script`

---

## Research Layers

> **Architecture note:** All research uses agent-native tools (`web_search`, `web_fetch`).
> Shell scripts are helpers for APIs that work via curl (Hacker News) and data post-processing.
> Do NOT use curl for Reddit or YouTube — they block automated requests.

### Layer 1: Trend Scanning (fast, every round)

**Primary method: `web_search`**

Run these searches (adapt query to niche):

| What | Search Query Pattern | Extract |
|------|---------------------|---------|
| YouTube trending | `"{niche}" trending video 2026 site:youtube.com` | Titles, view counts, patterns |
| Rising topics | `"{niche}" trending topic this week` | What's getting attention now |
| Google Trends proxy | `"{niche}" google trends rising` | Rising search terms via reports |
| Industry news | `"{niche}" news this week 2026` | Recent developments, launches |
| Viral content | `"{niche}" viral went viral 2026` | What blew up recently |

**Secondary method: `scripts/hn-scan.sh`** (for tech/AI/startup niches only)

```bash
# Fetch Hacker News top stories filtered by niche keyword
bash scripts/hn-scan.sh --niche "AI" --limit 10
bash scripts/hn-scan.sh --niche "AI" --limit 10 --output /tmp/hn-trends.json
```

### Layer 2: Community Research (targeted, when deeper insight needed)

**Method: `web_search` + `web_fetch`**

| Source | How | What to Extract |
|--------|-----|----------------|
| Reddit | `web_search` for `site:reddit.com "{niche}" {question}` | Hot discussions, pain points, requests |
| YouTube comments | `web_search` for top videos → `web_fetch` video pages | "Can you make a video about...", common questions |
| Forums / Q&A | `web_search` for `site:quora.com "{niche}"` or `site:stackexchange.com` | Unanswered questions, confusion points |
| Product Hunt | `web_search` for `site:producthunt.com "{niche}" 2026` | New products, tools people are excited about |

**Digging into Reddit threads:**
```
1. web_search: "site:reddit.com r/artificial AI video tools"
2. Pick top 2-3 relevant results
3. web_fetch each URL → extract post title, top comments, sentiment
```

**Digging into YouTube:**
```
1. web_search: "{niche} tutorial 2026 site:youtube.com"
2. Note title patterns, view counts from search snippets
3. Optional: web_fetch a video page for description/comment themes
```

### Layer 3: Competitor Analysis (deep dive, when needed)

**Method: `web_search` + `web_fetch`**

| What | How | Output |
|------|-----|--------|
| Top channels | `web_search` for `best {niche} YouTube channels 2026` | Channel names, subscriber counts |
| Recent videos | `web_search` for `site:youtube.com @{channel}` | Recent uploads, title patterns |
| Performance | `web_search` for channel name + "most popular" | What topics get the most traction |
| Content gaps | Compare their catalog vs community questions | Topics nobody covers well |

**Script helper:** `scripts/competitor-scan.sh` (post-processes search results into structured format)

```bash
# After gathering competitor data via web_search, format it:
bash scripts/competitor-scan.sh --channel "@mkbhd" --data /tmp/competitor-raw.json
```

---

## Topic Selection Framework

Every candidate topic must answer these 6 questions:

| # | Question | Options |
|---|----------|---------|
| 1 | **Search or Viral?** | Searchable (SEO, evergreen) / Shareable (viral, trending) / Both |
| 2 | **Who watches?** | Specific audience segment |
| 3 | **What's the hook?** | One sentence that stops the scroll |
| 4 | **Data backing?** | Trend data, search volume, community demand |
| 5 | **Difficulty (1-5)?** | How hard to produce with AI tools |
| 6 | **Shelf life?** | Evergreen / Trending (weeks) / Time-sensitive (days) |

### Scoring

| Dimension | Weight | 1 (Low) | 5 (High) |
|-----------|:------:|---------|----------|
| Demand signal | 30% | No data | Strong trend + community demand |
| Competition gap | 25% | Saturated | Few good videos exist |
| Audience fit | 25% | Tangential | Core audience |
| Producibility | 20% | Needs live footage | Pure AI-producible |

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

## Research Summary
### Trends
- [data point with source and URL]
### Community Signals
- [what people are asking/discussing, with links]
### Competitor Landscape
- [what's working, what's missing]

## Candidate Topics (ranked)

### 1. {Title}
- **Type:** Searchable / Shareable
- **Hook variants:**
  1. "{hook 1}"
  2. "{hook 2}"
  3. "{hook 3}"
- **Target audience:** {who}
- **Data backing:** {evidence with links}
- **Difficulty:** ⭐⭐⭐ (3/5)
- **Shelf life:** Evergreen
- **Score:** {weighted score}/5.0
- **Reference videos:** [{title}]({url}) — {views}

### 2. {Title}
...

## Changes from v{N-1}
(What changed and why, based on user feedback)

## Open Questions
(Decisions the user needs to make)
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

## Project Directory

```
project/
├── ideation/
│   ├── brief-v1.md
│   ├── brief-v2.md
│   ├── brief-final.md       ← Approved final brief
│   ├── research/
│   │   ├── trends.json
│   │   ├── community.json
│   │   └── competitors.json
│   └── analytics.json       ← Post-publish performance
└── ...
```

## Integration

- **Input from:** User direction, previous analytics data
- **Output to:** `aivp-script` (approved brief → script writing)
- **Feedback from:** `aivp-publish` (published video analytics → next ideation round)
