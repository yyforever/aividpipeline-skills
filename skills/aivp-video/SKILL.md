---
name: aivp-video
description: Generate AI video clips from text or images using multiple providers (fal.ai, Replicate, local). Use when the user requests "Generate video", "Text to video", "Image to video", "Animate this image", "Create a video clip", or similar video generation tasks.
metadata:
  author: aividpipeline
  version: "0.2.0"
  tags: video, ai-video, text-to-video, image-to-video, seedance, kling, sora
---

# AIVP Video — AI Video Clip Generation

Generate video clips using state-of-the-art AI models. Supports text-to-video, image-to-video, and video-to-video workflows with queue-based async execution.

Supports two modes:

1. **Pipeline mode** — read storyboard + image outputs and generate all shot clips in order
2. **Standalone mode** — generate a single clip from prompt or image

## Core Process

```
Read storyboard outputs (frame-plan.md + shots/*.md)
     ↓
Read image outputs (frames/*.png + characters/*.png)
     ↓
For each shot in generation order:
     ├─ Choose mode (I2V preferred, T2V fallback)
     ├─ Call generate.sh (queue submit + poll)
     ├─ Save clip to video/clips/
     ├─ Log metadata to video/log/
     └─ Update video/plan.md status
     ↓
All clips generated → quality review → handoff to edit/lipsync
```

## Workflow

### Setup

1. **Locate API key** — Check these in order:
   - `FAL_KEY` environment variable
   - `.env` file in project root, `~/.env`, or `~/.aivp/.env`
2. **Read upstream outputs** (pipeline mode):
   - `storyboard/storyboard-final/frame-plan.md` — shot order + generation notes
   - `storyboard/storyboard-final/shots/shot-{NN}.md` — per-shot prompt, duration, camera, resolution
   - `image/frames/*.png` — keyframe inputs for I2V mode
   - `image/characters/*.png` — character reference anchors
   - `script/characters/*.md` and `script/scenes/*.md` — character/scene context for prompt refinement
3. **Create `video/plan.md`** — track generation progress with this table format:

| # | Type | File | Model | Mode | Status |
|---|------|------|-------|------|--------|
| 1 | shot-01 | `video/clips/shot-01.mp4` | `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` | I2V | queued |
| 2 | shot-02 | `video/clips/shot-02.mp4` | `fal-ai/bytedance/seedance/v1.5/pro/text-to-video` | T2V | pending |

### Step 1: Build Shot Queue

From `frame-plan.md` + `shots/*.md`, create an ordered queue (`shot-01`, `shot-02`, ...).

For each shot:
- Determine keyframe availability: check `image/frames/shot-{NN}-ff.png` (and `shot-{NN}-lf.png` if needed)
- Pull character refs from `image/characters/*.png` for identity consistency
- Resolve model + mode using pipeline strategy:
  - If keyframe exists in `image/frames/` → use **I2V** (preferred, more consistent)
  - If no keyframe exists → fallback to **T2V**
  - Default pipeline model: `fal-ai/bytedance/seedance/v1.5/pro` (best value, native audio)
  - Hero shots / final render: upgrade to `fal-ai/kling-video/v2.6/pro/*` or `fal-ai/veo3.1`

### Step 2: Generate Clips in Order

Run generation shot-by-shot in queue order:

```bash
# I2V preferred when keyframe exists
bash scripts/generate.sh \
  --prompt "Shot 01 action/camera/sound..." \
  --model "fal-ai/bytedance/seedance/v1.5/pro/image-to-video" \
  --file "image/frames/shot-01-ff.png" \
  --output "video/clips/shot-01.mp4"

# T2V fallback when no keyframe exists
bash scripts/generate.sh \
  --prompt "Shot 02 action/camera/sound..." \
  --model "fal-ai/bytedance/seedance/v1.5/pro/text-to-video" \
  --output "video/clips/shot-02.mp4"
```

After each shot:
- Verify clip saved to `video/clips/shot-{NN}.mp4`
- Save request/result metadata to `video/log/shot-{NN}.json`
- Update `video/plan.md` status (`pending` → `queued` → `done` / `failed`)

