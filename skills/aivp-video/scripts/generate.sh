#!/bin/bash

# AIVP Video Generation Script with Queue Support
# Usage: ./generate.sh --prompt "..." [--model MODEL] [options]
# Returns: JSON with generated video URLs
#
# Queue Mode (default): Submits to queue, polls for completion
# Async Mode: Returns request_id immediately
# Sync Mode: Direct request (not recommended for video)

set -e

FAL_QUEUE_ENDPOINT="https://queue.fal.run"
FAL_SYNC_ENDPOINT="https://fal.run"
FAL_TOKEN_ENDPOINT="https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3"

# Default values
MODEL="fal-ai/bytedance/seedance/v1.5/pro"
PROMPT=""
IMAGE_URL=""
IMAGE_FILE=""
ASPECT_RATIO="16:9"
DURATION=""
SEED=""
MODE="queue"  # queue (default), async, sync
REQUEST_ID=""
ACTION="generate"  # generate, status, result, cancel
POLL_INTERVAL=3
MAX_POLL_TIME=600
SHOW_LOGS=false
OUTPUT_PATH=""

# Check for --add-fal-key first
for arg in "$@"; do
    if [ "$arg" = "--add-fal-key" ]; then
        shift
        KEY_VALUE=""
        if [[ -n "$1" && ! "$1" =~ ^-- ]]; then
            KEY_VALUE="$1"
        fi
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

# Load .env if exists (check multiple locations)
for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    if [ -f "$envfile" ]; then
        source "$envfile" 2>/dev/null || true
    fi
done

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --prompt|-p)
            PROMPT="$2"
            shift 2
            ;;
        --model|-m)
            MODEL="$2"
            shift 2
            ;;
        --image-url)
            IMAGE_URL="$2"
            shift 2
            ;;
        --file|--image)
            IMAGE_FILE="$2"
            shift 2
            ;;
        --aspect-ratio)
            ASPECT_RATIO="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        --seed)
            SEED="$2"
            shift 2
            ;;
        --output|-o)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        # Mode options
        --async)
            MODE="async"
            shift
            ;;
        --sync)
            MODE="sync"
            shift
            ;;
        --logs)
            SHOW_LOGS=true
            shift
            ;;
        # Queue operations
        --status)
            ACTION="status"
            REQUEST_ID="$2"
            shift 2
            ;;
        --result)
            ACTION="result"
            REQUEST_ID="$2"
            shift 2
            ;;
        --cancel)
            ACTION="cancel"
            REQUEST_ID="$2"
            shift 2
            ;;
        # Polling options
        --poll-interval)
            POLL_INTERVAL="$2"
            shift 2
            ;;
        --timeout)
            MAX_POLL_TIME="$2"
            shift 2
            ;;
        # Provider selection (future: replicate, local)
        --provider)
            PROVIDER="$2"
            shift 2
            ;;
        # Schema lookup
        --schema)
            SCHEMA_MODEL="${2:-$MODEL}"
            ENCODED=$(echo "$SCHEMA_MODEL" | sed 's/\//%2F/g')
            echo "Fetching schema for $SCHEMA_MODEL..." >&2
            curl -s "https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=$ENCODED"
            exit 0
            ;;
        --help|-h)
            echo "AIVP Video Generation Script (Queue-based)" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./generate.sh --prompt \"...\" [options]" >&2
            echo "" >&2
            echo "Generation:" >&2
            echo "  --prompt, -p      Text description (required)" >&2
            echo "  --model, -m       Model ID (default: seedance/v1.5/pro)" >&2
            echo "  --image-url       Input image URL for I2V" >&2
            echo "  --file, --image   Local file (auto-uploads)" >&2
            echo "  --aspect-ratio    16:9, 9:16, 1:1 (default: 16:9)" >&2
            echo "  --duration        Target duration in seconds" >&2
            echo "  --seed            Random seed for reproducibility" >&2
            echo "  --output, -o      Save video to local path" >&2
            echo "" >&2
            echo "Mode:" >&2
            echo "  (default)         Queue — submit and poll until complete" >&2
            echo "  --async           Return request_id immediately" >&2
            echo "  --sync            Synchronous (not recommended)" >&2
            echo "  --logs            Show logs while polling" >&2
            echo "" >&2
            echo "Queue Operations:" >&2
            echo "  --status ID       Check status" >&2
            echo "  --result ID       Get result" >&2
            echo "  --cancel ID       Cancel request" >&2
            echo "" >&2
            echo "Advanced:" >&2
            echo "  --poll-interval   Seconds between checks (default: 3)" >&2
            echo "  --timeout         Max wait seconds (default: 600)" >&2
            echo "  --schema [MODEL]  Get OpenAPI schema" >&2
            echo "  --add-fal-key     Setup FAL_KEY" >&2
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Validate FAL_KEY
if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    echo "" >&2
    echo "Run: ./generate.sh --add-fal-key" >&2
    echo "Or:  export FAL_KEY=your_key_here" >&2
    exit 1
