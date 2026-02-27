# fal.ai Queue API Reference

All video models on fal.ai use the queue-based async pattern. This is what our generate.sh implements.

## Flow

```
1. POST https://queue.fal.run/{model_id}
   Authorization: Key {FAL_KEY}
   Body: {prompt, ...parameters}
   → {request_id, status: "IN_QUEUE", response_url, status_url, cancel_url}

2. GET {status_url}
   → {status: "IN_QUEUE"|"IN_PROGRESS"|"COMPLETED", queue_position, logs[]}

3. GET {response_url}  (when COMPLETED)
   → {video: {url, content_type}}
```

## Authentication

```bash
export FAL_KEY="your-api-key"
# Or in .env file
```

Get key from: https://fal.ai/dashboard/keys

## File Upload

Two-step process for local files:

```bash
# 1. Get upload token
POST https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3
→ {"token": "...", "base_url": "https://v3b.fal.media"}

# 2. Upload file
POST {base_url}/files/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data
→ {"access_url": "https://v3b.fal.media/files/..."}
```

Max file size: 100MB (simple upload).

## Model Discovery

Get OpenAPI schema for any model:
```
https://fal.ai/api/openapi/queue/openapi.json?endpoint_id={model-id-url-encoded}
```

Search models:
```
https://fal.ai/api/models/search?q={query}&category={text-to-video|image-to-video}
```

## Response Format

All video models return:

```json
{
  "video": {
    "url": "https://v3.fal.media/files/.../video.mp4",
    "content_type": "video/mp4"
  }
}
```

> ⚠️ Signed URLs expire (typically 24h). Download immediately.

## Error Handling

| Status | Meaning | Action |
|--------|---------|--------|
| 422 | Invalid parameters | Check model schema |
| 429 | Rate limited | Wait and retry |
| 500 | Server error | Retry with backoff |
| FAILED (in queue) | Generation failed | Check logs, rephrase prompt |
