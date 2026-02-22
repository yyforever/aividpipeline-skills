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

| Model | Speed | Quality | Pricing (参考) | Notes |
|-------|:-----:|:-------:|:-------------:|-------|
| `fal-ai/nano-banana-pro` | ⚡⚡⚡ | ★★★★★ | $0.15/image | **Default** — best overall, T2I + editing |
| `fal-ai/flux-2-turbo` | ⚡⚡⚡ | ★★★★ | ~$0.008/MP | Open source, cheapest quality option |
| `fal-ai/flux/dev` | ⚡⚡ | ★★★★ | $0.025/MP | Good balance, LoRA support |
| `fal-ai/flux/schnell` | ⚡⚡⚡ | ★★★ | ~$0.003/MP | ~1 second, for previews |
| `fal-ai/ideogram/v3` | ⚡⚡ | ★★★★ | $0.03-0.09/image | **Best text rendering** |
| `fal-ai/bytedance/seedream/v4.5` | ⚡⚡ | ★★★★★ | $0.04/image | Cinema-grade, up to 4MP |

### Image Editing

| Model | Best For | Pricing (参考) |
|-------|----------|:-------------:|
| `fal-ai/nano-banana-pro/edit` | General editing | $0.15/image |
| `fal-ai/flux-kontext` | Background change, context-aware | $0.04/MP |
| `fal-ai/flux/dev/image-to-image` | Style transfer | $0.025/MP |
| `fal-ai/bria/fibo-edit` | Object removal | ~$0.02/image |
| `fal-ai/flux/dev/inpainting` | Masked inpainting | $0.025/MP |

### Upscaling

| Model | Scale | Pricing (参考) | Notes |
|-------|:-----:|:-------------:|-------|
| `fal-ai/aura-sr` | 4x | ~$0.01/MP | Fast, general |
| `fal-ai/clarity-upscaler` | 2-4x | ~$0.001/s compute | Detail preservation |

---

## Detailed Model Documentation

### 🖼️ Nano Banana Pro (Default)

**Model IDs:**
- T2I: `fal-ai/nano-banana-pro`
- Edit: `fal-ai/nano-banana-pro/edit`

**Core Features:** Google's state-of-the-art model, text-to-image + editing in one model, advanced text rendering, character consistency, up to 2048×2048

#### Parameter Reference — T2I

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Image description |
| `image_size` | string/object | No | `"landscape_16_9"` | Preset or `{width, height}` (see below) |
| `num_images` | integer | No | `1` | `1` – `4` |
| `seed` | integer | No | random | Reproducibility seed |
| `safety_tolerance` | string | No | `"2"` | `1` (strict) – `6` (relaxed) |

**Size Presets:** `square_hd` (1024×1024), `square` (512×512), `portrait_4_3` (768×1024), `portrait_16_9` (576×1024), `landscape_4_3` (1024×768), `landscape_16_9` (1024×576)

#### Parameter Reference — Edit

| Parameter | Type | Required | Default | Description |
|-----------|------|:--------:|---------|-------------|
| `prompt` | string | **Yes** | — | Edit instruction in natural language |
| `image_url` | string | **Yes** | — | Source image URL |
| `image_size` | string/object | No | auto | Output size |
| `num_images` | integer | No | `1` | `1` – `4` |

#### Pricing (参考价格)

| Action | Price |
|--------|:-----:|
| Text-to-Image | $0.15 / image |
| Image Edit | $0.15 / image |

> Flat per-image pricing regardless of resolution.

#### Input/Output Example

**Request (T2I):**
```json
{
  "prompt": "A woman in a red dress standing on a cliff overlooking the ocean, golden hour, cinematic lighting, photorealistic",
  "image_size": "landscape_16_9",
  "num_images": 1
}
```

**Request (Edit):**
```json
{
  "prompt": "Change the dress color to blue and add dramatic storm clouds in the background",
  "image_url": "https://example.com/original.jpg"
}
```

**Response:**
```json
{
  "images": [
    { "url": "https://v3.fal.media/files/.../image.png", "width": 1024, "height": 576 }
  ]
}
```

> ⚠️ **Tips:** Best all-around model. No mask needed for editing — just describe what to change. Supports multi-turn editing for iterative refinement.

---

### ⚡ FLUX 2 Turbo / Dev

**Model IDs:**
- Turbo: `fal-ai/flux-2-turbo` (cheapest high-quality)
- Dev: `fal-ai/flux/dev` (LoRA + fine-tuning support)
- Schnell: `fal-ai/flux/schnell` (fastest, previews)

**Core Features:** Open-source FLUX family, LoRA support (Dev), extremely fast generation (Turbo/Schnell)

#### Parameter Reference — FLUX 2 Turbo

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Image description |
| `image_size` | string/object | No | `"landscape_4_3"` | Preset or `{width, height}` |
| `num_inference_steps` | integer | No | `4` | `1` – `50` (Turbo optimized for 4) |
| `num_images` | integer | No | `1` | `1` – `4` |
| `seed` | integer | No | random | Reproducibility seed |
| `guidance_scale` | float | No | `3.5` | `0` – `20` (prompt adherence) |
| `enable_safety_checker` | boolean | No | `true` | Safety filter |

#### Parameter Reference — FLUX Dev (additional)

| Parameter | Type | Required | Default | Description |
|-----------|------|:--------:|---------|-------------|
| `loras` | array | No | — | LoRA models `[{path, scale}]` |
| `guidance_scale` | float | No | `3.5` | `0` – `20` |
| `num_inference_steps` | integer | No | `28` | `1` – `50` |

#### Pricing (参考价格)

