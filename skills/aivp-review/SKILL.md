---
name: aivp-review
description: >
  Automated quality review and content safety checks for AI video production.
  Use when user requests "review video", "quality check", "QA check",
  "pre-publish review", "check video quality", "content review",
  or needs to validate video technical specs, audio levels,
  content safety, and brand compliance before publishing.
---

# AIVidPipeline Review

Automated quality checks and content review before publishing.

<!-- TODO: Implement all sections below -->

## References

- [Review Checklist](references/checklist.md) — Complete pre-publish checklist

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/check.sh` | Automated technical quality checks via ffprobe |

## Automated Technical Checks

<!-- TODO: Implement check.sh -->

1. **Resolution** — Meets platform minimum (1080p for YouTube, 720p minimum)
2. **Aspect ratio** — Matches target platform (16:9, 9:16, 1:1)
3. **Duration** — Within platform limits (60s for Shorts, 3min for Reels)
4. **Audio levels** — Peak < -1dBFS, average -14 to -16 LUFS
5. **Frame rate** — 24/30/60 fps (no odd rates)
6. **File size** — Within upload limits
7. **Codec** — H.264/H.265 for video, AAC for audio
8. **Subtitle sync** — SRT timestamps align with audio

## Content Safety

<!-- TODO: Implement content safety checks -->
<!-- TODO: Evaluate API options (Google Cloud Vision, OpenAI moderation) -->

- NSFW detection
- Violence/gore detection
- Copyright risk flags (watermarks, logos)
- Platform-specific policy compliance

## Human Review Checklist

<!-- TODO: Generate interactive checklist -->

- [ ] Visual quality acceptable (no artifacts, glitches)
- [ ] Character consistency across shots
- [ ] Audio/video sync correct
- [ ] Text on screen readable
- [ ] Brand guidelines followed
- [ ] No unintended content
- [ ] Pacing feels right
- [ ] CTA is clear

## Output Format

```json
{
  "status": "pass|warn|fail",
  "technical": {
    "resolution": { "value": "1920x1080", "status": "pass" },
    "audio_levels": { "peak": "-3dB", "lufs": "-15", "status": "pass" },
    "duration": { "value": "58s", "status": "pass" }
  },
  "content_safety": {
    "nsfw": "pass",
    "violence": "pass",
    "copyright": "warn"
  },
  "human_review_needed": true,
  "issues": []
}
```
