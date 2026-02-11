---
name: aivp-review
description: Automated quality review and content safety checks for AI video production. Use when the user requests "Review video", "Quality check", "Content review", "Check before publish", or similar review tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: review, quality, safety, checklist, qa
---

# AIVP Review — Quality & Safety Review

Automated quality review before publishing. Checks technical quality, content consistency, and safety compliance.

## When to Use

- After `aivp-edit` produces the final video
- Before `aivp-publish`
- User wants a quality check

## Review Checklist

### Technical Quality

| Check | How | Pass Criteria |
|-------|-----|---------------|
| Resolution | `ffprobe` | ≥ 1080p for YouTube, ≥ 720p for social |
| Frame rate | `ffprobe` | ≥ 24fps |
| Audio levels | `ffmpeg loudnorm` | -14 LUFS ± 2 (YouTube standard) |
| Duration | `ffprobe` | Within ±10% of target |
| File size | `ls -la` | < 4GB (YouTube limit) |
| Codec | `ffprobe` | H.264/H.265 for compatibility |
| Black frames | `ffmpeg blackdetect` | No unintended black frames > 1s |
| Silent sections | `ffmpeg silencedetect` | No unintended silence > 2s |

### Content Consistency

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Scene count | Compare to storyboard | All scenes present |
| Duration per scene | Extract from timeline | Within ±20% of target |
| Audio-visual sync | Compare VO timing to cuts | Narration matches visuals |
| Style consistency | Visual inspection notes | No jarring style breaks |
| Text readability | Check subtitle timing | Each subtitle ≥ 1.5s on screen |

### Content Safety

| Check | Severity | Action |
|-------|----------|--------|
| NSFW content | 🔴 Block | Do not publish |
| Copyright music | 🔴 Block | Replace with generated BGM |
| Watermarks from AI | 🟡 Warning | Note for user decision |
| Factual claims | 🟡 Warning | Flag for human review |
| Brand safety | 🟡 Warning | Check for controversial content |

## Scripts

| Script | Purpose |
|--------|---------|
| `check-technical.sh` | FFprobe-based technical checks |
| `check-audio.sh` | Audio level and silence detection |

### Technical Check

```bash
bash scripts/check-technical.sh --input "output/final.mp4"
```

Output:
```json
{
  "resolution": "1920x1080",
  "fps": 30,
  "duration": "180.5s",
  "codec": "h264",
  "audio_codec": "aac",
  "file_size_mb": 245,
  "checks": {
    "resolution": "PASS",
    "fps": "PASS",
    "duration": "PASS",
    "file_size": "PASS",
    "black_frames": "PASS",
    "silence": "WARNING: 1.5s silence at 45.0s"
  },
  "overall": "PASS_WITH_WARNINGS"
}
```

### Audio Level Check

```bash
bash scripts/check-audio.sh --input "output/final.mp4"
```

## Review Report

The agent generates a review report:

```markdown
## Video Review Report

### ✅ Technical Quality
- Resolution: 1920x1080 ✅
- FPS: 30 ✅
- Duration: 3:00 (target: 3:00) ✅
- Audio: -13.8 LUFS ✅

### ⚠️ Warnings
- 1.5s silence at 0:45 — check if intentional

### Content
- 5/5 scenes present ✅
- Style consistent ✅
- Subtitles readable ✅

### Verdict: READY TO PUBLISH
```

## Integration with AIVP Pipeline

```
aivp-edit (final video) → aivp-review → aivp-publish (if passed)
                                       → aivp-edit (if failed, with notes)
```

### Project Directory Convention

```
project/
├── output/
│   └── final.mp4
└── review/
    └── report.json       ← review results
```

## References

- [references/checklist.md](references/checklist.md) — Complete review checklist with thresholds
