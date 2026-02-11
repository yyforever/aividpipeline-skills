---
name: seedance-video
description: >
  Generate video clips using AI video models for video production.
  Use when user requests "generate video", "create video clip", "text to video",
  "image to video", "animate image", "video generation",
  or needs to generate video clips from text prompts or keyframe images
  using Seedance, Kling, Sora, Veo, or other video generation models.
---

# Seedance Video

Generate video clips from text or images using state-of-the-art AI video models.

<!-- TODO: Implement all sections below -->

## References

- [Video Models](references/models.md) — Model comparison, pricing, and selection guide
- [Prompt Guide](references/prompts.md) — Prompt templates and the SCELA framework
- [Cross-shot Consistency](references/consistency.md) — Maintaining visual consistency across clips

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/generate.sh` | Generate video via API (queue-based) |

## Supported Models

<!-- TODO: Add detailed comparison with pricing -->

| Model | Type | Duration | Quality | API |
|-------|------|----------|---------|-----|
| Seedance 2.0 | T2V + I2V | up to 10s | ⭐⭐⭐⭐⭐ | ByteDance / fal.ai |
| Seedance 1.5 Pro | I2V | up to 5s | ⭐⭐⭐⭐ | fal.ai |
| Kling 2.6 Pro | I2V | up to 10s | ⭐⭐⭐⭐⭐ | fal.ai |
| Sora 2 | T2V | up to 20s | ⭐⭐⭐⭐ | OpenAI |
| Veo 3.1 | T2V | up to 8s | ⭐⭐⭐⭐ | fal.ai |

## Generation Workflow

<!-- TODO: Implement generation workflow -->

### Text-to-Video
1. Take prompt from storyboard generation_prompt field
2. Select model based on requirements (quality/speed/cost)
3. Submit to queue, poll for completion
4. Download and save with shot ID

### Image-to-Video
1. Take keyframe image from seedance-image output
2. Add motion prompt from storyboard
3. Submit to queue with reference image
4. Validate output matches intended motion

### First-Last Frame
1. Use keyframes from consecutive shots as start/end frames
2. Generate transition video between frames
3. Ensure smooth motion continuity

## Prompt Engineering

<!-- TODO: Detail SCELA framework -->
<!-- TODO: Add prompt templates per shot type -->

### SCELA Framework
- **S**ubject — Who/what is in the frame
- **C**amera — Shot type and movement
- **E**nvironment — Setting and lighting
- **L**ook — Visual style and mood
- **A**ction — What happens in the clip

## Error Handling

<!-- TODO: Define retry and fallback logic -->

- Rate limit (429) → wait 30s, retry up to 3 times
- Generation failed → simplify prompt, retry
- Quality too low → try different model or adjust parameters
