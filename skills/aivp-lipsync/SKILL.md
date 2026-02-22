---
name: aivp-lipsync
description: Audio-driven talking video, motion transfer, and video dubbing for AI video production. Use when the user requests "Make this person talk", "Lip sync", "Audio to video", "Motion transfer", "Dub video", "OmniHuman", "DreamActor", or similar lip-sync/motion-driven tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: lipsync, audio-driven, motion-transfer, dubbing, omnihuman, dreamactor, video
---

# AIVP Lipsync — Audio-Driven Video, Motion Transfer & Dubbing

Generate talking-head videos from a still image and audio, transfer motion/expressions between videos, and dub existing videos with new audio — all powered by state-of-the-art lip-sync models.

## Scripts

| Script | Purpose |
|--------|---------|
| `audio-to-video.sh` | Image + audio → talking video (OmniHuman mode) |
| `motion-transfer.sh` | Reference video + target image → motion-transferred video (DreamActor mode) |
| `dub-video.sh` | Video + new audio → lip-synced dubbed video |

## Audio-Driven Video (OmniHuman)

Input a portrait image and an audio clip to generate a realistic talking video with synchronized lip movements, natural expressions, and emotion-correlated gestures.

```bash
bash scripts/audio-to-video.sh [options]
```

### Basic Usage

