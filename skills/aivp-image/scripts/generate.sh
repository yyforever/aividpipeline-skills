#!/bin/bash

# AIVP Image Generation Script with Queue Support
# Usage: ./generate.sh --prompt "..." [--model MODEL] [options]
# Returns: JSON with generated image URLs
#
# Shares the same fal.ai queue infrastructure as aivp-video.

set -e

FAL_QUEUE_ENDPOINT="https://queue.fal.run"
FAL_SYNC_ENDPOINT="https://fal.run"
FAL_TOKEN_ENDPOINT="https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3"

# Default values
MODEL="fal-ai/nano-banana-pro"
PROMPT=""
IMAGE_URL=""
IMAGE_FILE=""
IMAGE_SIZE="landscape_4_3"
NUM_IMAGES=1
SEED=""
MODE="queue"
REQUEST_ID=""
ACTION="generate"
POLL_INTERVAL=2
MAX_POLL_TIME=120
OUTPUT_PATH=""

# Check for --add-fal-key first
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

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --prompt|-p) PROMPT="$2"; shift 2 ;;
        --model|-m) MODEL="$2"; shift 2 ;;
        --image-url) IMAGE_URL="$2"; shift 2 ;;
        --file|--image) IMAGE_FILE="$2"; shift 2 ;;
        --size)
            case $2 in
                square) IMAGE_SIZE="square" ;;
                portrait) IMAGE_SIZE="portrait_4_3" ;;
                landscape) IMAGE_SIZE="landscape_4_3" ;;
                *) IMAGE_SIZE="$2" ;;
            esac
            shift 2
            ;;
        --num-images) NUM_IMAGES="$2"; shift 2 ;;
        --seed) SEED="$2"; shift 2 ;;
        --output|-o) OUTPUT_PATH="$2"; shift 2 ;;
        --async) MODE="async"; shift ;;
        --sync) MODE="sync"; shift ;;
        --status) ACTION="status"; REQUEST_ID="$2"; shift 2 ;;
        --result) ACTION="result"; REQUEST_ID="$2"; shift 2 ;;
        --cancel) ACTION="cancel"; REQUEST_ID="$2"; shift 2 ;;
        --poll-interval) POLL_INTERVAL="$2"; shift 2 ;;
        --timeout) MAX_POLL_TIME="$2"; shift 2 ;;
        --schema)
            SCHEMA_MODEL="${2:-$MODEL}"
            ENCODED=$(echo "$SCHEMA_MODEL" | sed 's/\//%2F/g')
            curl -s "https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=$ENCODED"
            exit 0
            ;;
        --help|-h)
            echo "AIVP Image Generation Script" >&2
            echo "Usage: ./generate.sh --prompt \"...\" [options]" >&2
            echo "" >&2
            echo "  --prompt, -p      Text description (required)" >&2
            echo "  --model, -m       Model (default: fal-ai/nano-banana-pro)" >&2
            echo "  --image-url       Input image for I2I" >&2
            echo "  --file            Local file (auto-uploads)" >&2
            echo "  --size            square, portrait, landscape" >&2
            echo "  --num-images      Number of images (default: 1)" >&2
            echo "  --seed            Random seed" >&2
            echo "  --output, -o      Save to local path" >&2
            echo "  --async           Return immediately" >&2
            echo "  --status ID       Check status" >&2
            echo "  --result ID       Get result" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

# Validate
if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set. Run: ./generate.sh --add-fal-key" >&2
    exit 1
fi

# Handle local file upload
if [ -n "$IMAGE_FILE" ]; then
    if [ ! -f "$IMAGE_FILE" ]; then
        echo "Error: File not found: $IMAGE_FILE" >&2
        exit 1
    fi
    FILENAME=$(basename "$IMAGE_FILE")
    EXT_LOWER=$(echo "${FILENAME##*.}" | tr '[:upper:]' '[:lower:]')
    case "$EXT_LOWER" in
        jpg|jpeg) CT="image/jpeg" ;; png) CT="image/png" ;; webp) CT="image/webp" ;; *) CT="application/octet-stream" ;;
    esac
    echo "Uploading $FILENAME..." >&2
    TR=$(curl -s -X POST "$FAL_TOKEN_ENDPOINT" -H "Authorization: Key $FAL_KEY" -H "Content-Type: application/json" -d '{}')
    CDN_TOKEN=$(echo "$TR" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    CDN_TT=$(echo "$TR" | grep -o '"token_type":"[^"]*"' | cut -d'"' -f4)
    CDN_URL=$(echo "$TR" | grep -o '"base_url":"[^"]*"' | cut -d'"' -f4)
    UR=$(curl -s -X POST "${CDN_URL}/files/upload" -H "Authorization: $CDN_TT $CDN_TOKEN" -H "Content-Type: $CT" -H "X-Fal-File-Name: $FILENAME" --data-binary "@$IMAGE_FILE")
    IMAGE_URL=$(echo "$UR" | grep -o '"access_url":"[^"]*"' | cut -d'"' -f4)
    echo "Uploaded: $IMAGE_URL" >&2
fi

HEADERS=(-H "Authorization: Key $FAL_KEY" -H "Content-Type: application/json")

# Queue operations
case $ACTION in
    status)
        curl -s -X GET "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID/status" "${HEADERS[@]}"
        exit 0 ;;
    result)
        curl -s -X GET "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID" "${HEADERS[@]}"
        exit 0 ;;
    cancel)
        curl -s -X PUT "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID/cancel" "${HEADERS[@]}"
        exit 0 ;;
esac

if [ -z "$PROMPT" ]; then
    echo "Error: --prompt is required" >&2
    exit 1
fi

# Build payload
PAYLOAD="{\"prompt\": \"$PROMPT\", \"image_size\": \"$IMAGE_SIZE\", \"num_images\": $NUM_IMAGES"
[ -n "$IMAGE_URL" ] && PAYLOAD="$PAYLOAD, \"image_url\": \"$IMAGE_URL\""
[ -n "$SEED" ] && PAYLOAD="$PAYLOAD, \"seed\": $SEED"
PAYLOAD="$PAYLOAD}"

# Sync mode
if [ "$MODE" = "sync" ]; then
    RESPONSE=$(curl -s -X POST "$FAL_SYNC_ENDPOINT/$MODEL" "${HEADERS[@]}" -d "$PAYLOAD")
    URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
    [ -n "$URL" ] && echo "Image URL: $URL" >&2
    echo "$RESPONSE"
    exit 0
fi

# Queue submit
echo "Submitting to queue: $MODEL..." >&2
SUBMIT=$(curl -s -X POST "$FAL_QUEUE_ENDPOINT/$MODEL" "${HEADERS[@]}" -d "$PAYLOAD")

REQUEST_ID=$(echo "$SUBMIT" | grep -oE '"request_id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
STATUS_URL=$(echo "$SUBMIT" | grep -oE '"status_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
RESPONSE_URL=$(echo "$SUBMIT" | grep -oE '"response_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')

if [ -z "$REQUEST_ID" ]; then
    echo "Error: No request_id" >&2; echo "$SUBMIT" >&2; exit 1
fi
echo "Request ID: $REQUEST_ID" >&2

if [ "$MODE" = "async" ]; then
    echo "Submitted. Check: ./generate.sh --status \"$REQUEST_ID\" --model \"$MODEL\"" >&2
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
URL=$(echo "$RESULT" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Image URL: $URL" >&2

if [ -n "$OUTPUT_PATH" ] && [ -n "$URL" ]; then
    curl -sL "$URL" -o "$OUTPUT_PATH"
    echo "Saved: $OUTPUT_PATH" >&2
fi

echo "$RESULT"
