#!/bin/bash

# AIVP Text-to-Speech Script
# Usage: ./text-to-speech.sh --text "..." [--model MODEL] [--voice VOICE]
# Returns: JSON with audio URL

set -e

FAL_API_ENDPOINT="https://fal.run"

MODEL="fal-ai/minimax/speech-2.6-turbo"
TEXT=""
VOICE=""
OUTPUT_PATH=""

# Check for --add-fal-key
for arg in "$@"; do
    if [ "$arg" = "--add-fal-key" ]; then
        shift
        KEY_VALUE=""
        if [[ -n "$1" && ! "$1" =~ ^-- ]]; then KEY_VALUE="$1"; fi
        if [ -z "$KEY_VALUE" ]; then echo "Enter your fal.ai API key:" >&2; read -r KEY_VALUE; fi
        if [ -n "$KEY_VALUE" ]; then
            grep -v "^FAL_KEY=" .env > .env.tmp 2>/dev/null || true
            mv .env.tmp .env 2>/dev/null || true
            echo "FAL_KEY=$KEY_VALUE" >> .env
            echo "FAL_KEY saved to .env" >&2
        fi
        exit 0
    fi
done

# Load .env
for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    [ -f "$envfile" ] && source "$envfile" 2>/dev/null || true
done

while [[ $# -gt 0 ]]; do
    case $1 in
        --text) TEXT="$2"; shift 2 ;;
        --model) MODEL="$2"; shift 2 ;;
        --voice) VOICE="$2"; shift 2 ;;
        --output|-o) OUTPUT_PATH="$2"; shift 2 ;;
        --help|-h)
            echo "AIVP Text-to-Speech" >&2
            echo "Usage: ./text-to-speech.sh --text \"...\" [--model MODEL] [--voice VOICE]" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    exit 1
fi

if [ -z "$TEXT" ]; then
    echo "Error: --text is required" >&2
    exit 1
fi

echo "Generating speech with $MODEL..." >&2

# Build payload
PAYLOAD="{\"text\": \"$TEXT\""
[ -n "$VOICE" ] && PAYLOAD="$PAYLOAD, \"voice\": \"$VOICE\""
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

AUDIO_URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Audio URL: $AUDIO_URL" >&2

if [ -n "$OUTPUT_PATH" ] && [ -n "$AUDIO_URL" ]; then
    curl -sL "$AUDIO_URL" -o "$OUTPUT_PATH"
    echo "Saved: $OUTPUT_PATH" >&2
fi

echo "$RESPONSE"
