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
| `voice-clone.sh` | Clone a voice from reference audio → TTS with cloned voice |

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

| Model | Quality | Speed | Pricing (参考) | Notes |
|-------|:-------:|:-----:|:-------------:|-------|
| `fal-ai/minimax/speech-2.6-hd` | ★★★★★ | ⚡ | $0.05/1K chars | Best quality |
| `fal-ai/minimax/speech-2.6-turbo` | ★★★★ | ⚡⚡⚡ | $0.03/1K chars | **Default** — fast |
| `fal-ai/elevenlabs/tts/eleven-v3` | ★★★★★ | ⚡⚡ | $0.10/1K chars | Natural voices, streaming |
| `fal-ai/chatterbox/multilingual` | ★★★ | ⚡⚡⚡ | $0.02/1K chars | Multi-language, budget |
| `fal-ai/kling-video/v1/tts` | ★★★ | ⚡⚡ | — | For video lipsync |

### Text-to-Music

| Model | Quality | Pricing (参考) | Notes |
|-------|:-------:|:-------------:|-------|
| `fal-ai/minimax-music/v2` | ★★★★★ | $0.03/generation | **Best quality**, lyrics support |
| `fal-ai/minimax-music/v1.5` | ★★★★ | $0.035/generation | Previous gen, still good |
| `fal-ai/lyria2` | ★★★★ | ~$0.05/generation | Google's model |
| `fal-ai/elevenlabs/music` | ★★★★ | ~$0.10/generation | Song with vocals |
| `fal-ai/sonauto/v2` | ★★★ | $0.075/generation | Full song creation |
| `fal-ai/beatoven` | ★★★ | ~$0.03/generation | Background music |

### Speech-to-Text

| Model | Features | Pricing (参考) | Notes |
|-------|----------|:-------------:|-------|
| `fal-ai/whisper` | 99+ languages, timestamps | ~$0.001/s compute | Fast, general |
| `fal-ai/elevenlabs/scribe` | Speaker diarization | $0.03/minute | Multi-speaker |

---

## Detailed Model Documentation

### 🎙️ MiniMax Speech 2.6 HD / Turbo

**Model IDs:**
- HD: `fal-ai/minimax/speech-2.6-hd`
- Turbo: `fal-ai/minimax/speech-2.6-turbo`

**Core Features:** High-quality Chinese/English TTS, emotion control, voice cloning support, streaming output

#### Parameter Reference

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `text` | string | **Yes** | — | Text to synthesize (max 10,000 chars) |
| `voice_id` | string | No | model default | Voice ID — see common voices below |
| `speed` | float | No | `1.0` | `0.5` – `2.0` (speech rate) |
| `pitch` | integer | No | `0` | `-12` – `12` (semitones) |
| `vol` | float | No | `1.0` | `0` – `10` (volume) |
| `language_boost` | string | No | — | `Chinese`, `English`, `Japanese`, `Korean`, `auto` |
| `output_format` | string | No | `"mp3"` | `mp3`, `wav`, `pcm` |

#### HD vs Turbo Comparison

| Feature | HD | Turbo |
|---------|:--:|:-----:|
| Quality | ★★★★★ | ★★★★ |
| Latency | ~2-3s | ~0.5-1s |
| Pricing (参考) | ~$0.05/1K chars | ~$0.03/1K chars |
| Best for | Final output, podcasts, audiobooks | Real-time, interactive, previews |
| Streaming | Yes | Yes |
| Emotion control | fluent/whisper tags | fluent/whisper tags |

#### Common Voice IDs

| voice_id | Name | Character |
|----------|------|-----------|
| `male-qn-qingse` | 青涩男声 | Young, energetic |
| `male-qn-jingying` | 精英男声 | Mature, professional |
| `female-shaonv` | 少女音 | Fresh, sweet |
| `female-yujie` | 御姐音 | Mature, elegant |
| `female-tianmei` | 甜美女声 | Warm, gentle |
| `presenter_male` | 男主播 | Professional broadcasting |
| `presenter_female` | 女主播 | Professional broadcasting |

> Full voice list available via API. Custom voices via voice cloning (10s-5min audio sample).

#### Pricing (参考价格)

| Model | Per 1K Characters | 1K chars (中文~500字) | 5K chars (~2500字) |
|-------|:-----------------:|:--------------------:|:------------------:|
| Speech 2.6 HD | ~$0.05 | $0.05 | $0.25 |
| Speech 2.6 Turbo | ~$0.03 | $0.03 | $0.15 |

#### Input/Output Example

**Request:**
```json
{
  "text": "各位听众朋友们，大家好！今天我们来聊聊人工智能的发展。这是一个令人兴奋的领域，正在改变我们的世界。",
  "voice_id": "presenter_male",
  "speed": 1.0,
  "language_boost": "Chinese"
}
```

**Response:**
```json
{
  "audio": {
    "url": "https://v3.fal.media/files/.../speech.mp3",
    "content_type": "audio/mpeg"
  }
}
```

