# OpenRouter Image Generation API

## Endpoint

```
POST https://openrouter.ai/api/v1/chat/completions
```

OpenAI-compatible format. Image generation uses the same endpoint as text, with the `modalities` parameter.

## Authentication

```
Authorization: Bearer sk-or-v1-...
```

## Two Model Categories

### Pure Image Models (modalities: ["image"])

These models ONLY generate images, no text. They require `modalities: ["image"]`.

```json
{
  "model": "black-forest-labs/flux.2-pro",
  "messages": [{"role": "user", "content": "A sunlit kitchen, cinematic lighting"}],
  "modalities": ["image"],
  "max_tokens": 500
}
```

Known pure image models:
- `black-forest-labs/flux.2-pro` — highest photorealism
- `black-forest-labs/flux.2-flex` — supports img2img / ControlNet

### Multi-Modal Models (modalities: ["image", "text"])

These models generate both image and text. They can also accept image inputs for editing.

```json
{
  "model": "google/gemini-2.5-flash-image",
  "messages": [{"role": "user", "content": "A portrait of a young woman, studio lighting"}],
  "modalities": ["image", "text"],
  "max_tokens": 1024
}
```

Known multi-modal image models:
- `google/gemini-2.5-flash-image`
- `google/gemini-3-pro-image-preview`
- `openai/gpt-5-image-mini`
- `openai/gpt-5-image`

## Reference Image Input (Image-to-Image)

Send a reference image as part of the message content array:

```json
{
  "model": "google/gemini-2.5-flash-image",
  "messages": [{
    "role": "user",
    "content": [
      {
        "type": "image_url",
        "image_url": {"url": "data:image/png;base64,iVBOR..."}
      },
      {
        "type": "text",
        "text": "Generate a similar scene from a different angle"
      }
    ]
  }],
  "modalities": ["image", "text"],
  "max_tokens": 1024
}
```

## Response Format

Images are returned in `choices[0].message.images` as base64 data URIs:

```json
{
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "Here is the generated image...",
      "images": [{
        "image_url": {
          "url": "data:image/png;base64,iVBOR..."
        }
      }]
    }
  }],
  "usage": {
    "prompt_tokens": 100,
    "completion_tokens": 0,
    "cost": 0.03
  },
  "provider": "Black Forest Labs"
}
```

### Important Notes

- **Images are in `message.images`** — NOT in `message.content`
- The `content` field may contain text (multi-modal models) or be empty (pure image models)
- Image format varies by model: PNG (Flux, Gemini) or JPEG (some Gemini)
- `usage.cost` gives the actual cost in USD
- `provider` shows which backend served the request

## Gotchas

1. **Flux models not in /api/v1/models** — They work when called directly but don't appear in the models list API
2. **GPT-5 Image Mini** may return empty `images` array — needs different parameter handling
3. **max_tokens minimum for OpenAI models is 16** — set at least 500 to be safe
4. **No negative prompts for most models** — describe what you WANT, not what to avoid (except via model-specific parameters)

## Cost Reference (as of testing, subject to change)

| Model | Approx Cost/Image |
|-------|:-----------------:|
| Flux 2 Pro | $0.03 |
| Flux 2 Flex | $0.05 |
| Gemini 2.5 Flash Image | $0.04 |
| Gemini 3 Pro Image Preview | $0.002 |
| GPT-5 Image Mini | $0.002 |

> ⚠️ Prices change. Check https://openrouter.ai/models for current pricing.
