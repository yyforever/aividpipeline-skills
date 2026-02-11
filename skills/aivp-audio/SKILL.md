---
name: aivp-audio
description: Generate voiceover, background music, and sound effects for AI video production. Use when the user requests "Generate voiceover", "Create music", "Text to speech", "Background music", "Sound effects", or similar audio generation tasks.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: audio, tts, voiceover, music, sound-effects, speech
---

# AIVP Audio — Voiceover, Music & Sound Effects

Generate audio assets for video production: voiceover narration, background music, and sound effects using AI models.

## Scripts

| Script | Purpose |
|--------|---------|
| `text-to-speech.sh` | Generate voiceover from script text |
| `text-to-music.sh` | Generate background music |
| `speech-to-text.sh` | Transcribe audio (for subtitles) |

## Text-to-Speech (Voiceover)

```bash
bash scripts/text-to-speech.sh [options]
```

### Basic Usage

```bash
# Default model (fast, good quality)
bash scripts/text-to-speech.sh \
  --text "Welcome to the future of AI video production."

# High quality
bash scripts/text-to-speech.sh \
  --text "This is premium narration." \
  --model "fal-ai/minimax/speech-2.6-hd"

# Natural voice (ElevenLabs)
bash scripts/text-to-speech.sh \
  --text "Natural sounding narration" \
  --model "fal-ai/elevenlabs/eleven-v3"

# Multi-language
bash scripts/text-to-speech.sh \
  --text "这是一段中文配音" \
  --model "fal-ai/chatterbox/multilingual"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--text` | Text to convert (required) | - |
| `--model` | TTS model | `fal-ai/minimax/speech-2.6-turbo` |
| `--voice` | Voice ID (model-specific) | - |
| `--output`, `-o` | Save to local path | - |

## Text-to-Music (BGM)

```bash
bash scripts/text-to-music.sh [options]
```

### Basic Usage

```bash
# Background music
bash scripts/text-to-music.sh \
  --prompt "Upbeat corporate background music, inspiring, 120bpm"

# Cinematic score
bash scripts/text-to-music.sh \
  --prompt "Epic cinematic orchestral music, building tension" \
  --model "fal-ai/minimax-music/v2"

# Instrumental only
bash scripts/text-to-music.sh \
  --prompt "Calm lo-fi hip hop beat, no vocals" \
  --model "fal-ai/sonauto/v2"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--prompt`, `-p` | Music description (required) | - |
| `--model` | Music model | `fal-ai/minimax-music/v2` |
| `--duration` | Target duration in seconds | model default |
| `--output`, `-o` | Save to local path | - |

## Speech-to-Text (Transcription)

```bash
bash scripts/speech-to-text.sh [options]
```

### Basic Usage

```bash
# Transcribe audio
bash scripts/speech-to-text.sh \
  --audio-url "https://example.com/voiceover.mp3"

# With speaker diarization
bash scripts/speech-to-text.sh \
  --audio-url "https://example.com/interview.mp3" \
  --model "fal-ai/elevenlabs/scribe"

# Specify language
bash scripts/speech-to-text.sh \
  --audio-url "https://example.com/chinese.mp3" \
  --language "zh"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--audio-url` | URL of audio file (required) | - |
| `--model` | STT model | `fal-ai/whisper` |
| `--language` | Language code (auto-detected) | - |

## Recommended Models

### Text-to-Speech

| Model | Quality | Speed | Notes |
|-------|:-------:|:-----:|-------|
| `fal-ai/minimax/speech-2.6-hd` | ★★★★★ | ⚡ | Best quality |
| `fal-ai/minimax/speech-2.6-turbo` | ★★★★ | ⚡⚡⚡ | **Default** — fast |
| `fal-ai/elevenlabs/eleven-v3` | ★★★★★ | ⚡⚡ | Natural voices, many options |
| `fal-ai/chatterbox/multilingual` | ★★★ | ⚡⚡⚡ | Multi-language |
| `fal-ai/kling-video/v1/tts` | ★★★ | ⚡⚡ | For video lipsync |

### Text-to-Music

| Model | Quality | Notes |
|-------|:-------:|-------|
| `fal-ai/minimax-music/v2` | ★★★★★ | **Best quality** |
| `fal-ai/minimax-music/v1.5` | ★★★★ | Fast |
| `fal-ai/lyria2` | ★★★★ | Google's model |
| `fal-ai/elevenlabs/music` | ★★★★ | Song with vocals |
| `fal-ai/sonauto/v2` | ★★★ | Instrumental |
| `fal-ai/beatoven` | ★★★ | Background music |

### Speech-to-Text

| Model | Features | Notes |
|-------|----------|-------|
| `fal-ai/whisper` | 99+ languages, timestamps | Fast, general |
| `fal-ai/elevenlabs/scribe` | Speaker diarization | Multi-speaker |

## Integration with AIVP Pipeline

```
aivp-script (narration text) → aivp-audio (voiceover + BGM)
                                     ↓
                               aivp-edit (mix into video)
```

### Project Directory Convention

```
project/
├── audio/
│   ├── voiceover_full.mp3       ← full narration
│   ├── voiceover_scene_01.mp3   ← per-scene narration
│   ├── voiceover_scene_02.mp3
│   ├── bgm.mp3                  ← background music
│   └── sfx/                     ← sound effects
│       ├── whoosh.mp3
│       └── click.mp3
├── subtitles/
│   └── transcript.srt           ← from speech-to-text
└── metadata/
    └── audio_params.json
```

## Output

### TTS Output
```json
{
  "audio": { "url": "https://v3.fal.media/files/.../speech.mp3" }
}
```

### Music Output
```json
{
  "audio": { "url": "https://v3.fal.media/files/.../music.mp3" }
}
```

## Troubleshooting

### Voice Sounds Robotic
Use `fal-ai/minimax/speech-2.6-hd` or `fal-ai/elevenlabs/eleven-v3` for natural voices.

### Music Too Short
Specify `--duration` for longer tracks. Some models have maximum duration limits.

### Language Detection Wrong
Use `--language` to specify explicitly (e.g., `zh`, `ja`, `ko`, `en`).
