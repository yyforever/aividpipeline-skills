---
name: seedance-edit
description: >
  Edit and compose video using ffmpeg for AI video production.
  Use when user requests "edit video", "cut video", "merge clips",
  "add subtitles", "add music to video", "trim video", "concat videos",
  "video transitions", "burn subtitles", "overlay audio",
  or needs to perform any ffmpeg-based video editing operations
  including cutting, merging, subtitle burning, and audio mixing.
---

# Seedance Edit

Video editing with ffmpeg — cutting, merging, transitions, subtitles, and audio mixing.

<!-- TODO: Implement all sections below -->

## References

- [FFmpeg Recipes](references/ffmpeg-recipes.md) — Common ffmpeg command patterns

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/cut.sh` | Cut/trim video segments |
| `scripts/merge.sh` | Concatenate multiple clips |
| `scripts/subtitle.sh` | Burn SRT subtitles into video |

## Operations

### Cut / Trim

<!-- TODO: Implement cut script -->

```bash
# Cut from 00:01:30 to 00:03:00
ffmpeg -i input.mp4 -ss 00:01:30 -to 00:03:00 -c:v libx264 -c:a aac output.mp4
```

### Merge / Concatenate

<!-- TODO: Implement merge script with transition support -->

```bash
# Concatenate clips
ffmpeg -f concat -safe 0 -i filelist.txt -c copy output.mp4
```

### Subtitle Burning

<!-- TODO: Implement subtitle script with styling options -->

```bash
# Burn SRT subtitles
ffmpeg -i input.mp4 -vf "subtitles=subs.srt:force_style='FontSize=24'" output.mp4
```

### Audio Mixing

<!-- TODO: Implement audio overlay (voiceover + BGM + video) -->

```bash
# Merge audio and video
ffmpeg -i video.mp4 -i voiceover.mp3 -i bgm.mp3 \
  -filter_complex "[1:a]volume=1.0[vo];[2:a]volume=0.3[bg];[vo][bg]amix=inputs=2[a]" \
  -map 0:v -map "[a]" -c:v copy output.mp4
```

### Multi-platform Resize

<!-- TODO: Implement aspect ratio cropping -->

```bash
# 16:9 → 9:16 (center crop for Shorts/Reels)
ffmpeg -i input.mp4 -vf "crop=ih*9/16:ih" output_vertical.mp4
```

## Prerequisites

- `ffmpeg` and `ffprobe` installed
- Verify: `ffmpeg -version`
