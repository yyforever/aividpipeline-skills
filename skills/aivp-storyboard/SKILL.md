---
name: aivp-storyboard
description: Design visual storyboards and shot lists for AI video production. Use when the user requests "Create storyboard", "Shot list", "Visual plan", "Scene breakdown", or similar visual planning tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: storyboard, shot-list, visual-planning, cinematography, camera
---

# AIVP Storyboard — Visual Planning & Shot Design

Convert scripts into detailed storyboards with shot-by-shot specifications. Output is optimized for `aivp-image` (keyframe generation) and `aivp-video` (clip generation).

## When to Use

- After script is written, before image/video generation
- User needs a visual plan for their video
- User wants to define camera angles, compositions, and visual style

## Output Format

Storyboards are output as structured JSON:

```json
{
  "project": "morning-habits",
  "style_guide": {
    "color_palette": "warm golden, soft whites, deep navy",
    "visual_style": "cinematic, shallow depth of field",
    "aspect_ratio": "16:9",
    "reference_images": []
  },
  "shots": [
    {
      "shot_id": "01",
      "scene_id": "01",
      "shot_type": "wide",
      "camera_angle": "low_angle",
      "camera_movement": "slow_tilt_up",
      "subject": "City skyline at sunrise",
      "composition": "Rule of thirds, sun on right intersection point",
      "lighting": "Golden hour, warm backlight",
      "prompt": "Cinematic wide shot, city skyline at sunrise, golden hour, warm light, low angle slowly tilting up, photorealistic, 16:9",
      "duration": "5s",
      "narration_sync": "Every morning, before the world wakes up..."
    },
    {
      "shot_id": "02",
      "scene_id": "01",
      "shot_type": "close_up",
      "camera_angle": "eye_level",
      "camera_movement": "static",
      "subject": "Alarm clock showing 5:30 AM",
      "composition": "Center frame, shallow DOF, bedside table",
      "lighting": "Soft morning light from window",
      "prompt": "Close-up of alarm clock showing 5:30 AM, soft morning light, shallow depth of field, warm tones, photorealistic",
      "duration": "3s",
      "narration_sync": "...the most successful people have already started their day."
    }
  ]
}
```

## Shot Types

| Type | Description | Use For |
|------|-------------|---------|
| `extreme_wide` | Vast landscape/environment | Establishing shots |
| `wide` | Full scene with environment | Scene setting |
| `medium` | Subject waist-up | Dialogue, action |
| `close_up` | Face or object detail | Emotion, detail |
| `extreme_close_up` | Eyes, hands, texture | Dramatic emphasis |
| `over_shoulder` | From behind one subject | Conversations |
| `pov` | First-person perspective | Immersion |

## Camera Movements

| Movement | Description |
|----------|-------------|
| `static` | No movement |
| `slow_pan_left/right` | Horizontal rotation |
| `slow_tilt_up/down` | Vertical rotation |
| `dolly_in/out` | Move toward/away |
| `tracking` | Follow subject |
| `crane_up/down` | Vertical elevation |
| `orbit` | Circle around subject |

## Camera Angles

| Angle | Effect |
|-------|--------|
| `eye_level` | Neutral, natural |
| `low_angle` | Power, grandeur |
| `high_angle` | Vulnerability, overview |
| `bird_eye` | God's view, context |
| `dutch_angle` | Tension, unease |

## Usage

This skill is primarily LLM-driven. The agent converts scripts to storyboards.

### Prompt Template

```
Convert this script to a storyboard:
[paste script JSON or text]

For each scene, create 2-4 shots with:
- shot_id, scene_id
- shot_type, camera_angle, camera_movement
- subject, composition, lighting
- prompt (optimized for AI image/video generation)
- duration
- narration_sync (which narration text plays during this shot)

Also define a style_guide with color palette, visual style, and aspect ratio.
Output as JSON following the aivp-storyboard schema.
```

## Integration with AIVP Pipeline

```
aivp-script → aivp-storyboard → aivp-image (generate keyframes from prompts)
                               → aivp-video (generate clips from prompts)
```

### Project Directory Convention

```
project/
├── script.json
├── storyboard.json       ← this skill's output
└── keyframes/
    ├── shot_01.png        ← generated from storyboard prompts
    └── shot_02.png
```

## Tips

1. **2-4 shots per scene** — enough variety without over-complicating
2. **Vary shot types** — alternate wide/medium/close-up for visual rhythm
3. **Camera movement = video prompt** — "slow zoom in" directly maps to AI video prompt
4. **Prompt field is the key output** — this text goes directly into aivp-image and aivp-video
5. **Duration per shot: 3-10 seconds** — matches AI video model output lengths

## References

- [references/shot-language.md](references/shot-language.md) — Complete cinematography vocabulary
- [references/templates.md](references/templates.md) — Storyboard templates by video type
