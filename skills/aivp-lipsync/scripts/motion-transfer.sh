#!/bin/bash

# AIVP Motion Transfer (DreamActor) — Image + Driving Video → Motion-Transferred Video
# Usage: ./motion-transfer.sh --image-url URL --video-url URL [options]
# Returns: JSON with generated video URL
#
# Queue Mode (default): Submits to queue, polls for completion
# Async Mode: Returns request_id immediately

set -euo pipefail

FAL_QUEUE_ENDPOINT="https://queue.fal.run"
FAL_TOKEN_ENDPOINT="https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3"

# Defaults
MODEL="fal-ai/bytedance/dreamactor/v2"
IMAGE_URL=""
VIDEO_URL=""
IMAGE_FILE=""
VIDEO_FILE=""
TRIM_FIRST_SECOND=true
MODE="queue"
ACTION="generate"
REQUEST_ID=""
POLL_INTERVAL=5
MAX_POLL_TIME=600
SHOW_LOGS=false
OUTPUT_PATH=""

# ─── Help ────────────────────────────────────────────────────────────────────

show_help() {
    cat >&2 <<'EOF'
AIVP Motion Transfer (DreamActor)
  Transfer motion, expressions, and lip movements from a driving video onto
  a target character image.

Usage:
  ./motion-transfer.sh --image-url URL --video-url URL [options]
  ./motion-transfer.sh --image FILE --video FILE [options]

Inputs:
  --image-url       Target character image URL (required unless --image)
  --video-url       Driving video URL (required unless --video)
  --image           Local image file (auto-uploads to fal CDN)
  --video           Local video file (auto-uploads to fal CDN)

Options:
  --model, -m       Model ID (default: fal-ai/bytedance/dreamactor/v2)
  --no-trim         Don't trim first second of output (default: trims)
  --output, -o      Save video to local path

Mode:
  (default)         Queue — submit and poll until complete
  --async           Return request_id immediately
  --logs            Show logs while polling

Queue Operations:
  --status ID       Check queue status
  --result ID       Get completed result
  --cancel ID       Cancel a queued request

Advanced:
  --poll-interval   Seconds between status checks (default: 5)
  --timeout         Max wait time in seconds (default: 600)
  --add-fal-key     Setup FAL_KEY
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
        --image-url)     IMAGE_URL="$2";     shift 2 ;;
        --video-url)     VIDEO_URL="$2";     shift 2 ;;
        --image)         IMAGE_FILE="$2";    shift 2 ;;
        --video)         VIDEO_FILE="$2";    shift 2 ;;
        --model|-m)      MODEL="$2";         shift 2 ;;
        --no-trim)       TRIM_FIRST_SECOND=false; shift ;;
        --output|-o)     OUTPUT_PATH="$2";   shift 2 ;;
        --async)         MODE="async";       shift ;;
        --logs)          SHOW_LOGS=true;     shift ;;
        --status)        ACTION="status";  REQUEST_ID="$2"; shift 2 ;;
        --result)        ACTION="result";  REQUEST_ID="$2"; shift 2 ;;
        --cancel)        ACTION="cancel";  REQUEST_ID="$2"; shift 2 ;;
        --poll-interval) POLL_INTERVAL="$2"; shift 2 ;;
        --timeout)       MAX_POLL_TIME="$2"; shift 2 ;;
        --help|-h)       show_help ;;
        *)               echo "Warning: unknown option $1" >&2; shift ;;
    esac
done

# ─── Validate FAL_KEY ────────────────────────────────────────────────────────

if [ -z "${FAL_KEY:-}" ]; then
    echo "Error: FAL_KEY not set" >&2
    echo "Run: ./motion-transfer.sh --add-fal-key" >&2
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
        jpg|jpeg)   content_type="image/jpeg" ;;
        png)        content_type="image/png" ;;
        gif)        content_type="image/gif" ;;
        webp)       content_type="image/webp" ;;
        mp4)        content_type="video/mp4" ;;
        mov)        content_type="video/quicktime" ;;
        webm)       content_type="video/webm" ;;
        *)          content_type="application/octet-stream" ;;
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