| Model | Unit | Price | ~1024×1024 cost |
|-------|------|:-----:|:---------------:|
| FLUX 2 Turbo | per megapixel | $0.008 | ~$0.008 |
| FLUX Dev | per megapixel | $0.025 | ~$0.025 |
| FLUX Schnell | per megapixel | ~$0.003 | ~$0.003 |

> Megapixel = (width × height) / 1,000,000. A 1024×1024 image ≈ 1.05 MP.

#### Input/Output Example

**Request (Turbo):**
```json
{
  "prompt": "Character sheet: young male explorer, brown jacket, multiple angles, white background, detailed illustration",
  "image_size": "square_hd",
  "num_images": 4
}
```

> ⚠️ **Tips:** Use Turbo for bulk generation (8x cheaper than Nano Banana). Use Dev when you need LoRA fine-tuning. Schnell for instant previews during iteration.

---

### 📝 Ideogram v3 (Best Text Rendering)

**Model IDs:**
- T2I: `fal-ai/ideogram/v3`
- Edit: `fal-ai/ideogram/v3/edit`
- Remix: `fal-ai/ideogram/v3/remix`
- Reframe: `fal-ai/ideogram/v3/reframe`

**Core Features:** Industry-leading text rendering in images, multiple quality tiers, style control

#### Parameter Reference

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Description; include exact text in quotes |
| `quality` | string | No | `"balanced"` | `turbo` (fast) / `balanced` / `quality` (best) |
| `aspect_ratio` | string | No | `"1:1"` | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `10:16`, `16:10`, `3:2`, `2:3` |
| `style_type` | string | No | `"auto"` | `auto`, `general`, `realistic`, `design`, `render_3d`, `anime` |
| `negative_prompt` | string | No | — | What to avoid |
| `num_images` | integer | No | `1` | `1` – `4` |
| `seed` | integer | No | random | Reproducibility seed |

#### Pricing (参考价格)

| Quality Tier | Price per Image | Best For |
|:------------:|:---------------:|----------|
| `turbo` | $0.03 | Fast iteration |
| `balanced` | $0.06 | General use |
| `quality` | $0.09 | Final output |

#### Input/Output Example

**Request:**
```json
{
  "prompt": "A vintage coffee shop sign that reads \"MORNING BREW\" in elegant serif font, neon glow, rainy night, cinematic",
  "quality": "quality",
  "aspect_ratio": "16:9",
  "style_type": "realistic"
}
```

> ⚠️ **Tips:** Only model that reliably renders text in images. Use exact text in quotes. `quality` tier is worth the extra cost for text-heavy images. For logos and signage, use `style_type: "design"`.

---

### 🎬 Seedream 4.5 (Cinema-Grade)

**Model IDs:**
- T2I: `fal-ai/bytedance/seedream/v4.5/text-to-image`
- Edit: `fal-ai/bytedance/seedream/v4.5/edit`

**Core Features:** ByteDance's flagship image model, up to 4MP (2048×2048), unified T2I + editing, multi-reference support (up to 10 images)

#### Parameter Reference — T2I

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Detailed description |
| `image_size` | string/object | No | `"landscape_16_9"` | Preset or `{width, height}` up to 2048×2048 |
| `num_images` | integer | No | `1` | `1` – `4` |
| `seed` | integer | No | random | Reproducibility seed |

#### Parameter Reference — Edit (additional)

| Parameter | Type | Required | Default | Description |
|-----------|------|:--------:|---------|-------------|
| `image_url` | string | **Yes** | — | Source image URL |
| `reference_image_urls` | array | No | — | Up to 10 reference images for composition |

#### Pricing (参考价格)

| Action | Price |
|--------|:-----:|
| Text-to-Image | $0.04 / image |
| Image Edit | $0.04 / image |

> Cheapest premium model — 73% less than Nano Banana Pro at comparable quality.

#### Input/Output Example

**Request:**
```json
{
  "prompt": "Cinematic close-up portrait, woman with freckles looking through rain-streaked window, golden hour backlight, shallow depth of field, film grain",
  "image_size": {"width": 1920, "height": 1080},
  "num_images": 1
}
```

> ⚠️ **Tips:** Excellent for cinematic keyframes in video pipeline. At $0.04/image, ideal for generating many variations. Text rendering is decent but Ideogram v3 is better for precise text.

---

## Model Selection Decision Tree

```
              Need an image?
                    │
          ┌─────────┴─────────┐
          │                   │
    Text-to-Image        Image Editing
          │                   │
    ┌─────┴─────┐      ┌─────┴─────┐
    │           │      │           │
 Need text   General   Simple     Complex
 in image?   purpose   edit       composition
    │           │      │           │
 Ideogram    Quality   Nano       Seedream 4.5
 v3          vs Cost?  Banana     (multi-ref)
 ($0.03-0.09)    │     ($0.15)    ($0.04)
          ┌──┴──┐
          │     │
       Premium  Budget
          │     │
     Nano Banana  FLUX 2 Turbo
     ($0.15)      ($0.008/MP)
```

**Quick Decision:**
- 🏆 **Best overall** → `nano-banana-pro` ($0.15) — when quality matters most
- 💰 **Budget bulk** → `flux-2-turbo` ($0.008/MP) — ~$0.008 per 1024×1024
- 📝 **Text in images** → `ideogram/v3` ($0.03-0.09) — only reliable text renderer
- 🎬 **Cinematic keyframes** → `seedream/v4.5` ($0.04) — best value for quality
- ⚡ **Instant preview** → `flux/schnell` (~$0.003/MP) — sub-second generation
- 🎨 **Custom style (LoRA)** → `flux/dev` ($0.025/MP) — fine-tuning support
- 🔍 **Upscale** → `aura-sr` (4x) — fast, general purpose

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