> ⚠️ **Tips:** Use HD for final delivery, Turbo for drafts/testing. `language_boost` improves accuracy for specific languages. Emotion tags: wrap text in `[fluent]...[/fluent]` or `[whisper]...[/whisper]` for style control.

---

### 🗣️ ElevenLabs Eleven-v3

**Model ID:** `fal-ai/elevenlabs/tts/eleven-v3`

**Core Features:** Most natural-sounding voices, largest voice library, streaming, voice cloning, emotion-rich output

#### Parameter Reference

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `text` | string | **Yes** | — | Text to synthesize |
| `voice_id` | string | No | `"JBFqnCBsd6RMkjVDRZzb"` | ElevenLabs voice ID |
| `model_id` | string | No | `"eleven_v3"` | Model variant |
| `stability` | float | No | `0.5` | `0` – `1.0` (voice consistency) |
| `similarity_boost` | float | No | `0.75` | `0` – `1.0` (voice similarity to original) |
| `style` | float | No | `0.0` | `0` – `1.0` (expressiveness) |
| `speed` | float | No | `1.0` | `0.25` – `4.0` |
| `output_format` | string | No | `"mp3_44100_128"` | Various mp3/pcm formats |
| `language_code` | string | No | auto | ISO language code |

#### Pricing (参考价格)

| Unit | Price | Example: 5000 chars |
|------|:-----:|:-------------------:|
| Per 1K characters | $0.10 | $0.50 |

> ~2x more expensive than MiniMax HD, but with broader voice variety and most natural intonation.

#### Input/Output Example

**Request:**
```json
{
  "text": "Welcome to the future of AI video production. Today we're going to explore how artificial intelligence is revolutionizing the creative process.",
  "voice_id": "JBFqnCBsd6RMkjVDRZzb",
  "stability": 0.5,
  "similarity_boost": 0.75,
  "style": 0.3,
  "speed": 1.0
}
```

**Response:**
```json
{
  "audio": {
    "url": "https://v3.fal.media/files/.../speech.mp3",
    "content_type": "audio/mpeg"
  }
}
```

> ⚠️ **Tips:** Best for English narration and emotional content. Higher `style` = more expressive but less stable. Higher `stability` = more consistent but potentially monotone. Supports streaming output for real-time applications.

---

### 🎵 MiniMax Music v2

**Model ID:** `fal-ai/minimax-music/v2`

**Core Features:** Highest quality AI music generation, lyrics support, diverse genres, reference track support

#### Parameter Reference

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `prompt` | string | **Yes** | — | Music description (genre, mood, tempo, instruments) |
| `lyrics` | string | No | — | Song lyrics (for vocal tracks) |
| `reference_audio_url` | string | No | — | Reference track URL for style guidance |
| `duration` | integer | No | model default | Target duration in seconds |

#### Pricing (参考价格)

| Unit | Price | Notes |
|------|:-----:|-------|
| Per generation | $0.03 | One of the cheapest music models |

#### Input/Output Example

**Request (Instrumental):**
```json
{
  "prompt": "Epic cinematic orchestral music, building tension, strings and brass, 110 BPM, dramatic"
}
```

**Request (With lyrics):**
```json
{
  "prompt": "Upbeat pop song, female vocal, catchy chorus, 120 BPM, major key",
  "lyrics": "[Verse]\nWalking down the street today\nSun is shining all the way\n[Chorus]\nThis is our moment, this is our time\nEverything is gonna be just fine"
}
```

**Response:**
```json
{
  "audio": {
    "url": "https://v3.fal.media/files/.../music.mp3",
    "content_type": "audio/mpeg"
  }
}
```

> ⚠️ **Tips:** Include BPM, key, genre, and instrument details for best results. Use `[Verse]`, `[Chorus]`, `[Bridge]` tags in lyrics. Reference audio helps match a specific style.

---

### 📝 Whisper (Speech-to-Text)

**Model ID:** `fal-ai/whisper`

**Core Features:** OpenAI Whisper, 99+ languages, word-level timestamps, automatic language detection

#### Parameter Reference

| Parameter | Type | Required | Default | Range / Options |
|-----------|------|:--------:|---------|-----------------|
| `audio_url` | string | **Yes** | — | Audio file URL (mp3/wav/m4a/ogg/aac) |
| `task` | string | No | `"transcribe"` | `transcribe` or `translate` (to English) |
| `language` | string | No | auto-detect | ISO language code (`en`, `zh`, `ja`, `ko`...) |
| `chunk_level` | string | No | `"segment"` | `segment` or `word` (timestamp granularity) |
| `version` | string | No | `"3"` | Whisper version (`3` recommended) |
| `diarize` | boolean | No | `false` | Speaker diarization (who said what) |

#### Pricing (参考价格)

| Unit | Price | Notes |
|------|:-----:|-------|
| Per compute second | ~$0.001 | Extremely cheap; 1min audio ≈ $0.01-0.02 |

> For speaker diarization, consider `fal-ai/elevenlabs/scribe` ($0.03/min).

