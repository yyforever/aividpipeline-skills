---
name: seedance-pipeline
description: >
  Orchestrate end-to-end AI video production by chaining seedance skills together.
  Use when user requests "make a video from scratch", "full video pipeline",
  "end to end video", "automate video production", "video workflow",
  or needs to chain multiple production steps (ideation → script → storyboard →
  image → video → audio → edit → review → publish) into a single workflow.
---

# Seedance Pipeline

Orchestrate the complete AI video production workflow.

<!-- TODO: Implement all sections below -->

## References

- [Workflow Templates](references/workflows.md) — Pre-built workflow templates

## Available Skills

| Phase | Skill | Input | Output |
|-------|-------|-------|--------|
| Pre-production | seedance-ideation | keywords/niche | scored topic list |
| Pre-production | seedance-script | topic | structured script JSON |
| Pre-production | seedance-storyboard | script | shot list JSON |
| Asset generation | seedance-image | shot list | keyframe images |
| Asset generation | seedance-video | keyframes + prompts | video clips |
| Asset generation | seedance-audio | script narration | voiceover + BGM + SRT |
| Post-production | seedance-edit | clips + audio + SRT | composed video |
| Quality | seedance-review | composed video | QA report |
| Distribution | seedance-publish | video + QA pass | metadata + uploads |
| Feedback | seedance-ideation | publish analytics | updated topic scores |

## Workflow Templates

### Quick Short (< 60s)

<!-- TODO: Define minimal viable pipeline -->

```
ideation → script(short-form) → storyboard → video → audio → edit → review → publish
```

Skip: seedance-image (use text-to-video directly for simple shorts)

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