fi

# --- File Upload Helper ---
upload_file() {
    local FILE_PATH="$1"
    local FILENAME=$(basename "$FILE_PATH")
    local EXTENSION="${FILENAME##*.}"
    local EXT_LOWER=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

    case "$EXT_LOWER" in
        jpg|jpeg) CONTENT_TYPE="image/jpeg" ;;
        png) CONTENT_TYPE="image/png" ;;
        gif) CONTENT_TYPE="image/gif" ;;
        webp) CONTENT_TYPE="image/webp" ;;
        mp4) CONTENT_TYPE="video/mp4" ;;
        mov) CONTENT_TYPE="video/quicktime" ;;
        *) CONTENT_TYPE="application/octet-stream" ;;
    esac

    echo "Uploading $FILENAME..." >&2

    # Step 1: Get CDN token
    local TOKEN_RESPONSE=$(curl -s -X POST "$FAL_TOKEN_ENDPOINT" \
        -H "Authorization: Key $FAL_KEY" \
        -H "Content-Type: application/json" \
        -d '{}')

    local CDN_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    local CDN_TOKEN_TYPE=$(echo "$TOKEN_RESPONSE" | grep -o '"token_type":"[^"]*"' | cut -d'"' -f4)
    local CDN_BASE_URL=$(echo "$TOKEN_RESPONSE" | grep -o '"base_url":"[^"]*"' | cut -d'"' -f4)

    if [ -z "$CDN_TOKEN" ] || [ -z "$CDN_BASE_URL" ]; then
        echo "Error: Failed to get CDN token" >&2
        return 1
    fi

    # Step 2: Upload file
    local UPLOAD_RESPONSE=$(curl -s -X POST "${CDN_BASE_URL}/files/upload" \
        -H "Authorization: $CDN_TOKEN_TYPE $CDN_TOKEN" \
        -H "Content-Type: $CONTENT_TYPE" \
        -H "X-Fal-File-Name: $FILENAME" \
        --data-binary "@$FILE_PATH")

    if echo "$UPLOAD_RESPONSE" | grep -q '"error"'; then
        local ERROR_MSG=$(echo "$UPLOAD_RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "Upload error: $ERROR_MSG" >&2
        return 1
    fi

    local ACCESS_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"access_url":"[^"]*"' | cut -d'"' -f4)
    if [ -z "$ACCESS_URL" ]; then
        echo "Error: Failed to get URL from upload" >&2
        return 1
    fi

    echo "Uploaded: $ACCESS_URL" >&2
    echo "$ACCESS_URL"
}

# Handle local file upload
if [ -n "$IMAGE_FILE" ]; then
    if [ ! -f "$IMAGE_FILE" ]; then
        echo "Error: File not found: $IMAGE_FILE" >&2
        exit 1
    fi
    IMAGE_URL=$(upload_file "$IMAGE_FILE")
fi

# Build headers
HEADERS=(-H "Authorization: Key $FAL_KEY" -H "Content-Type: application/json")

