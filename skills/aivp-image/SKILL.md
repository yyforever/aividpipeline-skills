---
name: aivp-image
description: >
  Generate keyframe images and character reference sheets for AI video production.
  Use when user requests "generate keyframe", "character reference", "reference image",
  "character sheet", "scene image", "background art", "concept art",
  or needs consistent character/scene images as input for video generation.
  Supports multiple image models (Seedream, FLUX, Midjourney) and
  character consistency techniques (reference images, LoRA, prompt anchoring).
---

# AIVidPipeline Image

Generate keyframe images and character references for AI video production.

<!-- TODO: Implement all sections below -->

## References

- [Image Models](references/models.md) — Model comparison and selection guide
- [Character Consistency](references/character.md) — Techniques for maintaining character appearance across shots

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/generate.sh` | Generate images via API (Seedream/FLUX/fal.ai) |

## Workflow

### Keyframe Generation

<!-- TODO: Implement keyframe generation from storyboard -->

1. Read shot list from storyboard output
2. For each shot, generate keyframe image matching visual description
3. Apply character consistency constraints (reference images, style anchors)
4. Output keyframe images with shot ID mapping

### Character Reference Sheet

<!-- TODO: Implement character sheet generation -->

1. Generate character in multiple poses/angles from description
2. Validate consistency across poses
3. Output reference sheet for use in video generation

## Character Consistency Methods

<!-- TODO: Detail each method with examples -->

1. **Reference Image Anchoring** — Feed previous keyframes as reference
2. **Prompt Anchoring** — Consistent character description prefix across all prompts
3. **LoRA/IP-Adapter** — Fine-tuned model for specific characters
4. **Multi-shot Validation** — Generate multiple candidates, pick most consistent via VLM

## Supported Models

<!-- TODO: Add pricing and quality comparison -->

| Model | Best For | API |
|-------|----------|-----|
| Seedream 4.0 | General keyframes | ByteDance |
| FLUX | Open source, fast | fal.ai |
| Nano Banana Pro | T2I + editing | fal.ai |
| Ideogram v3 | Text in images | fal.ai |
