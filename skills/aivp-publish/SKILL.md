---
name: aivp-publish
description: >
  Optimize metadata, generate thumbnails, and publish videos to multiple platforms.
  Use when user requests "publish video", "upload to YouTube", "post to TikTok",
  "create thumbnail", "SEO optimize", "video metadata", "repurpose video",
  "multi-platform publish", "generate tags", "video description",
  or needs to prepare and distribute video content across platforms
  with optimized titles, descriptions, tags, and thumbnails.
---

# AIVidPipeline Publish

Metadata optimization, thumbnail generation, and multi-platform distribution.

<!-- TODO: Implement all sections below -->

## References

- [Platform Specs](references/platforms.md) — Format requirements per platform

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/metadata.sh` | Generate SEO-optimized title, description, tags |
| `scripts/thumbnail.sh` | Generate video thumbnail |
| `scripts/repurpose.sh` | Reformat video for different platforms |

## Metadata Generation

<!-- TODO: Implement metadata generation -->

### Title Optimization
- Hook pattern: Number + Adjective + Keyword + Promise
- A/B test variants (generate 3-5 options)
- Platform-specific length (YouTube 60 chars, TikTok shorter)

### Description
- First 2 lines visible above fold — front-load keywords
- Structured sections: summary, timestamps, links, hashtags
- Platform-specific formatting

### Tags
- Mix of broad + specific + long-tail keywords
- Competitor tag analysis

## Thumbnail Generation

<!-- TODO: Implement thumbnail generation -->
<!-- TODO: Integrate with aivp-image for AI thumbnail creation -->

- High contrast, readable at small sizes
- Face + emotion when applicable
- Text overlay (3-5 words max)
- Platform-specific dimensions (YouTube 1280x720, etc.)

## Multi-platform Repurposing

<!-- TODO: Implement repurpose.sh -->

| Platform | Aspect | Max Duration | Notes |
|----------|--------|-------------|-------|
| YouTube | 16:9 | 12h | Chapters, cards, end screens |
| YouTube Shorts | 9:16 | 60s | Vertical, loop-friendly |
| TikTok | 9:16 | 10min | Trending sounds, hashtags |
| Instagram Reels | 9:16 | 90s | Cover frame selection |
| Bilibili | 16:9 | Varies | Chinese metadata |

## Output Format

```json
{
  "metadata": {
    "title": "...",
    "title_variants": ["...", "..."],
    "description": "...",
    "tags": ["...", "..."],
    "hashtags": ["...", "..."],
    "thumbnail_path": "...",
    "category": "...",
    "language": "..."
  },
  "platform_variants": {
    "youtube": { "file": "...", "metadata": {} },
    "tiktok": { "file": "...", "metadata": {} },
    "reels": { "file": "...", "metadata": {} }
  }
}
```
