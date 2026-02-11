---
name: aivp-ideation
description: Topic ideation, trend analysis, and post-publish performance analytics for AI video production. Use when the user requests "Video ideas", "Trending topics", "Content ideas", "Analyze performance", or similar ideation and analytics tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: ideation, trending, topics, analytics, content-strategy
---

# AIVP Ideation — Topic Discovery & Performance Analytics

Discover trending topics, generate video ideas, and analyze post-publish performance. This skill closes the content flywheel: published video analytics feed back into the next round of topic selection.

## When to Use

- **Start of pipeline**: User needs video topic ideas
- **End of pipeline**: User wants to analyze published video performance
- **Content planning**: User wants a content calendar

## Topic Discovery

### Sources

| Source | What to Check | How |
|--------|---------------|-----|
| YouTube Trending | What's hot right now | Web search for trending topics in niche |
| Google Trends | Search volume trends | `trends.google.com` via web search |
| Reddit | Community discussions | Search subreddits in niche |
| Twitter/X | Real-time buzz | Search hashtags and trending topics |
| Competitor channels | What's working for others | Analyze top-performing videos |
| Comments | Audience questions | Mine comments for content gaps |

### Idea Generation Template

The agent generates ideas in this format:

```json
{
  "ideas": [
    {
      "title": "5 Morning Habits of Successful People",
      "hook": "90% of CEOs do this before 6 AM",
      "angle": "Science-backed habits with real examples",
      "format": "listicle",
      "estimated_duration": "3:00",
      "target_audience": "Young professionals 22-35",
      "trending_score": 8,
      "competition_score": 6,
      "difficulty_score": 3,
      "priority": "HIGH",
      "keywords": ["morning routine", "productivity", "habits"],
      "reference_videos": [
        { "title": "...", "url": "...", "views": "..." }
      ]
    }
  ]
}
```

### Scoring

| Dimension | Weight | What to Measure |
|-----------|:------:|-----------------|
| Trending | 30% | Search volume trend, social buzz |
| Competition | 25% | Number of similar videos, quality bar |
| Audience fit | 25% | Match to target audience |
| Production difficulty | 20% | How hard to produce with AI tools |

## Performance Analytics

After publishing, analyze how videos perform:

### Metrics to Track

| Metric | Good | Great | Source |
|--------|:----:|:-----:|--------|
| CTR (Click-through rate) | >5% | >10% | YouTube Analytics |
| Avg view duration | >50% | >70% | YouTube Analytics |
| Views (first 48h) | Varies | Top 20% of channel | YouTube Analytics |
| Engagement rate | >5% | >10% | Likes + comments / views |

### Feedback Loop

```json
{
  "video_id": "abc123",
  "published": "2026-02-10",
  "metrics_48h": {
    "views": 1250,
    "ctr": 8.3,
    "avg_view_duration_pct": 62,
    "likes": 89,
    "comments": 12
  },
  "learnings": [
    "Hook worked well (high CTR)",
    "Drop-off at 1:30 — middle section too slow",
    "Top comment: 'Can you do one about evening routines?'"
  ],
  "next_actions": [
    "Create follow-up: evening routines",
    "Keep hooks under 5 seconds",
    "Add more visual variety in middle sections"
  ]
}
```

## Integration with AIVP Pipeline

```
aivp-ideation (topic) → aivp-script → ... → aivp-publish → aivp-ideation (analytics)
      ↑                                                              ↓
      └──────────────── feedback loop ──────────────────────────────┘
```

### Project Directory Convention

```
project/
├── ideation/
│   ├── ideas.json           ← generated ideas
│   └── analytics.json       ← post-publish performance
└── script.json
```

## References

- [references/platforms.md](references/platforms.md) — Platform-specific trend sources
- [references/scoring.md](references/scoring.md) — Detailed scoring methodology