### Step 3: Log Metadata

Use one JSON log per clip (`video/log/shot-{NN}.json`) in this shared pipeline format:

```json
{
  "id": "shot-01",
  "type": "clip",
  "file": "video/clips/shot-01.mp4",
  "model": "fal-ai/bytedance/seedance/v1.5/pro/image-to-video",
  "mode": "I2V",
  "status": "completed",
  "request_id": "abc123-def456",
  "prompt": "Camera pushes in as Elena turns to Marco and says \"We have one chance.\"",
  "seed": 42,
  "duration": "5",
  "aspect_ratio": "16:9",
  "input_image": "image/frames/shot-01-ff.png",
  "character_refs": [
    "image/characters/elena-front.png",
    "image/characters/marco-front.png"
  ],
  "video_url": "https://v3.fal.media/files/.../shot-01.mp4",
  "cost_usd": 0.26,
  "timestamp": "2026-02-27T12:00:00Z"
}
```

### Step 4: Quality Review

After all clips are generated:
1. Check character consistency against `image/characters/*.png`
2. Check shot continuity against `storyboard/storyboard-final/shots/*.md`
3. Check motion/camera intent matches shot specs
4. Check audio quality and dialogue clarity (when audio enabled)
5. Mark failed clips in `video/plan.md` and regenerate only failed shots

### Step 5: Handoff

- For assembly: pass completed clips in `video/clips/` to `aivp-edit`
- For talking-shot enhancement: pass selected clips to `aivp-lipsync`

## Scripts

| Script | Purpose |
|--------|---------|
| `generate.sh` | Generate video clips (queue-based) |
| `upload.sh` | Upload local files to provider CDN |
| `search-models.sh` | Search and discover available models |
| `get-schema.sh` | Get OpenAPI schema for any model |

## Queue System (Default)

Video generation is slow (10s–5min). All requests use queue mode by default:

```
User Request → Queue Submit → Poll Status → Get Result
                   ↓
              request_id
```

## Generate Video

```bash
bash scripts/generate.sh [options]
```

### Text-to-Video

```bash
# Default model (Seedance 1.5 Pro)
bash scripts/generate.sh --prompt "A cat walking on the beach at sunset"

# Specify model
bash scripts/generate.sh \
  --prompt "Ocean waves crashing on rocks, cinematic" \
  --model "fal-ai/veo3.1"

# With aspect ratio
bash scripts/generate.sh \
  --prompt "A chef preparing sushi, close-up" \
  --model "fal-ai/kling-video/v2.5-turbo/pro" \
  --aspect-ratio "16:9"
```

### Image-to-Video

```bash
# Animate an image
bash scripts/generate.sh \
  --prompt "Camera slowly zooms in, hair blowing in wind" \
  --model "fal-ai/kling-video/v2.6/pro/image-to-video" \
  --image-url "https://example.com/portrait.jpg"

# Local file (auto-uploads)
bash scripts/generate.sh \
  --prompt "The character turns and smiles" \
  --model "fal-ai/bytedance/seedance/v1.5/pro/image-to-video" \
  --file "./image/frames/shot-01-ff.png"
```

### Async Mode (Long Jobs)

```bash
# Submit and return immediately
bash scripts/generate.sh \
  --prompt "Epic battle scene" \
  --model "fal-ai/veo3.1" \
  --async

# Check status later
bash scripts/generate.sh --status "abc123" --model "fal-ai/veo3.1"

# Get result when done
bash scripts/generate.sh --result "abc123" --model "fal-ai/veo3.1"
```

## Arguments Reference

| Argument | Description | Default |
|----------|-------------|---------|
| `--prompt`, `-p` | Text description | (required) |
| `--model`, `-m` | Model ID | `fal-ai/bytedance/seedance/v1.5/pro` |
| `--image-url` | Input image URL for I2V | - |
| `--file`, `--image` | Local file (auto-uploads) | - |
| `--aspect-ratio` | `16:9`, `9:16`, `1:1` | `16:9` |
| `--duration` | Target duration in seconds | model default |
| `--seed` | Random seed for reproducibility | - |

**Mode Options:**

