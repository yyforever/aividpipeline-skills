---
name: aivp-edit
description: Edit and compose video using FFmpeg for AI video production. Use when the user requests "Combine clips", "Add music to video", "Add subtitles", "Trim video", "Concat videos", "Adjust speed", or similar video editing tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: ffmpeg, video-editing, compose, subtitle, concat, trim
---

# AIVP Edit — FFmpeg Video Editing & Composition

Compose final videos from clips, audio, and subtitles using FFmpeg. This skill handles the "post-production" stage: concatenation, audio mixing, subtitle burning, transitions, and export.

## Prerequisites

- FFmpeg installed (`brew install ffmpeg` / `apt install ffmpeg`)

## Scripts

| Script | Purpose |
|--------|---------|
| `concat.sh` | Concatenate multiple clips into one |
| `mix-audio.sh` | Add voiceover and/or BGM to video |
| `add-subtitles.sh` | Burn subtitles into video |
| `trim.sh` | Trim video by start/end time |
| `adjust-speed.sh` | Speed up or slow down video |
| `export.sh` | Full pipeline: concat + audio + subtitles |

## Concatenate Clips

```bash
bash scripts/concat.sh [options]
```

### Basic Usage

```bash
# Concat clips in order
bash scripts/concat.sh \
  --input "clips/scene_01.mp4" \
  --input "clips/scene_02.mp4" \
  --input "clips/scene_03.mp4" \
  --output "output/combined.mp4"

# From a file list
bash scripts/concat.sh \
  --list "clips/filelist.txt" \
  --output "output/combined.mp4"
```

`filelist.txt` format:
```
file 'scene_01.mp4'
file 'scene_02.mp4'
file 'scene_03.mp4'
```

### Arguments

| Argument | Description |
|----------|-------------|
| `--input`, `-i` | Input file (repeatable) |
| `--list` | FFmpeg concat file list |
| `--output`, `-o` | Output file path (required) |
| `--transition` | `none`, `crossfade` (default: none) |
| `--crossfade-duration` | Crossfade duration in seconds (default: 0.5) |

## Mix Audio

```bash
bash scripts/mix-audio.sh [options]
```

### Basic Usage

```bash
# Add voiceover
bash scripts/mix-audio.sh \
  --video "output/combined.mp4" \
  --voiceover "audio/voiceover.mp3" \
  --output "output/with_vo.mp4"

# Add BGM (lower volume)
bash scripts/mix-audio.sh \
  --video "output/with_vo.mp4" \
  --bgm "audio/bgm.mp3" \
  --bgm-volume 0.15 \
  --output "output/with_bgm.mp4"

# Both at once
bash scripts/mix-audio.sh \
  --video "output/combined.mp4" \
  --voiceover "audio/voiceover.mp3" \
  --bgm "audio/bgm.mp3" \
  --bgm-volume 0.15 \
  --output "output/final.mp4"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--video` | Input video (required) | - |
| `--voiceover` | Voiceover audio file | - |
| `--bgm` | Background music file | - |
| `--bgm-volume` | BGM volume (0.0 - 1.0) | 0.15 |
| `--vo-volume` | Voiceover volume | 1.0 |
| `--output`, `-o` | Output file (required) | - |

## Add Subtitles

```bash
bash scripts/add-subtitles.sh [options]
```

### Basic Usage

```bash
# Burn SRT subtitles
bash scripts/add-subtitles.sh \
  --video "output/final.mp4" \
  --srt "subtitles/transcript.srt" \
  --output "output/with_subs.mp4"

# Custom style
bash scripts/add-subtitles.sh \
  --video "output/final.mp4" \
  --srt "subtitles/transcript.srt" \
  --font-size 24 \
  --font-color "white" \
  --outline-color "black" \
  --position "bottom" \
  --output "output/with_subs.mp4"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--video` | Input video (required) | - |
| `--srt` | SRT subtitle file (required) | - |
| `--font-size` | Font size | 24 |
| `--font-color` | Font color | white |
| `--outline-color` | Outline color | black |
| `--position` | `top`, `center`, `bottom` | bottom |
| `--output`, `-o` | Output file (required) | - |

## Trim Video

```bash
# Trim from 5s to 15s
bash scripts/trim.sh \
  --input "video.mp4" \
  --start 5 \
  --end 15 \
  --output "trimmed.mp4"

# Trim first 3 seconds off
bash scripts/trim.sh \
  --input "video.mp4" \
  --start 3 \
  --output "trimmed.mp4"
```

## Adjust Speed

```bash
# 2x speed
bash scripts/adjust-speed.sh \
  --input "video.mp4" \
  --speed 2.0 \
  --output "fast.mp4"

# Slow motion (0.5x)
bash scripts/adjust-speed.sh \
  --input "video.mp4" \
  --speed 0.5 \
  --output "slowmo.mp4"
```

## Full Export Pipeline

```bash
bash scripts/export.sh [options]
```

One command to do everything: concat → mix audio → burn subtitles → export.

```bash
bash scripts/export.sh \
  --clips-dir "clips/" \
  --voiceover "audio/voiceover.mp3" \
  --bgm "audio/bgm.mp3" \
  --bgm-volume 0.15 \
  --srt "subtitles/transcript.srt" \
  --output "output/final_video.mp4" \
  --resolution "1920x1080" \
  --fps 30
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--clips-dir` | Directory of clips (sorted by name) | - |
| `--clips-list` | Explicit file list | - |
| `--voiceover` | Voiceover file | - |
| `--bgm` | Background music | - |
| `--bgm-volume` | BGM volume | 0.15 |
| `--srt` | Subtitle file | - |
| `--output`, `-o` | Final output path (required) | - |
| `--resolution` | Output resolution | source |
| `--fps` | Output frame rate | source |
| `--codec` | Video codec | libx264 |
| `--quality` | CRF value (lower = better) | 23 |

## Integration with AIVP Pipeline

```
aivp-video (clips) + aivp-audio (VO + BGM) → aivp-edit → aivp-review
```

### Project Directory Convention

```
project/
├── clips/
│   ├── scene_01.mp4
│   ├── scene_02.mp4
│   └── scene_03.mp4
├── audio/
│   ├── voiceover.mp3
│   └── bgm.mp3
├── subtitles/
│   └── transcript.srt
└── output/
    ├── combined.mp4          ← concat only
    ├── with_audio.mp4        ← + audio
    └── final.mp4             ← + subtitles (upload this)
```

## Common FFmpeg Recipes

### Crossfade Transition
```bash
ffmpeg -i clip1.mp4 -i clip2.mp4 \
  -filter_complex "xfade=transition=fade:duration=0.5:offset=4" \
  -y output.mp4
```

### Picture-in-Picture
```bash
ffmpeg -i main.mp4 -i overlay.mp4 \
  -filter_complex "[1:v]scale=320:180[pip];[0:v][pip]overlay=W-w-10:H-h-10" \
  -y output.mp4
```

### Add Fade In/Out
```bash
ffmpeg -i input.mp4 \
  -vf "fade=t=in:st=0:d=1,fade=t=out:st=9:d=1" \
  -y output.mp4
```

### Scale to 1080p
```bash
ffmpeg -i input.mp4 \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -y output.mp4
```

## Troubleshooting

### Clips Have Different Resolutions
Scale all clips to same resolution before concat, or use `--resolution` in `export.sh`.

### Audio Out of Sync
Ensure voiceover duration matches video. Use `trim.sh` or adjust with `--start` offset.

### Large Output File
Lower quality: `--quality 28` or use `--codec libx265` for better compression.
