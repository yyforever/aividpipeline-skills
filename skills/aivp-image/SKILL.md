---
name: aivp-image
description: Generate keyframe images for video production — character portraits, scene keyframes, and style frames via OpenRouter API. Activate on "generate keyframe", "create image", "character portrait", "scene image", "generate frames", or any image generation request in the video pipeline.
metadata:
  author: aividpipeline
  version: "0.3.0"
  tags: image, keyframe, openrouter, text-to-image, image-to-image, character-consistency
---

# AIVP Image — Keyframe Generation for Video Pipeline

Generate keyframe images that feed into aivp-video. Supports two modes:

1. **Pipeline mode** — read storyboard's frame-plan, generate all keyframes in Camera Tree order
2. **Standalone mode** — generate individual images from a text prompt

Default API: **OpenRouter** (`https://openrouter.ai/api/v1`). Model passed as parameter — not hardcoded.

## Core Process

```
Read storyboard outputs (frame-plan.md + shots/*.md)
     ↓
 For each frame in generation order:
     ├─ Build prompt (from shot spec + character/scene refs)
     ├─ Call generate.sh (OpenRouter API)
     ├─ Save image to image/frames/
     ├─ Log metadata to image/log/
     └─ Update preview.md placeholder → real image path
     ↓
 All frames generated → quality review → done
```

## Workflow

### Setup

1. **Locate API key** — Check these in order:
   - `OPENROUTER_API_KEY` environment variable
   - `.env` file in project root, `~/.env`, or `~/.aivp/.env`
2. **Read storyboard outputs** (pipeline mode):
   - `storyboard/storyboard-final/frame-plan.md` — generation order + reference image list
   - `storyboard/storyboard-final/shots/shot-{NN}.md` — per-shot specs (prompt, resolution, references)
   - `script/characters/*.md` — character portrait descriptions (text)
   - `script/scenes/*.md` — scene background descriptions
3. **Create `image/plan.md`** — track generation progress

### Step 1: Generate Character Portraits (Priority 0)

**Before any scene keyframes**, generate character reference images. These are the visual anchors for the entire video — all subsequent frames reference them for consistency.

For each character in `script/characters/*.md`:

1. **Three-view sheet** — front / side (3/4) / back in one image:
   ```bash
   bash scripts/generate.sh \
     --prompt "Character turnaround sheet, three views (front, 3/4 side, back) of [character description from character sheet]. White background, full body, consistent lighting, reference sheet style" \
     --model "black-forest-labs/flux.2-pro" \
     --output image/characters/{name}-turnaround.png
   ```

2. **Individual portraits** (for frame-plan references):
   - Front portrait → `image/characters/{name}-front.png`
   - Side (3/4) portrait → `image/characters/{name}-side.png`
   - Back portrait → `image/characters/{name}-back.png`

Use the turnaround sheet as reference for individual portraits to ensure consistency:
```bash
bash scripts/generate.sh \
  --prompt "Front portrait of [character description], head and shoulders, studio lighting" \
  --model "google/gemini-2.5-flash-image" \
  --reference image/characters/{name}-turnaround.png \
  --output image/characters/{name}-front.png
```

Save metadata to `image/log/character-{name}.json`.

### Step 2: Plan Scene Generation Queue

From `frame-plan.md`, build the ordered queue:

1. **Priority 1: Root cameras** — establishing shots (T2I, use character portraits + scene descriptions as reference)
2. **Priority 2: Child cameras** — medium/close shots derived from parent frames (I2I)
3. **Priority 3: Last frames** — for medium/large variation shots only

For each frame, note:
- Generation mode: T2I or I2I
- Model choice (user specifies or use default)
- Character portraits to reference (from Step 1)
- Target resolution

### Step 3: Generate Scene Keyframes

For each frame in the queue, call `scripts/generate.sh`:

```bash
# Root camera establishing shot (T2I, reference character portraits)
bash scripts/generate.sh \
  --prompt "Wide shot of a sunlit kitchen..." \
  --model "black-forest-labs/flux.2-pro" \
  --output image/frames/shot-01-ff.png

# Child camera (I2I, refine from parent frame)
bash scripts/generate.sh \
  --prompt "Medium shot, same kitchen, focus on woman at counter..." \
  --model "google/gemini-2.5-flash-image" \
  --reference image/frames/shot-01-ff.png \
  --output image/frames/shot-02-ff.png
```

After each generation:
- Verify image was saved successfully
- Log metadata to `image/log/shot-{NN}-ff.json` (model, cost, prompt, seed)
- Update `image/plan.md` with status

### Step 4: Quality Review

