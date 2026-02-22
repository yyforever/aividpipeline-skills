# Performance Feedback Loop

After a video is published, feed analytics back into future ideation rounds.

## Signals

| Signal | Meaning | Action |
|--------|---------|--------|
| High CTR | Hook worked | Use similar hook pattern |
| Low CTR | Hook missed | Try different hook type |
| High retention | Topic + pacing right | Repeat format |
| Drop-off at X:XX | Section too slow | Note for script pacing |
| Comment requests | Audience wants more | Add to topic queue |

## Storage

Save analytics to `ideation/analytics.json` for reference in future rounds.

```json
{
  "videos": [
    {
      "title": "...",
      "published": "2026-01-15",
      "ctr": 8.2,
      "avg_retention": 0.65,
      "views_7d": 12000,
      "hook_type": "contrast",
      "topic_score": 4.2,
      "notes": "Drop-off at 3:20, pacing issue"
    }
  ]
}
```
