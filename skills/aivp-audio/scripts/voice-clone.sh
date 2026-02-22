#!/bin/bash

# AIVP Voice Clone — Upload reference audio → Clone voice → TTS with cloned voice
# Usage: ./voice-clone.sh --audio-url URL --text "..." [options]
# Returns: JSON with cloned speech audio URL
#
# Two-step process:
#   1. Clone voice from reference audio (get voice_id)
#   2. Generate speech using cloned voice
#
# Or use --clone-only to just get the voice_id for later use.

set -euo pipefail

FAL_API_ENDPOINT="https://fal.run"
FAL_QUEUE_ENDPOINT="https://queue.fal.run"
FAL_TOKEN_ENDPOINT="https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3"

# Defaults
TTS_MODEL="fal-ai/minimax/speech-2.6-hd"
AUDIO_URL=""
AUDIO_FILE=""
TEXT=""
VOICE_ID=""
CLONE_ONLY=false
SPEED=""
PITCH=""
OUTPUT_PATH=""

# ─── Help ────────────────────────────────────────────────────────────────────

show_help() {
    cat >&2 <<'EOF'
AIVP Voice Clone
  Clone a voice from a reference audio sample, then generate speech using
  the cloned voice. Powered by ElevenLabs voice cloning via fal.ai.

Usage:
  Clone + TTS:
    ./voice-clone.sh --audio-url URL --text "Hello world" [options]
    ./voice-clone.sh --audio ./sample.mp3 --text "Hello world" [options]

  Clone only (get voice_id):
    ./voice-clone.sh --audio-url URL --clone-only

  TTS with existing voice_id:
    ./voice-clone.sh --voice-id ID --text "Hello world"

Inputs:
  --audio-url       Reference audio URL for voice cloning
  --audio           Local reference audio file (auto-uploads)
  --text            Text to synthesize (required unless --clone-only)
  --voice-id        Use existing voice ID (skip cloning step)

Options:
  --model, -m       TTS model (default: fal-ai/minimax/speech-2.6-hd)
  --clone-only      Only clone voice, don't generate speech
  --speed           Speech speed: 0.5–2.0 (default: 1.0)
  --pitch           Pitch adjustment: -12 to 12 (default: 0)
  --output, -o      Save audio to local path

Setup:
  --add-fal-key     Configure FAL_KEY

Supported TTS Models:
  fal-ai/minimax/speech-2.6-hd      Best quality (default)
  fal-ai/minimax/speech-2.6-turbo   Faster
  fal-ai/elevenlabs/eleven-v3       Natural voices

Audio Requirements (for cloning):
  - Format: mp3, wav, m4a
  - Duration: 10 seconds – 5 minutes
  - Clear speech, minimal background noise
  - Single speaker preferred
EOF
    exit 0
}

# ─── FAL Key Setup ───────────────────────────────────────────────────────────

for arg in "$@"; do
    if [ "$arg" = "--add-fal-key" ]; then
        shift
        KEY_VALUE="${1:-}"
        if [ -z "$KEY_VALUE" ]; then
            echo "Enter your fal.ai API key:" >&2
            read -r KEY_VALUE
        fi
        if [ -n "$KEY_VALUE" ]; then
            grep -v "^FAL_KEY=" .env > .env.tmp 2>/dev/null || true
            mv .env.tmp .env 2>/dev/null || true
            echo "FAL_KEY=$KEY_VALUE" >> .env
            echo "FAL_KEY saved to .env" >&2
        fi
        exit 0
    fi
done

# ─── Load .env ───────────────────────────────────────────────────────────────

for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    if [ -f "$envfile" ]; then
        # shellcheck disable=SC1090
        source "$envfile" 2>/dev/null || true
    fi
done

# ─── Parse Arguments ─────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case $1 in
        --audio-url)   AUDIO_URL="$2";    shift 2 ;;
        --audio)       AUDIO_FILE="$2";   shift 2 ;;
        --text)        TEXT="$2";         shift 2 ;;
        --voice-id)    VOICE_ID="$2";    shift 2 ;;
        --model|-m)    TTS_MODEL="$2";   shift 2 ;;
        --clone-only)  CLONE_ONLY=true;  shift ;;
        --speed)       SPEED="$2";       shift 2 ;;
        --pitch)       PITCH="$2";       shift 2 ;;
        --output|-o)   OUTPUT_PATH="$2"; shift 2 ;;
        --help|-h)     show_help ;;
        *)             echo "Warning: unknown option $1" >&2; shift ;;
    esac
done

# ─── Validate FAL_KEY ────────────────────────────────────────────────────────

if [ -z "${FAL_KEY:-}" ]; then
    echo "Error: FAL_KEY not set" >&2
    echo "Run: ./voice-clone.sh --add-fal-key" >&2
    echo "Or:  export FAL_KEY=your_key_here" >&2
    exit 1
fi

HEADERS=(-H "Authorization: Key $FAL_KEY" -H "Content-Type: application/json")

# ─── File Upload Helper ──────────────────────────────────────────────────────

