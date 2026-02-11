---
name: aivp-pipeline
description: >
  Orchestrate end-to-end AI video production by chaining aivp skills together.
  Use when user requests "make a video from scratch", "full video pipeline",
  "end to end video", "automate video production", "video workflow",
  or needs to chain multiple production steps (ideation → script → storyboard →
  image → video → audio → edit → review → publish) into a single workflow.
---

# AIVidPipeline Pipeline

Orchestrate the complete AI video production workflow.

<!-- TODO: Implement all sections below -->

## References

- [Workflow Templates](references/workflows.md) — Pre-built workflow templates

## Available Skills

| Phase | Skill | Input | Output |
|-------|-------|-------|--------|
| Pre-production | aivp-ideation | keywords/niche | scored topic list |
| Pre-production | aivp-script | topic | structured script JSON |
| Pre-production | aivp-storyboard | script | shot list JSON |
| Asset generation | aivp-image | shot list | keyframe images |
| Asset generation | aivp-video | keyframes + prompts | video clips |
| Asset generation | aivp-audio | script narration | voiceover + BGM + SRT |
| Post-production | aivp-edit | clips + audio + SRT | composed video |
| Quality | aivp-review | composed video | QA report |
| Distribution | aivp-publish | video + QA pass | metadata + uploads |
| Feedback | aivp-ideation | publish analytics | updated topic scores |

## Workflow Templates

### Quick Short (< 60s)

<!-- TODO: Define minimal viable pipeline -->

```
ideation → script(short-form) → storyboard → video → audio → edit → review → publish
```

Skip: aivp-image (use text-to-video directly for simple shorts)

### Full Production

<!-- TODO: Define complete pipeline -->

```
ideation → script → storyboard → image → video → audio → edit → review → publish
```

All skills in sequence, with character consistency checks between image and video.

### Batch Production

<!-- TODO: Define batch workflow -->

```
ideation(5 topics) → [script → storyboard → video → edit](×5) → review(×5) → publish(×5)
```

Parallel generation for multiple videos from a single ideation session.

## Data Flow Conventions

<!-- TODO: Define standard I/O format between skills -->

All skills read/write to a shared project directory:

```
project/
├── config.json          # Project settings (niche, style, platforms)
├── topic.json           # From ideation
├── script.json          # From script
├── storyboard.json      # From storyboard
├── assets/
│   ├── keyframes/       # From image
│   ├── clips/           # From video
│   └── audio/           # From audio
├── output/
│   ├── composed.mp4     # From edit
│   ├── review.json      # From review
│   └── published.json   # From publish
└── analytics/           # From ideation (feedback)
```

## Error Handling

<!-- TODO: Define per-stage error recovery -->

- Any stage failure → stop pipeline, report which stage failed
- Retry logic per stage (configurable)
- Human checkpoint after review stage (configurable)