After all frames are generated:
1. Check character consistency — compare each frame's characters against turnaround sheet
2. Check scene consistency — same location should look the same across shots
3. Check visual continuity — parent/child camera shots should be spatially coherent
4. Flag any frames that need regeneration

### Step 5: Update Preview

Replace `[🖼️ 待生成]` placeholders in `storyboard/storyboard-final/preview.md` with actual image paths.

> **Note:** This is a cross-directory write (image writing to storyboard's preview.md). This is an intentional exception to the "write only to own directory" rule — storyboard's Integration section acknowledges this update.

## Script Reference

### generate.sh

```bash
bash scripts/generate.sh [options]
```

| Argument | Description | Default |
|----------|-------------|---------|
| `--prompt`, `-p` | Image description | (required) |
| `--model`, `-m` | OpenRouter model ID | (required) |
| `--reference`, `-r` | Reference image path (for I2I / multi-modal) | — |
| `--output`, `-o` | Save image to this path | `./output.png` |
| `--modalities` | `image` (pure image models) or `image,text` (multi-modal) | auto-detect |
| `--size` | `square` / `portrait` / `landscape` | `landscape` |
| `--width` | Explicit width in pixels | — |
| `--height` | Explicit height in pixels | — |
| `--seed` | Reproducibility seed | — |

### Model ID examples (not exhaustive — models change frequently)

```bash
# Pure image models (modalities=image)
--model "black-forest-labs/flux.2-pro"
--model "black-forest-labs/flux.2-flex"

# Multi-modal models (modalities=image,text)
--model "google/gemini-2.5-flash-image"
--model "google/gemini-3-pro-image-preview"
--model "openai/gpt-5-image-mini"
```

> ⚠️ Models and pricing change frequently. Do NOT hardcode model choices.
> Check https://openrouter.ai/models for current availability.

### Environment

The script reads `OPENROUTER_API_KEY` from environment or `.env` files. To set:

```bash
# Option 1: Environment variable
export OPENROUTER_API_KEY="sk-or-v1-..."

# Option 2: .env file (project root or ~/.env or ~/.aivp/.env)
echo "OPENROUTER_API_KEY=sk-or-v1-..." >> .env
```

## Project Output Structure

```
project/image/
├── plan.md                    ← Track generation progress
├── characters/                ← Character reference images (generated first)
│   ├── elena-turnaround.png   ← Three-view sheet (front + side + back)
│   ├── elena-front.png        ← Individual front portrait
│   ├── elena-side.png         ← Individual 3/4 side portrait
│   ├── elena-back.png         ← Individual back portrait
│   └── marco-turnaround.png
├── frames/                    ← Scene keyframe images
│   ├── shot-01-ff.png         ← Shot 1 first-frame
│   ├── shot-01-lf.png         ← Shot 1 last-frame (if medium/large)
│   ├── shot-02-ff.png
│   └── ...
└── log/                       ← Generation metadata
    ├── character-elena.json   ← Character portrait generation log
    ├── shot-01-ff.json        ← Per-frame: model, cost, prompt, timestamp
    └── ...
```

## References

- **OpenRouter Image API** → `references/openrouter-image-api.md` — API format, modalities parameter, response parsing, base64 handling
- **Generation log template** → `assets/generation-log-template.md` — Per-image metadata format

## Integration

- **Input from:** `aivp-storyboard` →
  - `storyboard/storyboard-final/frame-plan.md` — generation order + reference image list
  - `storyboard/storyboard-final/shots/*.md` — per-shot image prompts + resolution
  - `storyboard/storyboard-final/preview.md` — to update with generated image paths (cross-directory write)
- **Input from:** `aivp-script` →
  - `script/characters/*.md` — character visual descriptions (for generating turnaround sheets + portraits)
  - `script/scenes/*.md` — scene background descriptions
- **Output to:**
  - `aivp-video` → `image/characters/*.png` (character portraits for reference) + `image/frames/*.png` (keyframes as video input)
  - `aivp-storyboard` → updates `preview.md` image placeholders (cross-directory exception)

### Project Directory Convention

```
project/
├── ideation/          ← aivp-ideation owns
├── script/            ← aivp-script owns
├── storyboard/        ← aivp-storyboard owns
├── image/             ← aivp-image owns (this skill)
├── video/             ← aivp-video (next)
└── audio/             ← aivp-audio (next)
```

Each skill reads from upstream sibling directories and writes only to its own — except image updates storyboard's `preview.md` (acknowledged by both skills).

### Standalone Mode

When used outside the pipeline (no storyboard):

```bash
# Just generate an image
bash scripts/generate.sh \
  --prompt "A young woman in a red dress on a cliff, golden hour, cinematic" \
  --model "black-forest-labs/flux.2-pro" \
  --output my-image.png
```

The script works independently — no storyboard required.