upload_file() {
    local file_path="$1"
    local filename
    filename=$(basename "$file_path")
    local ext="${filename##*.}"
    local ext_lower
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    local content_type
    case "$ext_lower" in
        mp3)  content_type="audio/mpeg" ;;
        wav)  content_type="audio/wav" ;;
        m4a)  content_type="audio/mp4" ;;
        ogg)  content_type="audio/ogg" ;;
        aac)  content_type="audio/aac" ;;
        *)    content_type="application/octet-stream" ;;
    esac

    echo "Uploading $filename..." >&2

    local token_response
    token_response=$(curl -s -X POST "$FAL_TOKEN_ENDPOINT" \
        -H "Authorization: Key $FAL_KEY" \
        -H "Content-Type: application/json" \
        -d '{}')

    local cdn_token cdn_token_type cdn_base_url
    cdn_token=$(echo "$token_response" | jq -r '.token // empty')
    cdn_token_type=$(echo "$token_response" | jq -r '.token_type // empty')
    cdn_base_url=$(echo "$token_response" | jq -r '.base_url // empty')

    if [ -z "$cdn_token" ] || [ -z "$cdn_base_url" ]; then
        echo "Error: Failed to get CDN token" >&2
        return 1
    fi

    local upload_response
    upload_response=$(curl -s -X POST "${cdn_base_url}/files/upload" \
        -H "Authorization: $cdn_token_type $cdn_token" \
        -H "Content-Type: $content_type" \
        -H "X-Fal-File-Name: $filename" \
        --data-binary "@$file_path")

    local access_url
    access_url=$(echo "$upload_response" | jq -r '.access_url // empty')

    if [ -z "$access_url" ]; then
        local error_msg
        error_msg=$(echo "$upload_response" | jq -r '.message // "Unknown upload error"')
        echo "Upload error: $error_msg" >&2
        return 1
    fi

    echo "Uploaded: $access_url" >&2
    echo "$access_url"
}

# ─── Handle Local File Upload ────────────────────────────────────────────────

if [ -n "$AUDIO_FILE" ]; then
    if [ ! -f "$AUDIO_FILE" ]; then
        echo "Error: Audio file not found: $AUDIO_FILE" >&2
        exit 1
    fi
    AUDIO_URL=$(upload_file "$AUDIO_FILE")
fi

# ─── Validate Inputs ─────────────────────────────────────────────────────────

if [ -z "$VOICE_ID" ] && [ -z "$AUDIO_URL" ]; then
    echo "Error: --audio-url, --audio, or --voice-id is required" >&2
    echo "Provide a reference audio to clone, or an existing voice ID." >&2
    exit 1
fi

if [ "$CLONE_ONLY" = false ] && [ -z "$TEXT" ]; then
    echo "Error: --text is required (or use --clone-only)" >&2
    exit 1
fi

# ─── Step 1: Voice Cloning (if no voice_id provided) ─────────────────────────

if [ -z "$VOICE_ID" ]; then
    echo "Step 1: Cloning voice from reference audio..." >&2
    echo "  Audio: $AUDIO_URL" >&2

    clone_payload=$(jq -n \
        --arg audio_url "$AUDIO_URL" \
        '{audio_url: $audio_url}')

    clone_response=$(curl -s -X POST "$FAL_API_ENDPOINT/fal-ai/elevenlabs/voice-clone/instant" \
        "${HEADERS[@]}" -d "$clone_payload")

    if echo "$clone_response" | jq -e '.error' >/dev/null 2>&1; then
        echo "Error: Voice cloning failed" >&2
        echo "  $(echo "$clone_response" | jq -r '.message // .error')" >&2
        exit 1
    fi

    VOICE_ID=$(echo "$clone_response" | jq -r '.voice_id // empty')

    if [ -z "$VOICE_ID" ]; then
        echo "Error: Failed to get voice_id from clone response" >&2
        echo "$clone_response" >&2
        exit 1
    fi

    echo "Voice cloned! voice_id: $VOICE_ID" >&2

    # Clone-only mode — output and exit
    if [ "$CLONE_ONLY" = true ]; then
        echo "" >&2
        echo "Use this voice_id for TTS:" >&2
        echo "  ./voice-clone.sh --voice-id \"$VOICE_ID\" --text \"Your text\"" >&2
        echo "  ./text-to-speech.sh --voice \"$VOICE_ID\" --text \"Your text\"" >&2
        echo "$clone_response"
        exit 0
    fi
fi

# ─── Step 2: TTS with Cloned Voice ───────────────────────────────────────────

echo "Step 2: Generating speech with cloned voice..." >&2
echo "  Model: $TTS_MODEL" >&2
echo "  Voice: $VOICE_ID" >&2

tts_payload=$(jq -n \
    --arg text "$TEXT" \
    --arg voice "$VOICE_ID" \
    '{text: $text, voice: $voice}')

# Add optional parameters
if [ -n "$SPEED" ]; then
    tts_payload=$(echo "$tts_payload" | jq --argjson speed "$SPEED" '. + {speed: $speed}')
fi
if [ -n "$PITCH" ]; then
    tts_payload=$(echo "$tts_payload" | jq --argjson pitch "$PITCH" '. + {pitch: $pitch}')
fi

tts_response=$(curl -s -X POST "$FAL_API_ENDPOINT/$TTS_MODEL" \
    "${HEADERS[@]}" -d "$tts_payload")

if echo "$tts_response" | jq -e '.error' >/dev/null 2>&1; then
    echo "Error: TTS generation failed" >&2
    echo "  $(echo "$tts_response" | jq -r '.message // .error')" >&2
    exit 1
fi

audio_url=$(echo "$tts_response" | jq -r '.audio.url // .url // empty')

echo "" >&2
echo "Voice clone + TTS complete!" >&2
echo "  Voice ID: $VOICE_ID" >&2
[ -n "$audio_url" ] && echo "  Audio URL: $audio_url" >&2

# Download if --output specified
if [ -n "$OUTPUT_PATH" ] && [ -n "$audio_url" ]; then
    echo "Downloading to $OUTPUT_PATH..." >&2
    curl -sL "$audio_url" -o "$OUTPUT_PATH"
    echo "Saved: $OUTPUT_PATH" >&2
fi

# Merge voice_id into output for downstream use
echo "$tts_response" | jq --arg voice_id "$VOICE_ID" '. + {voice_id: $voice_id}'