# --- Queue Operations ---
case $ACTION in
    status)
        if [ -z "$REQUEST_ID" ]; then
            echo "Error: Request ID required for --status" >&2
            exit 1
        fi
        LOGS_PARAM=""
        if [ "$SHOW_LOGS" = true ]; then
            LOGS_PARAM="?logs=1"
        fi
        echo "Checking status for $REQUEST_ID..." >&2
        RESPONSE=$(curl -s -X GET "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID/status$LOGS_PARAM" "${HEADERS[@]}")
        STATUS=$(echo "$RESPONSE" | grep -oE '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
        echo "Status: $STATUS" >&2
        if [ "$STATUS" = "IN_QUEUE" ]; then
            POSITION=$(echo "$RESPONSE" | grep -o '"queue_position":[0-9]*' | cut -d':' -f2)
            [ -n "$POSITION" ] && echo "Queue position: $POSITION" >&2
        fi
        echo "$RESPONSE"
        exit 0
        ;;
    result)
        if [ -z "$REQUEST_ID" ]; then
            echo "Error: Request ID required for --result" >&2
            exit 1
        fi
        echo "Getting result for $REQUEST_ID..." >&2
        RESPONSE=$(curl -s -X GET "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID" "${HEADERS[@]}")
        if echo "$RESPONSE" | grep -q '"error"'; then
            ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
            echo "Error: $ERROR_MSG" >&2
            exit 1
        fi
        URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
        [ -n "$URL" ] && echo "Video URL: $URL" >&2
        echo "$RESPONSE"
        exit 0
        ;;
    cancel)
        if [ -z "$REQUEST_ID" ]; then
            echo "Error: Request ID required for --cancel" >&2
            exit 1
        fi
        echo "Cancelling request $REQUEST_ID..." >&2
        RESPONSE=$(curl -s -X PUT "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID/cancel" "${HEADERS[@]}")
        echo "$RESPONSE"
        exit 0
        ;;
esac

# --- Generate ---
if [ -z "$PROMPT" ]; then
    echo "Error: --prompt is required" >&2
    exit 1
fi

# Build payload based on model type
build_payload() {
    local PAYLOAD_PARTS=()
    PAYLOAD_PARTS+=("\"prompt\": \"$PROMPT\"")

    # Image-to-video models
    if [[ "$MODEL" == *"image-to-video"* ]] || [[ "$MODEL" == *"i2v"* ]]; then
        if [ -z "$IMAGE_URL" ]; then
            echo "Error: --image-url or --file required for image-to-video models" >&2
            exit 1
        fi
        PAYLOAD_PARTS+=("\"image_url\": \"$IMAGE_URL\"")
    fi

    # Optional fields
    [ -n "$DURATION" ] && PAYLOAD_PARTS+=("\"duration\": $DURATION")
    [ -n "$SEED" ] && PAYLOAD_PARTS+=("\"seed\": $SEED")

    # Aspect ratio (model-specific field names)
    if [[ "$MODEL" == *"seedance"* ]]; then
        PAYLOAD_PARTS+=("\"aspect_ratio\": \"$ASPECT_RATIO\"")
    elif [[ "$MODEL" == *"kling"* ]]; then
        PAYLOAD_PARTS+=("\"aspect_ratio\": \"$ASPECT_RATIO\"")
    fi

    local IFS=","
    echo "{${PAYLOAD_PARTS[*]}}"
}

PAYLOAD=$(build_payload)

# Sync mode
if [ "$MODE" = "sync" ]; then
    echo "Generating with $MODEL (sync mode)..." >&2
    RESPONSE=$(curl -s -X POST "$FAL_SYNC_ENDPOINT/$MODEL" "${HEADERS[@]}" -d "$PAYLOAD")
    if echo "$RESPONSE" | grep -q '"error"'; then
        ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "Error: $ERROR_MSG" >&2
        exit 1
    fi
    echo "Generation complete!" >&2
    URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
    [ -n "$URL" ] && echo "Video URL: $URL" >&2
    echo "$RESPONSE"
    exit 0
fi

# Queue mode
echo "Submitting to queue: $MODEL..." >&2

SUBMIT_RESPONSE=$(curl -s -X POST "$FAL_QUEUE_ENDPOINT/$MODEL" "${HEADERS[@]}" -d "$PAYLOAD")

