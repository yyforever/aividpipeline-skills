---
name: aivp-video
description: Generate AI video clips from text or images using multiple providers (fal.ai, Replicate, local). Use when the user requests "Generate video", "Text to video", "Image to video", "Animate this image", "Create a video clip", or similar video generation tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: video, ai-video, text-to-video, image-to-video, seedance, kling, sora
---

# AIVP Video — AI Video Clip Generation

Generate video clips using state-of-the-art AI models. Supports text-to-video, image-to-video, and video-to-video workflows with queue-based async execution.

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
  --file "./keyframes/scene_01.png"
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

| Model | Speed | Quality | Notes |
|-------|:-----:|:-------:|-------|
| `fal-ai/bytedance/seedance/v1.5/pro` | ⚡⚡ | ★★★★ | **Default** — fast, good quality, native audio |
| `fal-ai/veo3.1` | ⚡ | ★★★★★ | Highest quality, slow |
| `fal-ai/sora-2/pro` | ⚡ | ★★★★★ | OpenAI Sora |
| `fal-ai/kling-video/v2.5-turbo/pro` | ⚡⚡⚡ | ★★★ | Fastest |
| `fal-ai/minimax/hailuo-02/pro` | ⚡⚡ | ★★★★ | Good for characters |
| `fal-ai/bytedance/seedance/v1/pro` | ⚡⚡ | ★★★ | Older Seedance |

### Image-to-Video

| Model | Speed | Quality | Notes |
|-------|:-----:|:-------:|-------|
| `fal-ai/kling-video/v2.6/pro/image-to-video` | ⚡⚡ | ★★★★★ | **Best overall** |
| `fal-ai/veo3/fast` | ⚡⚡⚡ | ★★★★ | Fast, high quality |
| `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` | ⚡⚡ | ★★★★ | Smooth motion |
| `fal-ai/minimax/hailuo-02/standard/image-to-video` | ⚡⚡ | ★★★ | Good balance |

### Video-to-Video (Style Transfer)

| Model | Notes |
|-------|-------|
| `fal-ai/kling-video/v2.6/pro/video-to-video` | Style transfer, motion retargeting |

## Model Selection Guide

**Choose by use case:**
- 🎬 **Cinematic / hero shots** → `veo3.1` or `sora-2/pro`
- ⚡ **Fast iteration / previews** → `kling-video/v2.5-turbo/pro`
- 🧑 **Character animation** → `minimax/hailuo-02/pro`
- 🖼️ **Animate keyframe** → `kling-video/v2.6/pro/image-to-video`
- 🎵 **Video with audio** → `seedance/v1.5/pro` (native audio support)
- 💰 **Budget-conscious** → `seedance/v1/pro` or `kling-video/v2.5-turbo`

## Integration with AIVP Pipeline

This skill is typically called after `aivp-storyboard` and `aivp-image`:

```
aivp-storyboard → aivp-image (keyframes) → aivp-video (animate)
                                          ↗
                              aivp-script (prompt text)
```

### Project Directory Convention

When used within a pipeline project, videos are saved to:

```
project/
├── storyboard.json       ← from aivp-storyboard
├── keyframes/
│   ├── scene_01.png      ← from aivp-image
│   ├── scene_02.png
│   └── ...
├── clips/
│   ├── scene_01.mp4      ← generated by aivp-video
│   ├── scene_02.mp4
│   └── ...
└── metadata/
    ├── scene_01.json     ← generation params + request_id
    └── scene_02.json
```

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