| Argument | Description |
|----------|-------------|
| (default) | Queue mode — submit and poll until complete |
| `--async` | Submit to queue, return request_id immediately |
| `--sync` | Synchronous (not recommended) |
| `--logs` | Show generation logs while polling |

**Queue Operations:**

| Argument | Description |
|----------|-------------|
| `--status ID` | Check status of a queued request |
| `--result ID` | Get result of a completed request |
| `--cancel ID` | Cancel a queued request |

**Advanced:**

| Argument | Description | Default |
|----------|-------------|---------|
| `--poll-interval` | Seconds between status checks | 3 |
| `--timeout` | Max seconds to wait | 600 |
| `--provider` | `fal`, `replicate`, `local` | `fal` |
| `--output`, `-o` | Save video to local path | - |
| `--schema [MODEL]` | Get OpenAPI schema | - |

## Recommended Models

### Text-to-Video

| Model | Speed | Quality | Pricing (参考) | Notes |
|-------|:-----:|:-------:|:-------------:|-------|
| `fal-ai/bytedance/seedance/v1.5/pro` | ⚡⚡ | ★★★★ | ~$0.05/s (720p+audio) | **Default** — native audio, lip-sync |
| `fal-ai/veo3.1` | ⚡ | ★★★★★ | $0.20-0.40/s | Highest quality, 4K support |
| `fal-ai/sora-2/text-to-video/pro` | ⚡ | ★★★★★ | $0.30-0.50/s | Up to 25s, native audio |
| `fal-ai/kling-video/v2.5-turbo/pro` | ⚡⚡⚡ | ★★★ | ~$0.07/s | Fastest generation |
| `fal-ai/minimax/hailuo-02/pro` | ⚡⚡ | ★★★★ | $0.08/s (1080p) | Best physics, director camera |
| `fal-ai/bytedance/seedance/v1/pro` | ⚡⚡ | ★★★ | ~$0.02/s (720p) | Budget option |

### Image-to-Video

| Model | Speed | Quality | Pricing (参考) | Notes |
|-------|:-----:|:-------:|:-------------:|-------|
| `fal-ai/kling-video/v2.6/pro/image-to-video` | ⚡⚡ | ★★★★★ | $0.07-0.14/s | **Best I2V** — native audio |
| `fal-ai/veo3.1/fast/image-to-video` | ⚡⚡⚡ | ★★★★ | ~$0.10/s | Fast, high quality |
| `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` | ⚡⚡ | ★★★★ | ~$0.05/s (720p+audio) | Start+end frame, lip-sync |
| `fal-ai/minimax/hailuo-02/standard/image-to-video` | ⚡⚡ | ★★★ | ~$0.017/s (512p) | Budget I2V |

### Video-to-Video (Style Transfer)

| Model | Notes |
|-------|-------|
| `fal-ai/kling-video/v2.6/pro/video-to-video` | Style transfer, motion retargeting — $0.112/s |

---

## Detailed Model Documentation

### 🎬 Seedance v1.5 Pro (Default)

**Model IDs:**
- T2V: `fal-ai/bytedance/seedance/v1.5/pro/text-to-video`
- I2V: `fal-ai/bytedance/seedance/v1.5/pro/image-to-video`

**Core Features:** Native audio generation (dialogue + SFX + BGM), lip-sync, cinematic camera, start+end frame control (I2V)

#### Parameter Reference — T2V

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Describe scene, action, dialogue (in quotes), camera, sound |
| `aspect_ratio` | string | No | `"16:9"` | `21:9`, `16:9`, `4:3`, `1:1`, `3:4`, `9:16` |
| `resolution` | string | No | `"720p"` | `480p` (fast) / `720p` (balanced) / `1080p` (highest, T2V only) |
| `duration` | string | No | `"5"` | `4` – `12` seconds |
| `generate_audio` | boolean | No | `true` | `true` / `false` — false 时价格减半 |
| `camera_fixed` | boolean | No | `false` | `true` = tripod mode |
| `seed` | integer | No | random | `-1` for random, or specific integer |

#### Parameter Reference — I2V (additional)

