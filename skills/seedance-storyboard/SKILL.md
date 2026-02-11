---
name: seedance-storyboard
description: >
  Design visual storyboards and shot lists for AI video production.
  Use when user requests "storyboard", "shot list", "shot planning",
  "scene breakdown", "visual planning", "camera angles", "shot design",
  or needs to convert a script into a structured visual production plan
  with camera language, composition, and timing.
---

# Seedance Storyboard

Convert scripts into structured shot lists with professional camera language.

<!-- TODO: Implement all sections below -->

## References

- [Shot Language](references/shot-language.md) — Camera angles, movements, transitions terminology
- [Templates](references/templates.md) — Shot list JSON templates and examples

## Shot Design Process

<!-- TODO: Implement shot design workflow -->

1. Parse script into scenes and beats
2. Assign shot type (wide/medium/close-up/detail) per beat
3. Define camera movement (static/pan/tilt/dolly/drone)
4. Specify transitions between shots (cut/dissolve/fade/match cut)
5. Estimate duration per shot
6. Add visual description for image/video generation prompts

## Output Format

<!-- TODO: Define JSON schema -->

```json
{
  "title": "...",
  "total_duration": "60s",
  "shots": [
    {
      "id": 1,
      "scene": 1,
      "shot_type": "close-up",
      "camera_movement": "slow zoom in",
      "transition_in": "cut",
      "duration": "3s",
      "visual_description": "...",
      "narration_segment": "...",
      "generation_prompt": "...",
      "aspect_ratio": "16:9"
    }
  ]
}
```

## Key Considerations

<!-- TODO: Elaborate on each -->

- **Pacing**: Vary shot lengths for rhythm (fast cuts for energy, long shots for mood)
- **180° Rule**: Maintain spatial consistency across shots in a scene
- **Shot-reverse-shot**: For dialogue or reaction sequences
- **Establishing shots**: Open scenes with context-setting wide shots
- **Match cuts**: Connect scenes thematically through visual similarity