if echo "$SUBMIT_RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$SUBMIT_RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Error: $ERROR_MSG" >&2
    exit 1
fi

REQUEST_ID=$(echo "$SUBMIT_RESPONSE" | grep -oE '"request_id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
STATUS_URL=$(echo "$SUBMIT_RESPONSE" | grep -oE '"status_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')
RESPONSE_URL=$(echo "$SUBMIT_RESPONSE" | grep -oE '"response_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')

if [ -z "$REQUEST_ID" ]; then
    echo "Error: Failed to get request_id" >&2
    echo "$SUBMIT_RESPONSE" >&2
    exit 1
fi

echo "Request ID: $REQUEST_ID" >&2

# Async mode — return immediately
if [ "$MODE" = "async" ]; then
    echo "" >&2
    echo "Request submitted. Use these commands to check:" >&2
    echo "  Status: ./generate.sh --status \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "  Result: ./generate.sh --result \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "  Cancel: ./generate.sh --cancel \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "$SUBMIT_RESPONSE"
    exit 0
fi

# Poll until complete
echo "Waiting for completion..." >&2

ELAPSED=0
LAST_STATUS=""

while [ $ELAPSED -lt $MAX_POLL_TIME ]; do
    sleep $POLL_INTERVAL
    ELAPSED=$((ELAPSED + POLL_INTERVAL))

    LOGS_PARAM=""
    if [ "$SHOW_LOGS" = true ]; then
        LOGS_PARAM="?logs=1"
    fi

    STATUS_RESPONSE=$(curl -s -X GET "${STATUS_URL}${LOGS_PARAM}" "${HEADERS[@]}")
    STATUS=$(echo "$STATUS_RESPONSE" | grep -oE '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//')

    if [ "$STATUS" != "$LAST_STATUS" ]; then
        case $STATUS in
            IN_QUEUE)
                POSITION=$(echo "$STATUS_RESPONSE" | grep -o '"queue_position":[0-9]*' | cut -d':' -f2)
                echo "Status: IN_QUEUE (position: ${POSITION:-?})" >&2
                ;;
            IN_PROGRESS)
                echo "Status: IN_PROGRESS" >&2
                ;;
            COMPLETED)
                echo "Status: COMPLETED" >&2
                ;;
            *)
                echo "Status: $STATUS" >&2
                ;;
        esac
        LAST_STATUS="$STATUS"
    fi

    if [ "$SHOW_LOGS" = true ]; then
        LOGS=$(echo "$STATUS_RESPONSE" | grep -o '"logs":\[[^]]*\]' | head -1)
        if [ -n "$LOGS" ] && [ "$LOGS" != "[]" ]; then
            echo "$LOGS" | tr ',' '\n' | grep -o '"message":"[^"]*"' | cut -d'"' -f4 | while read -r log; do
                echo "  > $log" >&2
            done
        fi
    fi

    if [ "$STATUS" = "COMPLETED" ]; then
        break
    fi

    if [ "$STATUS" = "FAILED" ]; then
        echo "Error: Generation failed" >&2
        echo "$STATUS_RESPONSE"
        exit 1
    fi
done

if [ "$STATUS" != "COMPLETED" ]; then
    echo "Error: Timeout after ${MAX_POLL_TIME}s" >&2
    echo "Request ID: $REQUEST_ID" >&2
    echo "Check manually: ./generate.sh --status \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    exit 1
fi

# Get final result
echo "Fetching result..." >&2
RESULT=$(curl -s -X GET "$RESPONSE_URL" "${HEADERS[@]}")

if echo "$RESULT" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$RESULT" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Error: $ERROR_MSG" >&2
    exit 1
fi

echo "" >&2
echo "Generation complete!" >&2

URL=$(echo "$RESULT" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$URL" ] && echo "Video URL: $URL" >&2

# Download if --output specified
if [ -n "$OUTPUT_PATH" ] && [ -n "$URL" ]; then
    echo "Downloading to $OUTPUT_PATH..." >&2
    curl -sL "$URL" -o "$OUTPUT_PATH"
    echo "Saved: $OUTPUT_PATH" >&2
fi

echo "$RESULT"