| Parameter | Type | Required | Default | Description |
|-----------|------|:--------:|---------|-------------|
| `image_url` | string | **Yes** | — | Start frame image URL |
| `end_image_url` | string | No | — | End frame image URL (generates motion between frames) |

*I2V max resolution is 720p; T2V supports up to 1080p.*

#### Resolution / Duration / Pricing Matrix (参考价格)

**T2V (Text-to-Video):**

| Resolution | With Audio | Without Audio | 5s cost (audio) | 10s cost (audio) |
|:----------:|:----------:|:-------------:|:---------------:|:----------------:|
| 480p | ~$0.024/s | ~$0.012/s | ~$0.12 | ~$0.24 |
| 720p | ~$0.052/s | ~$0.026/s | ~$0.26 | ~$0.52 |
| 1080p | ~$0.115/s | ~$0.058/s | ~$0.58 | ~$1.15 |

> Token-based pricing: 1M video tokens = $2.4 (audio) / $1.2 (no audio). tokens = height × width × FPS × duration / 1024

**I2V (Image-to-Video):** Similar token-based pricing, 720p max.

#### Input/Output Example

**Request (T2V):**
```json
{
  "prompt": "Defense attorney declaring \"Ladies and gentlemen, reasonable doubt isn't just a phrase, it's the foundation of justice itself\", footsteps on marble, jury shifting, courtroom drama, closing argument power.",
  "aspect_ratio": "16:9",
  "resolution": "720p",
  "duration": "5",
  "generate_audio": true
}
```

**Request (I2V):**
```json
{
  "prompt": "Camera slowly zooms in, hair blowing in wind, she says \"I've been waiting for this\"",
  "image_url": "https://example.com/portrait.jpg",
  "end_image_url": "https://example.com/portrait_end.jpg",
  "resolution": "720p",
  "duration": "5",
  "generate_audio": true
}
```

**Response:**
```json
{
  "video": {
    "url": "https://v3.fal.media/files/.../video.mp4",
    "content_type": "video/mp4"
  }
}
```

#### Prompt Tips (Seedance Specific)

| Element | Example |
|---------|---------|
| **Scene** | `"Rainy Tokyo alley at night, neon reflections on wet pavement"` |
| **Action** | `"A woman in a trench coat turns and walks toward camera"` |
| **Dialogue** | `"I told you — we don't have much time."` (用引号包裹) |
| **Camera** | `"Slow dolly-in ending on a close-up"` |
| **Sound/Foley** | `"Rain on metal, distant traffic, her heels on concrete"` |

> ⚠️ **Common Pitfalls:**
> - Dialogue must be in quotes; describe emotion: `"I can't believe it," voice breaking with emotion`
> - Keep 1-2 characters per clip for best coherence
> - `camera_fixed: true` for stable shots; describe camera movement in prompt otherwise

---

### 🎥 Kling v2.6 Pro (Best I2V)

**Model IDs:**
- T2V: `fal-ai/kling-video/v2.6/pro/text-to-video`
- I2V: `fal-ai/kling-video/v2.6/pro/image-to-video`
- V2V: `fal-ai/kling-video/v2.6/pro/video-to-video`

**Core Features:** Cinematic motion, native audio + voice control, Chinese/English speech, auto-translation

#### Parameter Reference — I2V

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Scene/action description; embed dialogue in quotes |
| `image_url` | string | **Yes** | — | Start frame (jpg/jpeg/png/webp/gif/avif) |
| `end_image_url` | string | No | — | End frame image |
| `duration` | string | No | `"5"` | `5` or `10` seconds |
| `aspect_ratio` | string | No | `"16:9"` | `16:9`, `9:16`, `1:1` |
| `generate_audio` | boolean | No | `false` | Enable native audio generation |
| `voice_ids` | array | No | — | Voice IDs for voice control |
| `negative_prompt` | string | No | — | What to avoid |
| `seed` | integer | No | random | Reproducibility seed |
| `cfg_scale` | float | No | — | Prompt adherence strength |

#### Pricing (参考价格)