# ─── Handle Local File Uploads ───────────────────────────────────────────────

if [ -n "$IMAGE_FILE" ]; then
    if [ ! -f "$IMAGE_FILE" ]; then
        echo "Error: Image file not found: $IMAGE_FILE" >&2
        exit 1
    fi
    IMAGE_URL=$(upload_file "$IMAGE_FILE")
fi

if [ -n "$VIDEO_FILE" ]; then
    if [ ! -f "$VIDEO_FILE" ]; then
        echo "Error: Video file not found: $VIDEO_FILE" >&2
        exit 1
    fi
    VIDEO_URL=$(upload_file "$VIDEO_FILE")
fi

# ─── Queue Operations ────────────────────────────────────────────────────────

case $ACTION in
    status)
        if [ -z "$REQUEST_ID" ]; then echo "Error: Request ID required" >&2; exit 1; fi
        logs_param=""
        [ "$SHOW_LOGS" = true ] && logs_param="?logs=1"
        echo "Checking status for $REQUEST_ID..." >&2
        response=$(curl -s -X GET "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID/status${logs_param}" "${HEADERS[@]}")
        status=$(echo "$response" | jq -r '.status // "UNKNOWN"')
        echo "Status: $status" >&2
        if [ "$status" = "IN_QUEUE" ]; then
            position=$(echo "$response" | jq -r '.queue_position // "?"')
            echo "Queue position: $position" >&2
        fi
        echo "$response"
        exit 0
        ;;
    result)
        if [ -z "$REQUEST_ID" ]; then echo "Error: Request ID required" >&2; exit 1; fi
        echo "Getting result for $REQUEST_ID..." >&2
        response=$(curl -s -X GET "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID" "${HEADERS[@]}")
        if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
            echo "Error: $(echo "$response" | jq -r '.message // .error')" >&2
            exit 1
        fi
        url=$(echo "$response" | jq -r '.video.url // .url // empty')
        [ -n "$url" ] && echo "Video URL: $url" >&2
        echo "$response"
        exit 0
        ;;
    cancel)
        if [ -z "$REQUEST_ID" ]; then echo "Error: Request ID required" >&2; exit 1; fi
        echo "Cancelling request $REQUEST_ID..." >&2
        curl -s -X PUT "$FAL_QUEUE_ENDPOINT/$MODEL/requests/$REQUEST_ID/cancel" "${HEADERS[@]}"
        exit 0
        ;;
esac

# ─── Validate Inputs ─────────────────────────────────────────────────────────

if [ -z "$IMAGE_URL" ]; then
    echo "Error: --image-url or --image is required" >&2
    exit 1
fi

if [ -z "$VIDEO_URL" ]; then
    echo "Error: --video-url or --video is required" >&2
    exit 1
fi

# ─── Build JSON Payload with jq ──────────────────────────────────────────────

PAYLOAD=$(jq -n \
    --arg image_url "$IMAGE_URL" \
    --arg video_url "$VIDEO_URL" \
    --argjson trim_first_second "$TRIM_FIRST_SECOND" \
    '{
        image_url: $image_url,
        video_url: $video_url,
        trim_first_second: $trim_first_second
    }')

# ─── Submit to Queue ─────────────────────────────────────────────────────────

echo "Submitting to queue: $MODEL..." >&2
echo "  Image: $IMAGE_URL" >&2
echo "  Video: $VIDEO_URL" >&2
echo "  Trim first second: $TRIM_FIRST_SECOND" >&2

submit_response=$(curl -s -X POST "$FAL_QUEUE_ENDPOINT/$MODEL" "${HEADERS[@]}" -d "$PAYLOAD")

