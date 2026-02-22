#!/bin/bash

# AIVP Audio-to-Video (OmniHuman) — Image + Audio → Talking Video
# Usage: ./audio-to-video.sh --image-url URL --audio-url URL [options]
# Returns: JSON with generated video URL
#
# Queue Mode (default): Submits to queue, polls for completion
# Async Mode: Returns request_id immediately

set -euo pipefail

FAL_QUEUE_ENDPOINT="https://queue.fal.run"
FAL_TOKEN_ENDPOINT="https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3"

# Defaults
MODEL="fal-ai/bytedance/omnihuman/v1.5"
IMAGE_URL=""
AUDIO_URL=""
IMAGE_FILE=""
AUDIO_FILE=""
PROMPT=""
RESOLUTION="1080p"
TURBO_MODE=false
MODE="queue"      # queue (default), async
ACTION="generate" # generate, status, result, cancel
REQUEST_ID=""
POLL_INTERVAL=5
MAX_POLL_TIME=600
SHOW_LOGS=false
OUTPUT_PATH=""

# ─── Help ────────────────────────────────────────────────────────────────────

show_help() {
    cat >&2 <<'EOF'
AIVP Audio-to-Video (OmniHuman)
  Generate a talking video from a portrait image and audio clip.

Usage:
  ./audio-to-video.sh --image-url URL --audio-url URL [options]
  ./audio-to-video.sh --image FILE --audio FILE [options]

Inputs:
  --image-url       Portrait image URL (required unless --image)
  --audio-url       Audio file URL (required unless --audio)
  --image           Local image file (auto-uploads to fal CDN)
  --audio           Local audio file (auto-uploads to fal CDN)

Options:
  --model, -m       Model ID (default: fal-ai/bytedance/omnihuman/v1.5)
  --prompt, -p      Text prompt to guide generation style
  --resolution      720p or 1080p (default: 1080p)
  --turbo           Enable turbo mode (faster, slightly lower quality)
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

# ─── Parse Arguments ────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case $1 in
        --image-url)    IMAGE_URL="$2";     shift 2 ;;
        --audio-url)    AUDIO_URL="$2";     shift 2 ;;
        --image)        IMAGE_FILE="$2";    shift 2 ;;
        --audio)        AUDIO_FILE="$2";    shift 2 ;;
        --model|-m)     MODEL="$2";         shift 2 ;;
        --prompt|-p)    PROMPT="$2";        shift 2 ;;
        --resolution)   RESOLUTION="$2";    shift 2 ;;
        --turbo)        TURBO_MODE=true;    shift ;;
        --output|-o)    OUTPUT_PATH="$2";   shift 2 ;;
        --async)        MODE="async";       shift ;;
        --logs)         SHOW_LOGS=true;     shift ;;
        --status)       ACTION="status";  REQUEST_ID="$2"; shift 2 ;;
        --result)       ACTION="result";  REQUEST_ID="$2"; shift 2 ;;
        --cancel)       ACTION="cancel";  REQUEST_ID="$2"; shift 2 ;;
        --poll-interval) POLL_INTERVAL="$2"; shift 2 ;;
        --timeout)      MAX_POLL_TIME="$2"; shift 2 ;;
        --help|-h)      show_help ;;
        *)              echo "Warning: unknown option $1" >&2; shift ;;
    esac
done

# ─── Validate FAL_KEY ────────────────────────────────────────────────────────

if [ -z "${FAL_KEY:-}" ]; then
    echo "Error: FAL_KEY not set" >&2
    echo "Run: ./audio-to-video.sh --add-fal-key" >&2
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
        mp3)        content_type="audio/mpeg" ;;
        wav)        content_type="audio/wav" ;;
        m4a)        content_type="audio/mp4" ;;
        ogg)        content_type="audio/ogg" ;;
        aac)        content_type="audio/aac" ;;
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

if [ -n "$AUDIO_FILE" ]; then
    if [ ! -f "$AUDIO_FILE" ]; then
        echo "Error: Audio file not found: $AUDIO_FILE" >&2
        exit 1
    fi
    AUDIO_URL=$(upload_file "$AUDIO_FILE")
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

if [ -z "$AUDIO_URL" ]; then
    echo "Error: --audio-url or --audio is required" >&2
    exit 1
fi

# ─── Build JSON Payload with jq ──────────────────────────────────────────────

PAYLOAD=$(jq -n \
    --arg image_url "$IMAGE_URL" \
    --arg audio_url "$AUDIO_URL" \
    --arg resolution "$RESOLUTION" \
    --argjson turbo_mode "$TURBO_MODE" \
    '{
        image_url: $image_url,
        audio_url: $audio_url,
        resolution: $resolution,
        turbo_mode: $turbo_mode
    }')

# Add optional prompt
if [ -n "$PROMPT" ]; then
    PAYLOAD=$(echo "$PAYLOAD" | jq --arg prompt "$PROMPT" '. + {prompt: $prompt}')
fi

# ─── Submit to Queue ─────────────────────────────────────────────────────────

echo "Submitting to queue: $MODEL..." >&2
echo "  Image: $IMAGE_URL" >&2
echo "  Audio: $AUDIO_URL" >&2
echo "  Resolution: $RESOLUTION | Turbo: $TURBO_MODE" >&2

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
    echo "  Status: ./audio-to-video.sh --status \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "  Result: ./audio-to-video.sh --result \"$REQUEST_ID\" --model \"$MODEL\"" >&2
    echo "  Cancel: ./audio-to-video.sh --cancel \"$REQUEST_ID\" --model \"$MODEL\"" >&2
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
        echo "Error: Generation failed" >&2
        echo "$status_response" | jq -r '.error // empty' >&2
        echo "$status_response"
        exit 1
    fi
done

if [ "$status" != "COMPLETED" ]; then
    echo "Error: Timeout after ${MAX_POLL_TIME}s" >&2
    echo "Check manually: ./audio-to-video.sh --status \"$REQUEST_ID\" --model \"$MODEL\"" >&2
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
echo "Generation complete!" >&2
[ -n "$video_url" ] && echo "Video URL: $video_url" >&2

# Download if --output specified
if [ -n "$OUTPUT_PATH" ] && [ -n "$video_url" ]; then
    echo "Downloading to $OUTPUT_PATH..." >&2
    curl -sL "$video_url" -o "$OUTPUT_PATH"
    echo "Saved: $OUTPUT_PATH" >&2
fi

echo "$result"
