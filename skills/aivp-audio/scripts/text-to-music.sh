#!/bin/bash

# AIVP Text-to-Music Script
# Usage: ./text-to-music.sh --prompt "..." [--model MODEL] [--duration SECS]
# Returns: JSON with audio URL

set -e

FAL_QUEUE_ENDPOINT="https://queue.fal.run"

MODEL="fal-ai/minimax-music/v2"
PROMPT=""
DURATION=""
OUTPUT_PATH=""
MODE="queue"
POLL_INTERVAL=3
MAX_POLL_TIME=300

# Load .env
for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    [ -f "$envfile" ] && source "$envfile" 2>/dev/null || true
done

while [[ $# -gt 0 ]]; do
    case $1 in
        --prompt|-p) PROMPT="$2"; shift 2 ;;
        --model|-m) MODEL="$2"; shift 2 ;;
        --duration) DURATION="$2"; shift 2 ;;
        --output|-o) OUTPUT_PATH="$2"; shift 2 ;;
        --async) MODE="async"; shift ;;
        --help|-h)
            echo "AIVP Text-to-Music" >&2
            echo "Usage: ./text-to-music.sh --prompt \"...\" [--model MODEL]" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    exit 1
fi

if [ -z "$PROMPT" ]; then
    echo "Error: --prompt is required" >&2
    exit 1
fi

echo "Generating music with $MODEL..." >&2

# Build payload
PAYLOAD="{\"prompt\": \"$PROMPT\""
[ -n "$DURATION" ] && PAYLOAD="$PAYLOAD, \"duration\": $DURATION"
PAYLOAD="$PAYLOAD}"

HEADERS=(-H "Authorization: Key $FAL_KEY" -H "Content-Type: application/json")

# Submit to queue
SUBMIT=$(curl -s -X POST "$FAL_QUEUE_ENDPOINT/$MODEL" "${HEADERS[@]}" -d "$PAYLOAD")

REQUEST_ID=$(echo "$SUBMIT" | grep -oE '"request_id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
STATUS_URL=$(echo "$SUBMIT" | grep -oE '"status_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
RESPONSE_URL=$(echo "$SUBMIT" | grep -oE '"response_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')

if [ -z "$REQUEST_ID" ]; then
    echo "Error: No request_id" >&2; echo "$SUBMIT" >&2; exit 1
fi
echo "Request ID: $REQUEST_ID" >&2

if [ "$MODE" = "async" ]; then
    echo "Submitted. Check: status with --status" >&2
    echo "$SUBMIT"
    exit 0
fi

# Poll
ELAPSED=0
while [ $ELAPSED -lt $MAX_POLL_TIME ]; do
    sleep $POLL_INTERVAL
    ELAPSED=$((ELAPSED + POLL_INTERVAL))
    SR=$(curl -s -X GET "$STATUS_URL" "${HEADERS[@]}")
    STATUS=$(echo "$SR" | grep -oE '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
    echo "Status: $STATUS ($ELAPSED/${MAX_POLL_TIME}s)" >&2
    [ "$STATUS" = "COMPLETED" ] && break
    [ "$STATUS" = "FAILED" ] && { echo "Error: Failed" >&2; echo "$SR"; exit 1; }
done

if [ "$STATUS" != "COMPLETED" ]; then
    echo "Error: Timeout" >&2; exit 1
fi

RESULT=$(curl -s -X GET "$RESPONSE_URL" "${HEADERS[@]}")
AUDIO_URL=$(echo "$RESULT" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Music URL: $AUDIO_URL" >&2

if [ -n "$OUTPUT_PATH" ] && [ -n "$AUDIO_URL" ]; then
    curl -sL "$AUDIO_URL" -o "$OUTPUT_PATH"
    echo "Saved: $OUTPUT_PATH" >&2
fi

echo "$RESULT"