#### Input/Output Example

**Request:**
```json
{
  "audio_url": "https://example.com/interview.mp3",
  "language": "zh",
  "chunk_level": "segment"
}
```

**Response:**
```json
{
  "text": "各位听众朋友们，大家好！今天我们来聊聊人工智能的发展。",
  "chunks": [
    {
      "text": "各位听众朋友们，大家好！",
      "timestamp": [0.0, 2.5]
    },
    {
      "text": "今天我们来聊聊人工智能的发展。",
      "timestamp": [2.5, 5.2]
    }
  ]
}
```

> ⚠️ **Tips:** Specify `language` for better accuracy when you know the language. Use `chunk_level: "word"` for subtitle generation. `task: "translate"` converts any language to English text.

---

## Model Selection Decision Tree

### TTS (Text-to-Speech)

```
       Need voiceover?
            │
     ┌──────┴──────┐
     │             │
  Chinese/Asian   English/
  focused?        International?
     │             │
  MiniMax        ElevenLabs v3
  Speech 2.6     ($0.10/1K chars)
     │
  ┌──┴──┐
  │     │
Quality Speed
  │     │
  HD    Turbo
($0.05) ($0.03)
```

### Music Generation

```
    Need music?
        │
   ┌────┴────┐
   │         │
 With      Instrumental
 vocals?    only?
   │         │
 MiniMax    MiniMax Music v2
 Music v2   ($0.03) or
 ($0.03)    Sonauto ($0.075)
```

**Quick Decision:**
- 🏆 **Best Chinese TTS** → `minimax/speech-2.6-hd` ($0.05/1K chars)
- 🗣️ **Best English TTS** → `elevenlabs/tts/eleven-v3` ($0.10/1K chars)
- ⚡ **Fast + cheap TTS** → `minimax/speech-2.6-turbo` ($0.03/1K chars)
- 🌍 **Multi-language budget** → `chatterbox/multilingual` ($0.02/1K chars)
- 🎵 **Best music** → `minimax-music/v2` ($0.03/gen)
- 🎤 **Song with lyrics** → `minimax-music/v2` or `elevenlabs/music`
- 📝 **Transcription** → `whisper` (~$0.01/min) — cheapest, most languages
- 👥 **Multi-speaker transcription** → `elevenlabs/scribe` ($0.03/min)

## Voice Cloning

Clone a voice from a reference audio sample, then use the cloned voice for TTS. Ideal for preserving speaker identity across multilingual dubbing or character consistency.

```bash
bash scripts/voice-clone.sh [options]
```

### Basic Usage

```bash
# Clone voice + generate speech in one step
bash scripts/voice-clone.sh \
  --audio-url "https://example.com/speaker-sample.mp3" \
  --text "This is spoken in the cloned voice."

# Upload local reference audio
bash scripts/voice-clone.sh \
  --audio ./my-voice-sample.mp3 \
  --text "Hello from my cloned voice!"

# Clone only (get voice_id for later use)
bash scripts/voice-clone.sh \
  --audio-url "https://example.com/speaker-sample.mp3" \
  --clone-only

# Use existing voice_id
bash scripts/voice-clone.sh \
  --voice-id "abc123" \
  --text "Reuse a previously cloned voice."

# With speed and pitch adjustment
bash scripts/voice-clone.sh \
  --audio ./sample.mp3 \
  --text "Faster and higher pitched" \
  --speed 1.3 --pitch 2
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--audio-url` | Reference audio URL for cloning | - |
| `--audio` | Local reference audio file (auto-uploads) | - |
| `--text` | Text to synthesize (required unless `--clone-only`) | - |
| `--voice-id` | Existing voice ID (skip cloning step) | - |
| `--model`, `-m` | TTS model for speech generation | `fal-ai/minimax/speech-2.6-hd` |
| `--clone-only` | Only clone voice, output voice_id | off |
| `--speed` | Speech speed: 0.5–2.0 | 1.0 |
| `--pitch` | Pitch: -12 to 12 | 0 |
| `--output`, `-o` | Save audio to local path | - |

### Audio Requirements (for cloning)

- **Format**: mp3, wav, m4a
- **Duration**: 10 seconds – 5 minutes
- **Quality**: Clear speech, minimal background noise, single speaker preferred

### Workflow: Voice Clone → Lip Sync

A powerful combination for multilingual content:

```bash
# 1. Clone the original speaker's voice
bash scripts/voice-clone.sh \
  --audio ./original-speaker.mp3 \
  --clone-only
# → voice_id: abc123

# 2. Generate speech in another language with cloned voice
bash scripts/voice-clone.sh \
  --voice-id "abc123" \
  --text "这是用克隆声音说的中文" \
  --output ./dubbed-chinese.mp3

# 3. Dub the original video with new audio
bash ../aivp-lipsync/scripts/dub-video.sh \
  --video ./original-video.mp4 \
  --audio ./dubbed-chinese.mp3 \
  --output ./final-dubbed.mp4
```

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
