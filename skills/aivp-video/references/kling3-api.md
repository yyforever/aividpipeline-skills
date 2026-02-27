# Kling 3.0 / O3 API Reference (fal.ai)

Updated: 2026-02-27. Source: fal.ai blog + playground docs.

## Endpoints

### Kling V3 (VIDEO 3.0)

| Mode | Tier | Endpoint |
|------|------|----------|
| T2V | Pro | `fal-ai/kling-video/v3/pro/text-to-video` |
| T2V | Standard | `fal-ai/kling-video/v3/standard/text-to-video` |
| I2V | Pro | `fal-ai/kling-video/v3/pro/image-to-video` |
| I2V | Standard | `fal-ai/kling-video/v3/standard/image-to-video` |

### Kling O3 (VIDEO 3.0 Omni)

| Mode | Tier | Endpoint |
|------|------|----------|
| T2V | Pro | `fal-ai/kling-video/o3/pro/text-to-video` |
| T2V | Standard | `fal-ai/kling-video/o3/standard/text-to-video` |
| I2V | Standard | `fal-ai/kling-video/o3/standard/image-to-video` |
| Reference-to-Video | Pro | `fal-ai/kling-video/o3/pro/reference-to-video` |
| Reference-to-Video | Standard | `fal-ai/kling-video/o3/standard/reference-to-video` |

### V3 vs O3

| Feature | V3 | O3 |
|---------|----|----|
| Multi-shot storyboard | ✅ up to 6 shots | ✅ up to 6 shots |
| Element referencing (image) | ✅ | ✅ |
| Video element referencing | ❌ | ✅ |
| Voice binding / control | ❌ | ✅ |
| Multi-character coreference (3+) | ✅ | ✅ |
| Native audio (5 languages) | ✅ CN/EN/JA/KO/ES | ✅ CN/EN/JA/KO/ES |
| Video editing | ❌ | ✅ |
| Best for | Prompt-driven cinematic | Reference-heavy, character consistency |

## Core Features

### Multi-Shot Storyboarding

Up to 6 shots per generation, each with own prompt and duration. Total output up to 15 seconds.

```json
{
  "prompt": "Master scene: Kitchen, early morning, warm golden light.",
  "multi_shot_prompts": [
    {
      "prompt": "Medium shot, woman sets plate down too hard. [Elena, frustrated]: \"You never listen.\"",
      "duration": "5"
    },
    {
      "prompt": "Close-up reaction, man turns. [Marco, defensive]: \"Because you never stop blaming!\"",
      "duration": "4"
    }
  ],
  "aspect_ratio": "16:9",
  "generate_audio": true
}
```

### Element Referencing

Upload character reference images → model preserves identity across shots.

```json
{
  "prompt": "A detective walks into a dark alley...",
  "elements": [
    {
      "image_url": "https://cdn.example.com/detective-portrait.png",
      "description": "The main detective character"
    }
  ]
}
```

O3 also supports video element referencing (3-8s video → extracts appearance + voice).

### Voice Control (O3 only)

Bind specific voices to characters for consistent voice across generations:

```json
{
  "voice_ids": ["voice_id_1", "voice_id_2"]
}
```

## Parameters — T2V

| Parameter | Type | Required | Default | Values |
|-----------|------|:--------:|---------|--------|
| `prompt` | string | Yes | — | Scene description with dialogue in quotes |
| `duration` | string | No | `"5"` | `"3"` to `"15"` |
| `aspect_ratio` | string | No | `"16:9"` | `16:9`, `9:16`, `1:1` |
| `generate_audio` | boolean | No | `false` | Native audio (5 languages) |
| `negative_prompt` | string | No | — | What to avoid |
| `seed` | integer | No | random | Reproducibility |
| `cfg_scale` | float | No | — | Prompt adherence |

### Multi-Shot Additional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `multi_shot_prompts` | array | Array of {prompt, duration} objects, max 6 |
| `elements` | array | Array of {image_url, description} for character refs |
| `voice_ids` | array | Voice IDs for voice control (O3 only) |

## Parameters — I2V

Same as T2V plus:

| Parameter | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `image_url` | string | Yes | Start frame image |
| `end_image_url` | string | No | End frame image |

## Pricing (fal.ai, as of 2026-02)

### V3

| Tier | Audio Off | Audio On | Voice Control |
|------|:---------:|:--------:|:-------------:|
| Standard | $0.168/s | $0.224/s | $0.268/s |
| Pro | $0.252/s | $0.336/s | $0.392/s |

### O3

| Tier | Audio Off | Audio On | Voice Control |
|------|:---------:|:--------:|:-------------:|
| Standard | $0.168/s | $0.224/s | $0.268/s |
| Pro | $0.252/s | $0.336/s | $0.392/s |

Example costs:
- 5s V3 Pro with audio: **$1.68**
- 5s O3 Standard with audio: **$1.12**
- 15s multi-shot (3 × 5s) V3 Pro with audio: **$5.04**

### Previous Generation (still available)

| Model | Audio Off | Audio On |
|-------|:---------:|:--------:|
| Kling v2.6 Pro | $0.07/s | $0.14/s |
| Kling v2.5 Turbo Pro | $0.07/s | — |

> Kling 2.x is 2-4× cheaper than 3.0. Use for fast iteration.

## Prompt Tips

- UPPERCASE acronyms/proper nouns for pronunciation
- Dialogue format: `[Character, emotion]: "text"` for lip sync
- Camera keywords: dolly zoom, tracking shot, rack focus, crane
- Kling 3.0 handles fast motion much better than 2.x
- Multi-shot: each shot prompt can have its own camera, characters, dialogue
- Master prompt sets the scene; shot prompts add specifics

## Response

Same fal.ai queue format:

```json
{
  "video": {
    "url": "https://v3.fal.media/files/.../video.mp4",
    "content_type": "video/mp4"
  }
}
```
