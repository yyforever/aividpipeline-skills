#!/bin/bash

# AIVP Speech-to-Text Script
# Usage: ./speech-to-text.sh --audio-url "..." [--model MODEL] [--language LANG]
# Returns: JSON with transcription

set -e

FAL_API_ENDPOINT="https://fal.run"

MODEL="fal-ai/whisper"
AUDIO_URL=""
LANGUAGE=""

# Load .env
for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    [ -f "$envfile" ] && source "$envfile" 2>/dev/null || true
done

while [[ $# -gt 0 ]]; do
    case $1 in
        --audio-url) AUDIO_URL="$2"; shift 2 ;;
        --model) MODEL="$2"; shift 2 ;;
        --language) LANGUAGE="$2"; shift 2 ;;
        --help|-h)
            echo "AIVP Speech-to-Text" >&2
            echo "Usage: ./speech-to-text.sh --audio-url \"...\" [--model MODEL]" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    exit 1
fi

if [ -z "$AUDIO_URL" ]; then
    echo "Error: --audio-url is required" >&2
    exit 1
fi

echo "Transcribing with $MODEL..." >&2

PAYLOAD="{\"audio_url\": \"$AUDIO_URL\""
[ -n "$LANGUAGE" ] && PAYLOAD="$PAYLOAD, \"language\": \"$LANGUAGE\""
PAYLOAD="$PAYLOAD}"

RESPONSE=$(curl -s -X POST "$FAL_API_ENDPOINT/$MODEL" \
    -H "Authorization: Key $FAL_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

if echo "$RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Error: $ERROR_MSG" >&2
    exit 1
fi

echo "Transcription complete!" >&2
echo "$RESPONSE"
