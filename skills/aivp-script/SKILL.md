---
name: aivp-script
description: Generate structured video scripts for AI video production. Use when the user requests "Write a video script", "Create narration", "Script for video", "Write dialogue", or similar script writing tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: script, writing, narration, dialogue, storytelling
---

# AIVP Script — Video Script Generation

Generate structured video scripts with scene breakdowns, narration text, and visual directions. Output is optimized for downstream use by `aivp-storyboard` and `aivp-audio`.

## When to Use

- User wants to create a video and needs a script
- User has a topic/idea and wants structured content
- User needs narration text for voiceover generation

## Output Format

Scripts are output as structured JSON for machine consumption:

```json
{
  "title": "5 Morning Habits of Successful People",
  "duration_estimate": "3:00",
  "style": "documentary",
  "scenes": [
    {
      "scene_id": "01",
      "duration": "15s",
      "narration": "Every morning, before the world wakes up, the most successful people have already started their day.",
      "visual_direction": "Sunrise timelapse over city skyline, warm golden light",
      "mood": "inspiring",
      "transition": "fade_in"
    },
    {
      "scene_id": "02",
      "duration": "30s",
      "narration": "The first habit is waking up early. Studies show that 90% of executives wake before 6 AM.",
      "visual_direction": "Person stretching in bed, alarm clock showing 5:30 AM, soft morning light",
      "mood": "calm",
      "transition": "cut"
    }
  ],
  "metadata": {
    "target_audience": "young professionals",
    "tone": "motivational",
    "cta": "Subscribe for more productivity tips"
  }
}
```

## Script Styles

| Style | Description | Best For |
|-------|-------------|----------|
| `documentary` | Informative narration with B-roll directions | Educational, explainer |
| `listicle` | Numbered sections ("Top 5...") | Social media, YouTube |
| `tutorial` | Step-by-step instructions | How-to content |
| `story` | Narrative arc (setup → conflict → resolution) | Brand stories, shorts |
| `commercial` | Short, punchy, CTA-focused | Ads, product demos |
| `interview` | Q&A format with multiple speakers | Podcasts, testimonials |

## Usage

This skill is primarily LLM-driven (no shell scripts). The agent generates the script directly.

### Prompt Template

When generating a script, follow this structure:

```
Generate a video script with these parameters:
- Topic: [user's topic]
- Duration: [target length]
- Style: [documentary/listicle/tutorial/story/commercial]
- Audience: [target audience]
- Tone: [professional/casual/funny/inspiring]

Output as JSON following the aivp-script schema.
Each scene should include:
- scene_id (sequential, zero-padded)
- duration (estimated)
- narration (exact text for voiceover)
- visual_direction (what the viewer sees — detailed enough for image generation)
- mood (emotional tone of the scene)
- transition (cut/fade_in/fade_out/crossfade)
```

## Integration with AIVP Pipeline

```
aivp-ideation (topic) → aivp-script → aivp-storyboard (shot breakdown)
                                     → aivp-audio (narration text → TTS)
```

### Project Directory Convention

```
project/
├── script.json           ← structured script
├── script_raw.md         ← human-readable version
└── metadata/
    └── script_params.json
```

## Tips for Better Scripts

1. **Keep scenes 10-30 seconds** — matches typical AI video clip length
2. **Visual directions should be specific** — "woman in red dress on cliff" not "person outside"
3. **Narration pacing** — ~150 words per minute for comfortable listening
4. **Hook in first 5 seconds** — critical for social media retention
5. **End with CTA** — subscribe, follow, visit website

## References

For detailed format specifications and examples, see:
- [references/formats.md](references/formats.md) — JSON schema and field definitions
- [references/examples.md](references/examples.md) — Complete script examples by style
