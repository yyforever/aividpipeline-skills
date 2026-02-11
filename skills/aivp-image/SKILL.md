---
name: aivp-image
description: Generate keyframe images and character reference sheets for AI video production. Use when the user requests "Generate keyframe", "Create reference image", "Character sheet", "Scene image", or similar image generation tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: image, ai-image, keyframe, character-sheet, text-to-image, consistency
---

# AIVP Image — Keyframe & Reference Image Generation

Generate consistent keyframe images for video production: character reference sheets, scene keyframes, and style frames using AI image models.

## Scripts

| Script | Purpose |
|--------|---------|
| `generate.sh` | Generate images (queue-based, same as aivp-video) |
| `upload.sh` | Upload local files to provider CDN |
| `edit.sh` | Edit existing images (style transfer, inpainting) |

## Generate Images

```bash
bash scripts/generate.sh [options]
```

### Keyframe Generation

```bash
# Single keyframe
bash scripts/generate.sh \
  --prompt "A woman in a red dress standing on a cliff overlooking the ocean, golden hour, cinematic" \
  --model "fal-ai/nano-banana-pro" \
  --size landscape

# Character reference (multiple angles)
bash scripts/generate.sh \
  --prompt "Character sheet: young male explorer, brown jacket, multiple angles, white background" \
  --model "fal-ai/flux-2-turbo" \
  --size square \
  --num-images 4
```

### Style Frame

```bash
# Establish visual style for the project
bash scripts/generate.sh \
  --prompt "Cyberpunk city at night, neon lights, rain-slicked streets, cinematic color grading" \
  --model "fal-ai/nano-banana-pro" \
  --size landscape
```

### Image Editing

```bash
# Style transfer
bash scripts/edit.sh \
  --image-url "https://example.com/photo.jpg" \
  --prompt "Convert to anime style" \
  --model "fal-ai/flux/dev/image-to-image"

# Remove background
bash scripts/edit.sh \
  --image-url "https://example.com/character.jpg" \
  --prompt "Remove background, white background" \
  --model "fal-ai/bria/fibo-edit"
```

## Arguments Reference

| Argument | Description | Default |
|----------|-------------|---------|
| `--prompt`, `-p` | Text description | (required) |
| `--model`, `-m` | Model ID | `fal-ai/nano-banana-pro` |
| `--image-url` | Input image for I2I / editing | - |
| `--file`, `--image` | Local file (auto-uploads) | - |
| `--size` | `square`, `portrait`, `landscape` | `landscape` |
| `--num-images` | Number of images to generate | 1 |
| `--seed` | Random seed for reproducibility | - |
| `--output`, `-o` | Save to local path | - |

## Recommended Models

### Text-to-Image

| Model | Speed | Quality | Notes |
|-------|:-----:|:-------:|-------|
| `fal-ai/nano-banana-pro` | ⚡⚡⚡ | ★★★★★ | **Default** — best overall |
| `fal-ai/flux-2-turbo` | ⚡⚡ | ★★★★ | Open source, high quality |
| `fal-ai/flux/dev` | ⚡⚡ | ★★★★ | Good balance |
| `fal-ai/flux/schnell` | ⚡⚡⚡ | ★★★ | ~1 second, for previews |
| `fal-ai/ideogram/v3` | ⚡⚡ | ★★★★ | Best for text in images |

### Image Editing

| Model | Best For |
|-------|----------|
| `fal-ai/nano-banana-pro` | General editing |
| `fal-ai/flux-kontext` | Background change, context-aware |
| `fal-ai/flux/dev/image-to-image` | Style transfer |
| `fal-ai/bria/fibo-edit` | Object removal |
| `fal-ai/flux/dev/inpainting` | Masked inpainting |

### Upscaling

| Model | Scale | Notes |
|-------|:-----:|-------|
| `fal-ai/aura-sr` | 4x | Fast, general |
| `fal-ai/clarity-upscaler` | 2-4x | Detail preservation |

## Visual Consistency Strategy

For video production, visual consistency across frames is critical:

1. **Character Reference Sheet** — Generate once, use as reference for all scenes
2. **Style Frame** — Establish color palette and visual style early
3. **Seed Locking** — Use `--seed` to reproduce similar compositions
4. **IP-Adapter / ControlNet** — Use image-to-image with reference for consistency
5. **Same Model** — Stick to one model throughout a project

### Recommended Workflow

```
1. Generate character sheet (aivp-image)
2. Generate style frame (aivp-image)
3. Generate scene keyframes using character + style as reference (aivp-image)
4. Animate keyframes to video clips (aivp-video, image-to-video)
```

## Integration with AIVP Pipeline

```
aivp-storyboard (shot list) → aivp-image (keyframes) → aivp-video (animate)
```

### Project Directory Convention

```
project/
├── references/
│   ├── character_main.png     ← character reference sheet
│   └── style_frame.png        ← visual style reference
├── keyframes/
│   ├── scene_01.png           ← generated keyframes
│   ├── scene_02.png
│   └── ...
└── metadata/
    ├── scene_01.json          ← generation params + seed
    └── scene_02.json
```

## Output

```json
{
  "images": [
    { "url": "https://v3.fal.media/files/.../image.png", "width": 1024, "height": 768 }
  ]
}
```

## Troubleshooting

### Inconsistent Characters
Use character reference sheet as image input for I2I models. Keep the same seed and similar prompts.

### Text in Images
Use `fal-ai/ideogram/v3` — specifically designed for text rendering.

### Low Resolution
Generate at base resolution, then upscale with `fal-ai/aura-sr` or `fal-ai/clarity-upscaler`.
