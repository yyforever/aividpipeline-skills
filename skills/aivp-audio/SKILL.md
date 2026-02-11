---
name: aivp-audio
description: >
  Generate voiceover, background music, and sound effects for AI video production.
  Use when user requests "voiceover", "narration", "text to speech", "TTS",
  "background music", "BGM", "sound effects", "audio generation",
  or needs to create audio tracks for video content including
  voice narration, music, and SFX.
---

# AIVidPipeline Audio

Generate voiceover, BGM, and sound effects for AI video production.

<!-- TODO: Implement all sections below -->

## References

- [Audio Models](references/models.md) — TTS, music, and SFX model comparison

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/tts.sh` | Text-to-speech voiceover generation |
| `scripts/music.sh` | Background music generation |

## Voiceover (TTS)

<!-- TODO: Implement TTS workflow -->

1. Take narration text from script sections
2. Select voice (style, language, speed)
3. Generate audio segments per section
4. Generate SRT subtitle file from timestamps
5. Output audio files + subtitle file

### Supported TTS Models

| Model | Quality | Languages | API |
|-------|---------|-----------|-----|
| ElevenLabs v3 | ⭐⭐⭐⭐⭐ | 32 | ElevenLabs |
| MiniMax Speech 2.6 HD | ⭐⭐⭐⭐⭐ | 17 | fal.ai |
| Edge TTS | ⭐⭐⭐ | 60+ | Free (Microsoft) |
| Chatterbox | ⭐⭐⭐⭐ | Multi | fal.ai |

## Background Music

<!-- TODO: Implement music generation workflow -->

1. Determine mood/genre from script and storyboard
2. Generate music track matching video duration
3. Output music file

### Supported Music Models

| Model | Best For | API |
|-------|----------|-----|
| MiniMax Music v2 | General BGM | fal.ai |
| ElevenLabs Music | Songs with vocals | fal.ai |
| Sonauto v2 | Instrumental | fal.ai |
| Beatoven | Background music | fal.ai |

## Sound Effects

<!-- TODO: Implement SFX approach -->
<!-- TODO: Seedance 2.0 native audio — may eliminate need for separate SFX -->

## Output Format

```
output/
├── voiceover.mp3       # Full narration track
├── voiceover.srt       # Subtitle file
├── bgm.mp3             # Background music
└── segments/           # Per-section audio
    ├── 001_hook.mp3
    ├── 002_body.mp3
    └── 003_cta.mp3
```
