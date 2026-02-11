---
name: seedance-ideation
description: >
  Topic ideation and performance analytics for AI video production.
  Use when user requests "find video topics", "trending topics", "competitor analysis",
  "content ideas", "analyze video performance", "what should I make next",
  or needs to research trends, score topic ideas, track post-publish metrics,
  or feed analytics back into topic prioritization. Covers the full content flywheel:
  discover → score → produce → measure → learn → discover.
---

# Seedance Ideation

Topic research, scoring, and post-publish analytics for AI video production.

<!-- TODO: Implement all sections below -->

## References

- [Platform APIs](references/platforms.md) — YouTube/TikTok/Xiaohongshu trend and analytics APIs
- [Scoring Framework](references/scoring.md) — Topic evaluation criteria and weighting

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/trending.sh` | Fetch trending topics from YouTube/TikTok |
| `scripts/competitor.sh` | Analyze competitor channels and top-performing content |
| `scripts/score.sh` | Score and rank topic ideas |
| `scripts/analytics.sh` | Pull post-publish performance data and update topic scores |

## Workflow

### Topic Discovery

<!-- TODO: Implement trending topic fetching -->
<!-- TODO: Implement competitor channel analysis -->
<!-- TODO: Define scoring dimensions (search volume, competition, relevance, trend velocity) -->

1. Fetch trending topics from target platforms
2. Analyze competitor channels for content gaps
3. Score each topic against evaluation framework
4. Output ranked topic list with scores and rationale

### Performance Feedback Loop

<!-- TODO: Implement analytics data pulling -->
<!-- TODO: Implement feedback scoring update logic -->

1. Pull performance metrics for published videos (CTR, retention, engagement)
2. Map performance signals to topic/format attributes
3. Update scoring weights based on actual results
4. Feed insights back into next topic discovery cycle

## Output Format

<!-- TODO: Define JSON schema for topic list output -->

```json
{
  "topics": [
    {
      "title": "...",
      "score": 0.0,
      "dimensions": {},
      "sources": [],
      "rationale": "..."
    }
  ]
}
```