| Mode | Per Second | 5s Cost | 10s Cost |
|------|:----------:|:-------:|:--------:|
| No audio | $0.07 | $0.35 | $0.70 |
| With audio | $0.14 | $0.70 | $1.40 |
| Audio + voice control | $0.168 | $0.84 | $1.68 |

#### Input/Output Example

**Request (I2V with audio):**
```json
{
  "prompt": "A king walks slowly and says \"My people, here I am! I am here to save you all\"",
  "image_url": "https://example.com/king_portrait.jpg",
  "duration": "5",
  "generate_audio": true
}
```

**Response:**
```json
{
  "video": {
    "url": "https://v3.fal.media/files/.../output.mp4",
    "content_type": "video/mp4"
  }
}
```

> ⚠️ **Tips:** Use UPPERCASE for acronyms/proper nouns in English dialogue for correct pronunciation. Chinese and English are natively supported; other languages auto-translate.

---

### 🌟 Veo 3.1 (Highest Quality)

**Model IDs:**
- T2V: `fal-ai/veo3.1`
- I2V: `fal-ai/veo3.1/fast/image-to-video`
- First+Last Frame: `fal-ai/veo3.1/first-last-frame-to-video`

**Core Features:** Google's flagship model, highest visual quality, 4K support, native audio

#### Parameter Reference — T2V

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Detailed scene description |
| `aspect_ratio` | string | No | `"16:9"` | `16:9`, `9:16` |
| `duration` | string | No | `"8"` | `5` – `8` seconds |
| `generate_audio` | boolean | No | `true` | Enable/disable audio |
| `resolution` | string | No | `"720p"` | `720p`, `1080p`, `4k` |
| `enhance_prompt` | boolean | No | `true` | Auto-enhance prompt |
| `seed` | integer | No | random | Reproducibility seed |

#### Pricing (参考价格)

| Resolution | Without Audio | With Audio | 5s (audio) | 8s (audio) |
|:----------:|:------------:|:----------:|:----------:|:----------:|
| 720p / 1080p | $0.20/s | $0.40/s | $2.00 | $3.20 |
| 4K | $0.40/s | $0.60/s | $3.00 | $4.80 |

#### Input/Output Example

**Request:**
```json
{
  "prompt": "Aerial drone shot of a vast lavender field at golden hour, camera slowly descending toward a lone farmhouse, warm light spilling from windows, gentle wind rippling through purple flowers",
  "aspect_ratio": "16:9",
  "duration": "8",
  "generate_audio": true,
  "resolution": "1080p"
}
```

**Response:**
```json
{
  "video": {
    "url": "https://v3.fal.media/files/.../video.mp4",
    "content_type": "video/mp4"
  }
}
```

> ⚠️ **Best for:** Hero shots, cinematic content, final output. Not for fast iteration (slow + expensive).

---

### 🔮 Sora 2 Pro (OpenAI)

**Model ID:** `fal-ai/sora-2/text-to-video/pro`

**Core Features:** Up to 25s duration (industry-leading), native audio with dialogue lip-sync, environmental sound

#### Parameter Reference

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Natural language scene description |
| `aspect_ratio` | string | No | `"16:9"` | `16:9`, `9:16` |
| `duration` | integer | No | `8` | `4`, `8`, `12`, up to `25` seconds |
| `resolution` | string | No | `"1080p"` | `720p`, `1080p` |
| `seed` | integer | No | random | Reproducibility seed |

#### Pricing (参考价格)

| Resolution | Per Second | 5s Cost | 10s Cost | 25s Cost |
|:----------:|:----------:|:-------:|:--------:|:--------:|
| 720p | $0.30 | $1.50 | $3.00 | $7.50 |
| 1080p | $0.50 | $2.50 | $5.00 | $12.50 |

> ⚠️ **Most expensive** model but unique 25s capability. Audio is always generated.

#### Input/Output Example

**Request:**
```json
{
  "prompt": "A bustling Tokyo fish market at dawn, vendors arranging fresh tuna, steam rising from cooking stalls, a cat weaves between wooden crates, cinematic handheld camera",
  "aspect_ratio": "16:9",
  "duration": 12,
  "resolution": "1080p"
}
```

---

### 🌊 MiniMax Hailuo-02 Pro