```bash
# Portrait + speech audio → talking video
bash scripts/audio-to-video.sh \
  --image-url "https://example.com/portrait.jpg" \
  --audio-url "https://example.com/speech.mp3"

# With prompt and 720p for longer audio
bash scripts/audio-to-video.sh \
  --image-url "https://example.com/portrait.jpg" \
  --audio-url "https://example.com/narration.mp3" \
  --resolution 720p \
  --prompt "Professional news anchor presenting"

# Turbo mode for fast preview
bash scripts/audio-to-video.sh \
  --image-url "https://example.com/portrait.jpg" \
  --audio-url "https://example.com/speech.mp3" \
  --turbo

# Upload local files
bash scripts/audio-to-video.sh \
  --image ./portrait.png \
  --audio ./speech.mp3

# Async mode (returns request_id immediately)
bash scripts/audio-to-video.sh \
  --image-url "https://example.com/portrait.jpg" \
  --audio-url "https://example.com/speech.mp3" \
  --async
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--image-url` | Portrait image URL (required unless `--image`) | - |
| `--audio-url` | Audio file URL (required unless `--audio`) | - |
| `--image` | Local image file (auto-uploads to fal CDN) | - |
| `--audio` | Local audio file (auto-uploads to fal CDN) | - |
| `--model`, `-m` | Model ID | `fal-ai/bytedance/omnihuman/v1.5` |
| `--prompt`, `-p` | Text prompt to guide style | - |
| `--resolution` | Video resolution: `720p` or `1080p` | `1080p` |
| `--turbo` | Enable turbo mode (faster, slightly lower quality) | off |
| `--output`, `-o` | Save video to local path | - |
| `--async` | Return request_id immediately (don't poll) | off |
| `--status ID` | Check queue status of request | - |
| `--result ID` | Get result of completed request | - |
| `--cancel ID` | Cancel a queued request | - |
| `--poll-interval` | Seconds between status checks | `5` |
| `--timeout` | Max wait time in seconds | `600` |
| `--logs` | Show queue logs while polling | off |

### Resolution Limits

| Resolution | Max Audio Duration | Notes |
|-----------|-------------------|-------|
| 1080p | 30 seconds | Best quality |
| 720p | 60 seconds | Supports longer audio, still high quality |

### Pricing

- **Per second**: ~$0.16/sec (64 credits/sec)
- Video duration = audio duration
- Minimum billing: 3 seconds

## Motion Transfer (DreamActor)

Transfer motion, expressions, and lip movements from a driving video to a target image. The target character's identity and background are preserved.

```bash
bash scripts/motion-transfer.sh [options]
```

### Basic Usage

```bash
# Transfer dance motion to a character
bash scripts/motion-transfer.sh \
  --image-url "https://example.com/character.png" \
  --video-url "https://example.com/dance.mp4"

# Keep first-second transition
bash scripts/motion-transfer.sh \
  --image-url "https://example.com/character.png" \
  --video-url "https://example.com/acting.mp4" \
  --no-trim

# Upload local files
bash scripts/motion-transfer.sh \
  --image ./character.png \
  --video ./dance.mp4
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--image-url` | Target character image URL (required unless `--image`) | - |
| `--video-url` | Driving video URL (required unless `--video`) | - |
| `--image` | Local image file (auto-uploads) | - |
| `--video` | Local video file (auto-uploads) | - |
| `--model`, `-m` | Model ID | `fal-ai/bytedance/dreamactor/v2` |
| `--no-trim` | Don't trim first second of output | off (trims by default) |
| `--output`, `-o` | Save video to local path | - |
| `--async` | Return request_id immediately | off |
| `--status ID` | Check queue status | - |
| `--result ID` | Get result | - |
| `--cancel ID` | Cancel request | - |
| `--poll-interval` | Seconds between checks | `5` |
| `--timeout` | Max wait seconds | `600` |
| `--logs` | Show logs while polling | off |

### Input Requirements

**Image:**
- Formats: jpeg, jpg, png
- Max size: 4.7 MB
- Resolution: 480×480 to 1920×1080
- Character should be clearly visible

**Video:**
- Formats: mp4, mov, webm
- Max duration: 30 seconds
- Resolution: 200×200 to 2048×1440
- Supports face and full-body driving

### Supported Subjects

- Real humans (portraits, full-body)
- Animated characters
- Pets and animals
- Multi-character scenes

### Pricing

- **Per second**: ~$0.05/sec (20 credits/sec)
- Based on driving video duration
- Minimum billing: 3 seconds

## Video Dubbing (Lip Sync)

Replace the audio track of an existing video while re-synchronizing the speaker's lip movements to match the new audio.

```bash
bash scripts/dub-video.sh [options]
```

### Basic Usage

```bash
# Dub video with new audio
bash scripts/dub-video.sh \
  --video-url "https://example.com/original.mp4" \
  --audio-url "https://example.com/new-voiceover.mp3"

# Upload local files
bash scripts/dub-video.sh \
  --video ./original.mp4 \
  --audio ./dubbed-audio.mp3
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--video-url` | Source video URL (required unless `--video`) | - |
| `--audio-url` | New audio URL (required unless `--audio`) | - |
| `--video` | Local video file (auto-uploads) | - |
| `--audio` | Local audio file (auto-uploads) | - |
| `--model`, `-m` | Model ID | `fal-ai/pixverse/lipsync` |
| `--output`, `-o` | Save video to local path | - |
| `--async` | Return request_id immediately | off |
| `--status ID` | Check queue status | - |
| `--result ID` | Get result | - |
| `--cancel ID` | Cancel request | - |
| `--poll-interval` | Seconds between checks | `5` |
| `--timeout` | Max wait seconds | `600` |
| `--logs` | Show logs while polling | off |

### Pricing

- Per-request pricing varies by model and video duration
- Check fal.ai pricing page for current rates

## Recommended Models

### Audio-Driven Video

| Model | Quality | Speed | Notes |
|-------|:-------:|:-----:|-------|
| `fal-ai/bytedance/omnihuman/v1.5` | ★★★★★ | ⚡ | **Default** — best lip-sync, emotion-correlated |

### Motion Transfer

| Model | Quality | Speed | Notes |
|-------|:-------:|:-----:|-------|
| `fal-ai/bytedance/dreamactor/v2` | ★★★★★ | ⚡⚡ | **Default** — multi-character, pets, anime |

### Video Dubbing

| Model | Quality | Speed | Notes |
|-------|:-------:|:-----:|-------|
| `fal-ai/pixverse/lipsync` | ★★★★ | ⚡⚡ | **Default** — video re-dubbing |

## Integration with AIVP Pipeline

```
aivp-script (narration text)
     ↓
aivp-audio (TTS voiceover)
     ↓
aivp-lipsync (audio-to-video)  ← image + voiceover → talking video
     ↓
aivp-edit (composite into final video)
```

### Common Workflows

**Workflow 1: Character Narration**
```
1. aivp-image → generate character portrait
2. aivp-audio → TTS narration from script
3. aivp-lipsync/audio-to-video → talking-head video
4. aivp-edit → composite into final video
```

**Workflow 2: Multi-Language Dubbing**
```
1. Start with original video
2. aivp-audio/voice-clone → clone original speaker's voice
3. aivp-audio/text-to-speech → generate dubbed audio in new language
4. aivp-lipsync/dub-video → re-sync lips to new audio
```

**Workflow 3: Character Animation**
```
1. aivp-image → generate character portrait
2. Record or source a driving video (dance, gestures, etc.)
3. aivp-lipsync/motion-transfer → animate character with motion
4. aivp-edit → add music, effects
```

### Project Directory Convention

```
project/
├── characters/
│   ├── narrator.png          ← character portrait
│   └── host.png
├── audio/
│   ├── voiceover_scene_01.mp3
│   └── voiceover_scene_02.mp3
├── lipsync/
│   ├── talking_scene_01.mp4  ← audio-driven output
│   ├── talking_scene_02.mp4
│   ├── dance_transfer.mp4    ← motion transfer output
│   └── dubbed_scene.mp4      ← dubbing output
└── driving/
    └── dance_reference.mp4   ← motion reference video
```

## Output Format

All scripts output JSON to stdout. Status/progress messages go to stderr.

### Audio-to-Video Output
```json
{
  "video": { "url": "https://v3.fal.media/files/.../output.mp4" }
}
```

### Motion Transfer Output
```json
{
  "video": { "url": "https://v3.fal.media/files/.../output.mp4" }
}
```

### Dub Video Output
```json
{
  "video": { "url": "https://v3.fal.media/files/.../output.mp4" }
}
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Lip sync out of alignment | Ensure clean audio without background music; use 1080p |
| Motion transfer looks unnatural | Use driving video with clear, deliberate movements |
| Turbo mode artifacts | Disable turbo for final renders |
| Audio too long for 1080p | Switch to 720p (supports up to 60s) |
| Upload fails | Check file format and size limits |
| Queue timeout | Increase `--timeout` or use `--async` mode |

## Tips

1. **Portrait quality matters**: Use high-resolution, well-lit portraits with clear face visibility
2. **Audio clarity**: Clean speech audio without background noise produces best lip sync
3. **Resolution trade-off**: 1080p for short clips (< 30s), 720p for longer content
4. **Combine with voice clone**: Clone a voice with `aivp-audio`, then generate talking video — powerful for multilingual content
5. **Motion reference**: For motion transfer, use videos with clear movements against simple backgrounds
6. **Batch processing**: Use `--async` mode to submit multiple jobs, then collect results
