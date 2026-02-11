---
name: aivp-pipeline
description: Orchestrate end-to-end AI video production by chaining aivp skills together. Use when the user requests "Make a video from scratch", "Full video pipeline", "End to end video", or wants to run the complete production workflow.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: pipeline, orchestration, workflow, end-to-end
---

# AIVP Pipeline — End-to-End Video Production Orchestrator

Lightweight orchestrator that chains aivp skills into a complete video production workflow. Defines project structure, data flow conventions, and execution order.

**This skill does NOT hardcode a fixed workflow.** It defines conventions so that each skill can interoperate. The agent decides which steps to run based on user intent.

## Quick Start

```
Make a 3-minute YouTube video about "5 Morning Habits of Successful People"
```

The agent will execute:

```
1. aivp-ideation  → validate topic, check competition
2. aivp-script    → generate structured script (JSON)
3. aivp-storyboard → convert script to shot list with prompts
4. aivp-image     → generate keyframes from storyboard prompts
5. aivp-video     → animate keyframes to video clips (I2V)
6. aivp-audio     → generate voiceover (TTS) + background music
7. aivp-edit      → concat clips + mix audio + burn subtitles
8. aivp-review    → technical quality check
9. aivp-publish   → thumbnail + metadata + platform formatting
```

## Project Directory Structure

Every pipeline run creates a project directory:

```
project-name/
├── ideation/
│   └── ideas.json              ← topic validation & scoring
├── script.json                 ← structured script with scenes
├── storyboard.json             ← shot list with AI prompts
├── references/
│   ├── character_main.png      ← character reference sheet
│   └── style_frame.png         ← visual style reference
├── keyframes/
│   ├── shot_01.png             ← generated from storyboard
│   ├── shot_02.png
│   └── ...
├── clips/
│   ├── shot_01.mp4             ← animated from keyframes
│   ├── shot_02.mp4
│   └── ...
├── audio/
│   ├── voiceover.mp3           ← full narration
│   ├── voiceover_scene_01.mp3  ← per-scene (optional)
│   ├── bgm.mp3                 ← background music
│   └── sfx/                    ← sound effects (optional)
├── subtitles/
│   └── transcript.srt          ← from speech-to-text
├── output/
│   ├── final.mp4               ← master output
│   ├── final_shorts.mp4        ← vertical cut (optional)
│   ├── final_tiktok.mp4        ← platform variant (optional)
│   └── thumbnail.jpg           ← generated thumbnail
├── review/
│   └── report.json             ← quality check results
├── publish/
│   └── metadata.json           ← per-platform metadata
└── metadata/
    ├── pipeline.json           ← execution log
    ├── shot_01.json            ← per-shot generation params
    └── ...
```

## Pipeline Modes

### Full Pipeline
Run everything from topic to publish-ready video:
```
Create a complete video about [topic]
```

### Partial Pipeline
Start from any point:

| Start From | When To Use |
|------------|-------------|
| Script → | User already has a topic/outline |
| Storyboard → | User already has a script |
| Image → | User already has a storyboard |
| Video → | User already has keyframes |
| Edit → | User already has clips + audio |
| Review → | User already has final video |

```
I have a script ready at project/script.json, generate the video from there
```

### Single Skill
Run any skill independently:
```
Generate a voiceover for this text: "..."
```

## Data Flow

```
                    ┌─────────────┐
                    │  ideation   │ ← analytics feedback
                    └──────┬──────┘
                           │ topic + validation
                    ┌──────▼──────┐
                    │   script    │
                    └──────┬──────┘
                           │ script.json (scenes + narration)
                    ┌──────▼──────┐
                    │ storyboard  │
                    └──────┬──────┘
                           │ storyboard.json (shots + prompts)
                ┌──────────┼──────────┐
                │          │          │
         ┌──────▼──┐ ┌────▼────┐ ┌───▼─────┐
         │  image   │ │  video  │ │  audio  │
         │(keyframe)│ │(T2V/I2V)│ │(VO+BGM) │
         └──────┬───┘ └────┬────┘ └───┬─────┘
                │          │          │
                └──────────┼──────────┘
                    ┌──────▼──────┐
                    │    edit     │ ← concat + mix + subs
                    └──────┬──────┘
                           │ final.mp4
                    ┌──────▼──────┐
                    │   review    │
                    └──────┬──────┘
                           │ PASS / FAIL
                    ┌──────▼──────┐
                    │   publish   │ → thumbnail + metadata
                    └──────┬──────┘
                           │ analytics
                    ┌──────▼──────┐
                    │  ideation   │ ← feedback loop
                    └─────────────┘
```

## Execution Log

The pipeline tracks what was run in `metadata/pipeline.json`:

```json
{
  "project": "morning-habits",
  "created": "2026-02-11T14:00:00Z",
  "steps": [
    {
      "skill": "aivp-script",
      "status": "completed",
      "started": "2026-02-11T14:00:05Z",
      "completed": "2026-02-11T14:00:12Z",
      "output": "script.json"
    },
    {
      "skill": "aivp-storyboard",
      "status": "completed",
      "started": "2026-02-11T14:00:12Z",
      "completed": "2026-02-11T14:00:18Z",
      "output": "storyboard.json"
    },
    {
      "skill": "aivp-video",
      "status": "completed",
      "started": "2026-02-11T14:00:18Z",
      "completed": "2026-02-11T14:05:30Z",
      "output": "clips/",
      "details": {
        "model": "fal-ai/bytedance/seedance/v1.5/pro",
        "clips_generated": 8,
        "total_duration": "2:45"
      }
    }
  ],
  "total_cost_estimate": "$2.40",
  "total_time": "5:30"
}
```

## Configuration

### Default Models

Override defaults per project by setting environment variables or passing to scripts:

| Component | Default Model | Env Variable |
|-----------|---------------|-------------|
| Video (T2V) | `fal-ai/bytedance/seedance/v1.5/pro` | `AIVP_VIDEO_MODEL` |
| Video (I2V) | `fal-ai/kling-video/v2.6/pro/image-to-video` | `AIVP_I2V_MODEL` |
| Image | `fal-ai/nano-banana-pro` | `AIVP_IMAGE_MODEL` |
| TTS | `fal-ai/minimax/speech-2.6-turbo` | `AIVP_TTS_MODEL` |
| Music | `fal-ai/minimax-music/v2` | `AIVP_MUSIC_MODEL` |
| STT | `fal-ai/whisper` | `AIVP_STT_MODEL` |

### API Keys

```bash
# Required
export FAL_KEY=your_fal_key

# Optional (for specific providers)
export REPLICATE_API_TOKEN=your_token
export PEXELS_API_KEY=your_key
```

## Tips

1. **Always generate keyframes first, then animate** — I2V produces more consistent results than T2V for multi-scene videos
2. **Lock visual style early** — generate a style frame and character reference before scene keyframes
3. **Use the same model throughout** — mixing models causes style inconsistency
4. **Review before publish** — automated checks catch technical issues; human review catches creative ones
5. **Save generation params** — seeds, models, and prompts in metadata/ enable reproducibility
6. **Start small** — test with 2-3 scenes before generating a full 10-scene video