**Model IDs:**
- T2V: `fal-ai/minimax/hailuo-02/pro/text-to-video`
- I2V: `fal-ai/minimax/hailuo-02/pro/image-to-video`
- Standard T2V: `fal-ai/minimax/hailuo-02/standard/text-to-video`
- Standard I2V: `fal-ai/minimax/hailuo-02/standard/image-to-video`

**Core Features:** Best physics simulation, director camera commands, prompt optimizer, 1080p native

#### Parameter Reference — T2V (Pro)

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Text + `[camera commands]` |
| `prompt_optimizer` | boolean | No | `true` | Auto-enhance prompt quality |
| `duration` | integer | No | `6` | `6` or `10` seconds |
| `resolution` | string | No | `"1080P"` | `768P` (Standard), `1080P` (Pro) |
| `first_frame_image` | string | No | — | First frame image URL (I2V mode) |

#### Camera Commands (in square brackets)

`[Pan left/right]` · `[Truck left/right]` · `[Push in/Pull out]` · `[Pedestal up/down]` · `[Tilt up/down]` · `[Zoom in/out]` · `[Shake]` · `[Tracking shot]` · `[Static shot]`

> Combine up to 3 per prompt: `[Truck left, Pan right, Zoom in]`

#### Pricing (参考价格)

| Tier | Resolution | Per Second | 6s Cost | 10s Cost |
|------|:----------:|:----------:|:-------:|:--------:|
| Pro | 1080P | $0.08 | $0.48 | $0.80 |
| Standard | 768P | $0.045 | $0.27 | $0.45 |
| Standard I2V | 512-768P | ~$0.017-0.045/s | ~$0.10-0.27 | — |

#### Input/Output Example

**Request (T2V Pro):**
```json
{
  "prompt": "A serene mountain landscape with clouds rolling over peaks at sunset [Push in, Tilt up]",
  "prompt_optimizer": true,
  "duration": 6,
  "resolution": "1080P"
}
```

**Response:**
```json
{
  "video": {
    "url": "https://v3.fal.media/files/.../video.mp4",
    "content_type": "video/mp4"
  }
}
```

> ⚠️ **Tips:** Use `prompt_optimizer: true` for better results. Image input requires aspect ratio between 2:5 and 5:2, min 300px on shorter side.

---

## Model Selection Decision Tree

```
                        Need video generation?
                               │
                    ┌──────────┴──────────┐
                    │                     │
              Text-to-Video          Image-to-Video
                    │                     │
            ┌───────┴───────┐      ┌──────┴──────┐
            │               │      │             │
       Need audio?     No audio   Best quality?  Budget?
            │               │      │             │
     ┌──────┴──────┐   Fast iter   Kling 2.6    Hailuo Std
     │             │   Kling 2.5t   Pro I2V      I2V
  Best quality?  Budget?  ($0.07)  ($0.07-0.14)  ($0.017)
     │             │
  ┌──┴──┐    Seedance
  │     │    v1.5 Pro
Sora 2  Veo 3.1  ($0.05)
($0.50) ($0.40)
```

**Quick Decision:**
- 🎬 **Cinematic / hero shots** → `veo3.1` ($0.40/s) or `sora-2/pro` ($0.50/s)
- ⚡ **Fast iteration / previews** → `kling-video/v2.5-turbo/pro` ($0.07/s)
- 🧑 **Characters + physics** → `minimax/hailuo-02/pro` ($0.08/s)
- 🖼️ **Best I2V** → `kling-video/v2.6/pro/image-to-video` ($0.07-0.14/s)
- 🎵 **Video with audio (budget)** → `seedance/v1.5/pro` (~$0.05/s)
- 🎵 **Video with audio (premium)** → `sora-2/pro` ($0.30-0.50/s)
- 💰 **Cheapest** → `seedance/v1/pro` (~$0.02/s) or `hailuo-02/standard` ($0.045/s)
- ⏱️ **Longest duration (25s)** → `sora-2/pro` only
- 📺 **4K output** → `veo3.1` only

### Pipeline Mode Model Strategy

