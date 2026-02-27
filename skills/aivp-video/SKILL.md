---
name: aivp-video
description: Generate AI video clips from text or images using multiple providers (fal.ai, Replicate, local). Use when the user requests "Generate video", "Text to video", "Image to video", "Animate this image", "Create a video clip", or similar video generation tasks.
metadata:
  author: aividpipeline
  version: "0.3.0"
  tags: video, ai-video, text-to-video, image-to-video, seedance, kling, sora, multi-shot
---

# AIVP Video — AI Video Clip Generation

Generate video clips using state-of-the-art AI models. Supports text-to-video, image-to-video, and video-to-video workflows with queue-based async execution.

Supports three modes:

1. **Pipeline mode (single-shot)** — read storyboard + image outputs, generate clips one shot at a time
2. **Pipeline mode (multi-shot)** — group shots and generate via Kling O3 multi-shot API (up to 6 shots per call)
3. **Standalone mode** — generate a single clip from prompt or image

## Core Process

```
Read storyboard outputs (frame-plan.md + shots/*.md)
     ↓
Read image outputs (frames/*.png + characters/*.png)
     ↓
Choose generation strategy:
     ├─ Single-shot (default): one API call per shot
     │   └─ For each shot: choose mode (I2V/T2V) → generate.sh → save clip
     └─ Multi-shot (Kling O3): group shots → one API call per group
         └─ For each group (≤6 shots): build multi-shot payload → generate.sh → split/save clips
     ↓
Save clips to video/clips/, log to video/log/
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
   - `storyboard/storyboard-final/shots/shot-{NN}.md` — per-shot specs with **dual-format prompts**:
     - `Motion prompt (Seedance 2.0 format)` — Chinese time-axis format (primary)
     - `Motion prompt (Kling 3.0 format)` — English format with camera tags (fallback)
   - `image/frames/*.png` — keyframe inputs for I2V mode
   - `image/characters/*.png` — character reference anchors (for element referencing)
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
  - **Default model:** `fal-ai/bytedance/seedance/v1.5/pro` (best value with native audio, ~$0.05/s)
  - **Character consistency needed:** `fal-ai/kling-video/o3/pro/*` (element referencing, ~$0.34/s)
  - **Hero / final render:** `fal-ai/veo3.1` ($0.40/s) or `fal-ai/kling-video/v3/pro/*` ($0.34/s)
  - **Fast iteration:** `fal-ai/kling-video/v2.5-turbo/pro` ($0.07/s, still available)
  - Use Seedance 2.0 format prompt from storyboard when using Seedance models
  - Use Kling 3.0 format prompt from storyboard when using Kling models

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

### Step 2b: Multi-Shot Mode (Kling O3/V3 — Optional)

When character consistency across shots is critical, use Kling 3.0 multi-shot instead of shot-by-shot:

1. **Group shots** from the storyboard (max 6 per group):
   - Same scene → same group
   - Dialogue sequences → same group
   - Don't cross scene boundaries within a group
2. **Build multi-shot payload** using Kling 3.0 format prompts from `shots/*.md`:
   ```bash
   bash scripts/generate.sh \
     --model "fal-ai/kling-video/o3/pro/text-to-video" \
     --prompt "Master: Kitchen, early morning, warm golden light." \
     --multi-shot '[
       {"prompt": "Medium shot, woman sets plate. [Elena]: \"You never listen.\"", "duration": "5"},
       {"prompt": "Close-up reaction. [Marco]: \"Stop blaming!\"", "duration": "4"}
     ]' \
     --element "image/characters/elena-front.png:Elena" \
     --output "video/clips/group-01.mp4"
   ```
3. **Split group output** into individual shot clips if needed for downstream editing
4. Log the group as a single entry in `video/log/group-{NN}.json`

> **When to use multi-shot:** Dialogue-heavy scenes with 2+ characters who must stay consistent. For simple shots or fast iteration, single-shot mode is cheaper and faster.

> **Cost warning:** Kling O3 Pro is ~$0.34/s with audio — a 15s multi-shot group costs ~$5. Use Seedance 1.5 for iteration, Kling O3 for final renders.

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

## Recommended Models (2026-02 Updated)

### Text-to-Video

| Model | Speed | Quality | $/s (audio) | Notes |
|-------|:-----:|:-------:|:-----------:|-------|
| `fal-ai/bytedance/seedance/v1.5/pro` | ⚡⚡ | ★★★★ | ~$0.05 | **Default** — best value with audio |
| `fal-ai/kling-video/o3/pro/text-to-video` | ⚡ | ★★★★★ | ~$0.34 | **Multi-shot + element ref + voice** |
| `fal-ai/kling-video/v3/pro/text-to-video` | ⚡ | ★★★★★ | ~$0.34 | Multi-shot, prompt-driven cinematic |
| `fal-ai/veo3.1` | ⚡ | ★★★★★ | $0.40 | Highest quality, 4K support |
| `fal-ai/sora-2/text-to-video/pro` | ⚡ | ★★★★★ | $0.50 | Up to 25s, native audio |
| `fal-ai/kling-video/v2.5-turbo/pro` | ⚡⚡⚡ | ★★★ | ~$0.07 | **Fastest** — good for iteration |
| `fal-ai/minimax/hailuo-02/pro` | ⚡⚡ | ★★★★ | $0.08 | Best physics, director camera |
| `fal-ai/bytedance/seedance/v1/pro` | ⚡⚡ | ★★★ | ~$0.02 | Budget option |

### Image-to-Video

| Model | Speed | Quality | $/s (audio) | Notes |
|-------|:-----:|:-------:|:-----------:|-------|
| `fal-ai/kling-video/v3/pro/image-to-video` | ⚡ | ★★★★★ | ~$0.34 | **Best I2V** — 3.0 quality |
| `fal-ai/kling-video/v2.6/pro/image-to-video` | ⚡⚡ | ★★★★ | $0.14 | Good I2V, cheaper than v3 |
| `fal-ai/veo3.1/fast/image-to-video` | ⚡⚡⚡ | ★★★★ | ~$0.10 | Fast, high quality |
| `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` | ⚡⚡ | ★★★★ | ~$0.05 | Start+end frame, lip-sync |
| `fal-ai/minimax/hailuo-02/standard/image-to-video` | ⚡⚡ | ★★★ | ~$0.017 | Budget I2V |

### Reference-to-Video (Character Consistency)

| Model | Notes |
|-------|-------|
| `fal-ai/kling-video/o3/pro/reference-to-video` | Upload character image/video → consistent across shots, $0.34/s |
| `fal-ai/kling-video/o3/standard/reference-to-video` | Same but standard tier, $0.22/s |

### Video-to-Video (Style Transfer / Editing)

| Model | Notes |
|-------|-------|
| `fal-ai/kling-video/v2.6/pro/video-to-video` | Style transfer, motion retargeting — $0.112/s |

### Generation Strategy

| Scenario | Model | Why |
|----------|-------|-----|
| Fast iteration / previews | Seedance 1.5 Pro or Kling 2.5 Turbo | Cheap ($0.02-0.07/s) |
| Standard pipeline run | Seedance 1.5 Pro | Best value + audio ($0.05/s) |
| Character consistency needed | Kling O3 Pro (multi-shot) | Element referencing |
| Hero shots / final render | Kling V3 Pro or Veo 3.1 | Top quality |
| Longest single clip (25s) | Sora 2 Pro | Only model with 25s |
| Seedance 2.0 (when on fal.ai) | TBD | Multi-modal ref, 2K, 15s |

---

## Detailed Model Documentation

### 🆕 Kling 3.0 / O3 (Feb 2026 — Character Consistency + Multi-Shot)

**See:** `references/kling3-api.md` for full API details.

**Key capabilities vs 2.x:**
- Multi-shot storyboard (up to 6 shots, each with own prompt/duration, max 15s total)
- Element referencing (upload character images → consistent across shots)
- Multi-character coreference (3+ characters stay distinct)
- Video element referencing (O3 only — 3-8s video → extracts appearance + voice)
- Voice binding (O3 only — consistent voices across generations)
- Native audio in 5 languages (CN/EN/JA/KO/ES)
- Much better fast motion and acting quality

**Pipeline integration:**
- Read Kling 3.0 format prompts from `storyboard/storyboard-final/shots/*.md`
- Upload `image/characters/*.png` as element references
- Group shots by scene for multi-shot generation

**When to use:** Dialogue-heavy scenes, multi-character consistency, final renders.
**When NOT to use:** Fast iteration (too expensive), simple single-shot clips.

### 🆕 Seedance 2.0 (Feb 2026 — Multi-Modal Reference)

**See:** `references/seedance2-api.md` for full API details.

**Key capabilities vs 1.5:**
- Multi-modal reference (up to 12 files: 9 images + 3 videos + 3 audio)
- @ syntax to assign asset roles (`@Image1 as character`, `@Video1 for camera`)
- 2K resolution output (vs 1080p max on 1.5)
- 4-15 seconds duration (vs 4-12 on 1.5)
- Motion/camera/editing rhythm replication from reference videos
- One-take continuity for long unbroken shots

**fal.ai availability:** ⏳ Not yet on fal.ai (still 1.5 as of 2026-02-27). Available via ByteDance official API and proxies.

**Pipeline integration:**
- Read Seedance 2.0 format (Chinese time-axis) prompts from storyboard
- Use `image/characters/*.png` as @ references
- Use `image/frames/*.png` as first frame references

**When to use:** Once available on fal.ai — replaces 1.5 as default pipeline model.

---

### 🎬 Seedance v1.5 Pro (Current Default)

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

### 🎥 Kling v2.6 Pro (Previous Gen — Budget I2V)

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
              ┌────────────────┼────────────────┐
              │                │                │
        Single Shot      Multi-Shot       Reference-based
              │          (Kling O3/V3)    (Kling O3 ref)
              │                │                │
        ┌─────┴─────┐    Need character    Upload char image
        │           │     consistency?     → consistent across
   Has keyframe?  T2V     Yes → O3 Pro       all generations
        │           │     No → V3 Std
       I2V     ┌───┴───┐
        │      │       │
   ┌────┴──┐  Budget?  Premium?
   │       │    │        │
 Seedance Kling Seedance  Veo 3.1
  1.5 I2V v3 I2V 1.5 Pro ($0.40)
 ($0.05) ($0.34) ($0.05)
```

**Quick Decision:**
- 🎬 **Cinematic / hero shots** → Kling V3 Pro ($0.34/s) or Veo 3.1 ($0.40/s)
- 👥 **Character consistency (multi-shot)** → Kling O3 Pro ($0.34/s) — **new**
- ⚡ **Fast iteration / previews** → Kling 2.5 Turbo ($0.07/s) or Seedance v1 ($0.02/s)
- 🖼️ **Best I2V** → Kling V3 Pro I2V ($0.34/s) or v2.6 Pro I2V ($0.14/s, cheaper)
- 🎵 **Video with audio (budget)** → Seedance 1.5 Pro (~$0.05/s)
- 🎵 **Video with audio (premium)** → Sora 2 Pro ($0.50/s)
- 💰 **Cheapest** → Seedance v1 Pro (~$0.02/s) or Hailuo Standard ($0.045/s)
- ⏱️ **Longest single clip (25s)** → Sora 2 Pro only
- 📺 **4K output** → Veo 3.1 only
- 🔮 **Seedance 2.0** (when on fal.ai) → multi-modal ref, 2K, 15s

### Pipeline Mode Model Strategy

| Scenario | Mode | Model | $/s |
|----------|------|-------|:---:|
| Standard shot with keyframe | I2V | Seedance 1.5 Pro I2V | ~$0.05 |
| Standard shot without keyframe | T2V | Seedance 1.5 Pro T2V | ~$0.05 |
| Dialogue scene, 2+ characters | Multi-shot | Kling O3 Pro | ~$0.34 |
| Hero / final render | I2V or T2V | Kling V3 Pro or Veo 3.1 | $0.34-0.40 |
| Fast iteration / test | T2V | Kling 2.5 Turbo or Seedance v1 | $0.02-0.07 |

**Default pipeline model:** Seedance 1.5 Pro (best value + native audio).
**Upgrade path:** Seedance for most shots → Kling O3 for character-heavy scenes → Veo 3.1 for hero shots.

## Best Practices

1. **Prompt Structure**: Scene → Action → Dialogue → Camera → Sound/Foley
2. **Dialogue in quotes**: `"Hello world"` — models that support audio will generate speech
3. **Camera description**: Be specific — "slow dolly-in", "handheld shake", "drone pull-out"
4. **Seed for consistency**: Use same `--seed` across related clips
5. **Resolution strategy**: Generate at 480p/720p for testing, 1080p+ for final
6. **Audio toggle**: Set `generate_audio: false` to halve Seedance costs when audio not needed
7. **I2V over T2V**: When you have keyframes, I2V gives more control over appearance
8. **Budget workflow**: Seedance v1 Pro → test → upgrade to v1.5 Pro or Kling V3 for final
9. **Multi-shot grouping**: Group by scene, max 6 shots, same characters → Kling O3
10. **Element referencing**: Upload character portraits from `image/characters/` as elements for Kling O3
11. **Dual-format prompts**: Storyboard provides both Seedance 2.0 and Kling 3.0 formats — use the matching one for your chosen model

## Integration with AIVP Pipeline

This skill is typically called after `aivp-storyboard` and `aivp-image`, and before edit/lipsync:

```
aivp-storyboard → aivp-image (keyframes) → aivp-video (clips) → aivp-edit
                                          ↗                     ↘
                              aivp-script (prompt text)      aivp-lipsync
```

**Input from:** `aivp-storyboard` →
- `storyboard/storyboard-final/frame-plan.md` — shot order and generation dependencies
- `storyboard/storyboard-final/shots/*.md` — per-shot specs with **dual-format prompts** (Seedance 2.0 + Kling 3.0)

**Input from:** `aivp-image` →
- `image/frames/*.png` — keyframes for I2V mode
- `image/characters/*.png` — character portraits for element referencing (Kling O3)
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

## References (load as needed)

- **Kling 3.0 / O3 API** → `references/kling3-api.md` — Endpoints, multi-shot, element referencing, pricing
- **Seedance 2.0 API** → `references/seedance2-api.md` — Multi-modal reference, @ syntax, 1.5 vs 2.0 comparison
- **fal.ai Queue API** → `references/fal-queue-api.md` — Queue flow, file upload, authentication, error handling

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
