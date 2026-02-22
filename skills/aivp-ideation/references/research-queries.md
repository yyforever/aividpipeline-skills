# Research Query Patterns (Layers 1-4)

> All research uses agent-native tools (`web_search`, `web_fetch`).
> Shell scripts are helpers for APIs that work via curl (HN) and data post-processing.
> Do NOT use curl for Reddit or YouTube — they block automated requests.

## Layer 1: Trend Scanning (fast, every round)

**Primary: `web_search`**

| What | Search Query Pattern | Extract |
|------|---------------------|---------|
| YouTube trending | `"{niche}" trending video {current_year} site:youtube.com` | Titles, view counts, patterns |
| Rising topics | `"{niche}" trending topic this week` | What's getting attention now |
| Google Trends proxy | `"{niche}" google trends rising` | Rising search terms via reports |
| Industry news | `"{niche}" news this week {current_year}` | Recent developments, launches |
| Viral content | `"{niche}" viral went viral {current_year}` | What blew up recently |

**Secondary: `scripts/hn-scan.sh`** (for tech/AI/startup niches only)

```bash
bash scripts/hn-scan.sh --niche "AI" --limit 10
```

## Layer 2: Community Research (targeted, when deeper insight needed)

**Method: `web_search` + `web_fetch`**

| Source | How | What to Extract |
|--------|-----|----------------|
| Reddit | `web_search` for `site:reddit.com "{niche}" {question}` | Hot discussions, pain points |
| YouTube comments | `web_search` for top videos → `web_fetch` pages | Audience requests, questions |
| Forums / Q&A | `web_search` for `site:quora.com` or `site:stackexchange.com` | Unanswered questions |

## Layer 3: Competitor Analysis (deep dive, when needed)

**Method: `web_search` + `web_fetch`**

| What | How | Output |
|------|-----|--------|
| Top channels | `web_search` for `best {niche} YouTube channels {current_year}` | Channel names, sizes |
| Recent videos | `web_search` for `site:youtube.com @{channel}` | Title patterns |
| Content gaps | Compare catalog vs community questions | Underserved topics |

**Script helper:** `scripts/competitor-scan.sh` (post-processes search results)

## Layer 4: Platform Policy & Monetization (when relevant)

| What | Search Query Pattern |
|------|---------------------|
| Monetization rules | `{platform} monetization policy AI content {current_year}` |
| Content restrictions | `{platform} demonetization AI generated {current_year}` |
| Algorithm changes | `{platform} algorithm update {current_year}` |