| Condition | Mode | Recommended Model |
|-----------|------|-------------------|
| `image/frames/shot-{NN}-ff.png` exists | I2V (preferred) | `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` |
| No keyframe available | T2V fallback | `fal-ai/bytedance/seedance/v1.5/pro/text-to-video` |
| Hero shot / final render | I2V or T2V | `fal-ai/kling-video/v2.6/pro/*` or `fal-ai/veo3.1` |

Pipeline default is **Seedance v1.5 Pro** for cost/performance + native audio. Upgrade only selected shots to Kling 2.6 or Veo 3.1 when quality target requires it.

## Best Practices

1. **Prompt Structure**: Scene → Action → Dialogue → Camera → Sound/Foley
2. **Dialogue in quotes**: `"Hello world"` — models that support audio will generate speech
3. **Camera description**: Be specific — "slow dolly-in", "handheld shake", "drone pull-out"
4. **Seed for consistency**: Use same `--seed` across related clips
5. **Resolution strategy**: Generate at 480p/720p for testing, 1080p+ for final
6. **Audio toggle**: Set `generate_audio: false` to halve Seedance costs when audio not needed
7. **I2V over T2V**: When you have keyframes, I2V gives more control over appearance
8. **Budget workflow**: Seedance v1 Pro Fast → test → upgrade to v1.5 Pro or Kling 2.6 for final

## Integration with AIVP Pipeline

This skill is typically called after `aivp-storyboard` and `aivp-image`, and before edit/lipsync:

```
aivp-storyboard → aivp-image (keyframes) → aivp-video (clips) → aivp-edit
                                          ↗                     ↘
                              aivp-script (prompt text)      aivp-lipsync
```

**Input from:** `aivp-storyboard` →
- `storyboard/storyboard-final/frame-plan.md` — shot order and generation dependencies
- `storyboard/storyboard-final/shots/*.md` — per-shot prompt/camera/duration specs

**Input from:** `aivp-image` →
- `image/frames/*.png` — keyframes for I2V mode
- `image/characters/*.png` — character references for consistency

**Input from:** `aivp-script` →
- `script/characters/*.md` — identity and appearance constraints
- `script/scenes/*.md` — scene mood/environment language

**Output to:**
- `aivp-edit` → `video/clips/*.mp4` for timeline assembly
- `aivp-lipsync` → selected clips requiring speech-driven mouth sync

### Project Directory Convention

When used within a pipeline project, this skill writes to:

```
project/video/
├── plan.md          ← Track generation progress (same format as image/plan.md)
├── clips/           ← Generated video clips
│   ├── shot-01.mp4
│   ├── shot-02.mp4
│   └── ...
└── log/             ← Generation metadata
    ├── shot-01.json
    └── ...
```

Each skill reads from upstream sibling directories and writes only to its own directory. `aivp-video` reads `script/`, `storyboard/`, and `image/`, and writes only to `video/`.

## Output

**Queue Submit:**
```json
{
  "request_id": "abc123-def456",
  "status": "IN_QUEUE"
}
```

**Completed Result:**
```json
{
  "video": {
    "url": "https://v3.fal.media/files/.../video.mp4",
    "content_type": "video/mp4"
  }
}
```

## Present Results to User

**Video:**
```
[Click to view video](https://v3.fal.media/files/.../video.mp4)
• Model: seedance/v1.5/pro | Duration: 5s | Generated in 45s
```

**Async Submission:**
```
Request submitted to queue.
• Request ID: abc123-def456
• Model: fal-ai/veo3.1
• Check status: bash scripts/generate.sh --status "abc123-def456" --model "fal-ai/veo3.1"
```

## Troubleshooting

### Timeout Error
Video generation can take 1-5 minutes. Use `--async` for long jobs, or increase `--timeout`.

### API Key Error
```
Error: FAL_KEY not set
```
Run: `bash scripts/generate.sh --add-fal-key` or `export FAL_KEY=your_key`

### Image Required for I2V
Image-to-video models require `--image-url` or `--file`. Check model name contains `image-to-video`.

### Inconsistent Style Across Clips
Use `aivp-image` to generate consistent keyframes first, then animate each with I2V models. Use the same `--seed` where supported.