if echo "$submit_response" | jq -e '.error' >/dev/null 2>&1; then
    echo "Error: $(echo "$submit_response" | jq -r '.message // .error')" >&2
    exit 1
fi

REQUEST_ID=$(echo "$submit_response" | jq -r '.request_id // empty')
STATUS_URL=$(echo "$submit_response" | jq -r '.status_url // empty')
RESPONSE_URL=$(echo "$submit_response" | jq -r '.response_url // empty')

if [ -z "$REQUEST_ID" ]; then
    echo "Error: Failed to get request_id" >&2
    echo "$submit_response" >&2
    exit 1
fi

echo "Request ID: $REQUEST_ID" >&2

# ─── Async Mode ──────────────────────────────────────────────────────────────

if [ "$MODE" = "async" ]; then
    echo "" >&2
    echo "Request submitted. Use these commands to check:" >&2
    echo "  Status: ./motion-transfer.sh --status \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "  Result: ./motion-transfer.sh --result \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "  Cancel: ./motion-transfer.sh --cancel \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "$submit_response"
    exit 0
fi

# ─── Poll Until Complete ─────────────────────────────────────────────────────

echo "Waiting for completion..." >&2

elapsed=0
last_status=""

while [ "$elapsed" -lt "$MAX_POLL_TIME" ]; do
    sleep "$POLL_INTERVAL"
    elapsed=$((elapsed + POLL_INTERVAL))

    logs_param=""
    [ "$SHOW_LOGS" = true ] && logs_param="?logs=1"

    status_response=$(curl -s -X GET "${STATUS_URL}${logs_param}" "${HEADERS[@]}")
    status=$(echo "$status_response" | jq -r '.status // "UNKNOWN"')

    if [ "$status" != "$last_status" ]; then
        case $status in
            IN_QUEUE)
                position=$(echo "$status_response" | jq -r '.queue_position // "?"')
                echo "Status: IN_QUEUE (position: $position) [${elapsed}s]" >&2
                ;;
            IN_PROGRESS)
                echo "Status: IN_PROGRESS [${elapsed}s]" >&2
                ;;
            COMPLETED)
                echo "Status: COMPLETED [${elapsed}s]" >&2
                ;;
            *)
                echo "Status: $status [${elapsed}s]" >&2
                ;;
        esac
        last_status="$status"
    fi

    if [ "$SHOW_LOGS" = true ]; then
        echo "$status_response" | jq -r '.logs[]?.message // empty' 2>/dev/null | while read -r log; do
            echo "  > $log" >&2
        done
    fi

    if [ "$status" = "COMPLETED" ]; then break; fi

    if [ "$status" = "FAILED" ]; then
        echo "Error: Motion transfer failed" >&2
        echo "$status_response" | jq -r '.error // empty' >&2
        echo "$status_response"
        exit 1
    fi
done

if [ "$status" != "COMPLETED" ]; then
    echo "Error: Timeout after ${MAX_POLL_TIME}s" >&2
    echo "Check manually: ./motion-transfer.sh --status \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    exit 1
fi

# ─── Get Final Result ─────────────────────────────────────────────────────────

echo "Fetching result..." >&2
result=$(curl -s -X GET "$RESPONSE_URL" "${HEADERS[@]}")

if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
    echo "Error: $(echo "$result" | jq -r '.message // .error')" >&2
    exit 1
fi

video_url=$(echo "$result" | jq -r '.video.url // .url // empty')

echo "" >&2
echo "Motion transfer complete!" >&2
[ -n "$video_url" ] && echo "Video URL: $video_url" >&2

# Download if --output specified
if [ -n "$OUTPUT_PATH" ] && [ -n "$video_url" ]; then
    echo "Downloading to $OUTPUT_PATH..." >&2
    curl -sL "$video_url" -o "$OUTPUT_PATH"
    echo "Saved: $OUTPUT_PATH" >&2
fi

echo "$result"
