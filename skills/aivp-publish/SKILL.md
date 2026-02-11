---
name: aivp-publish
description: Optimize metadata, generate thumbnails, and prepare videos for publishing to multiple platforms. Use when the user requests "Publish video", "Upload to YouTube", "Create thumbnail", "SEO optimize", or similar publishing tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: publish, youtube, tiktok, thumbnail, seo, metadata
---

# AIVP Publish — Metadata, Thumbnails & Publishing

Prepare videos for publishing: generate thumbnails, optimize titles/descriptions/tags for each platform, and export platform-specific formats.

## When to Use

- After `aivp-review` passes
- User wants to publish or prepare for upload
- User needs thumbnails or SEO-optimized metadata

## Platform Specs

| Platform | Aspect Ratio | Max Duration | Max Size | Resolution |
|----------|:------------:|:------------:|:--------:|:----------:|
| YouTube | 16:9 | 12h | 256GB | 4K |
| YouTube Shorts | 9:16 | 60s | 256GB | 1080x1920 |
| TikTok | 9:16 | 10min | 4GB | 1080x1920 |
| Instagram Reels | 9:16 | 90s | 4GB | 1080x1920 |
| Instagram Feed | 1:1 or 4:5 | 60s | 4GB | 1080x1080 |
| Twitter/X | 16:9 | 2:20 | 512MB | 1920x1080 |

## Scripts

| Script | Purpose |
|--------|---------|
| `thumbnail.sh` | Extract or generate thumbnail from video |
| `metadata.sh` | Generate platform-optimized metadata |
| `reformat.sh` | Convert video to platform-specific format |

### Generate Thumbnail

```bash
# Extract best frame
bash scripts/thumbnail.sh \
  --video "output/final.mp4" \
  --output "output/thumbnail.jpg"

# Extract at specific timestamp
bash scripts/thumbnail.sh \
  --video "output/final.mp4" \
  --timestamp 15 \
  --output "output/thumbnail.jpg"
```

### Generate Metadata

This is LLM-driven. The agent generates optimized metadata:

```json
{
  "youtube": {
    "title": "5 Morning Habits That Changed My Life (Science-Backed)",
    "description": "Discover the morning routines used by the world's most successful people...\n\n⏰ Timestamps:\n0:00 Introduction\n0:15 Habit 1: Wake Up Early\n...\n\n🔔 Subscribe for more!",
    "tags": ["morning routine", "habits", "productivity", "success"],
    "category": "Education",
    "visibility": "public"
  },
  "tiktok": {
    "caption": "5 morning habits that actually work 🌅 #morningroutine #productivity #habits #success",
    "sounds": []
  },
  "shorts": {
    "title": "This morning habit changed everything #shorts",
    "description": "#morningroutine #productivity"
  }
}
```

### Reformat for Platform

```bash
# Convert to vertical for TikTok/Shorts
bash scripts/reformat.sh \
  --input "output/final.mp4" \
  --platform "tiktok" \
  --output "output/final_tiktok.mp4"

# Square for Instagram
bash scripts/reformat.sh \
  --input "output/final.mp4" \
  --platform "instagram" \
  --output "output/final_ig.mp4"
```

## SEO Tips

### YouTube Title
- Include primary keyword early
- Use numbers ("5 Habits", "Top 10")
- Add emotional trigger ("That Changed My Life")
- Keep under 60 characters

### YouTube Description
- First 2 lines are critical (shown in search)
- Include timestamps
- Add links and CTA
- Include keywords naturally

### Tags
- Primary keyword first
- Mix broad and specific
- 5-15 tags total
- Include common misspellings

## Integration with AIVP Pipeline

```
aivp-review (passed) → aivp-publish → aivp-ideation (analytics feedback)
```

### Project Directory Convention

```
project/
├── output/
│   ├── final.mp4
│   ├── final_shorts.mp4       ← vertical cut
│   ├── final_tiktok.mp4       ← TikTok format
│   └── thumbnail.jpg
└── publish/
    └── metadata.json          ← per-platform metadata
```

## References

- [references/platforms.md](references/platforms.md) — Detailed platform specs and best practices
