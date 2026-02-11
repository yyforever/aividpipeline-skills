#!/bin/bash

# AIVP File Upload Script — Upload local files to fal.ai CDN
# Usage: ./upload.sh --file /path/to/file
# Returns: CDN URL

set -e

FAL_TOKEN_ENDPOINT="https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3"
FILE_PATH=""

# Load .env
for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    [ -f "$envfile" ] && source "$envfile" 2>/dev/null || true
done

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --file|-f)
            FILE_PATH="$2"
            shift 2
            ;;
        --help|-h)
            echo "Upload files to fal.ai CDN" >&2
            echo "Usage: ./upload.sh --file /path/to/file" >&2
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    exit 1
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    echo "Error: --file required and must exist" >&2
    exit 1
fi

FILENAME=$(basename "$FILE_PATH")
EXTENSION="${FILENAME##*.}"
EXT_LOWER=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

case "$EXT_LOWER" in
    jpg|jpeg) CONTENT_TYPE="image/jpeg" ;;
    png) CONTENT_TYPE="image/png" ;;
    gif) CONTENT_TYPE="image/gif" ;;
    webp) CONTENT_TYPE="image/webp" ;;
    mp4) CONTENT_TYPE="video/mp4" ;;
    mov) CONTENT_TYPE="video/quicktime" ;;
    mp3) CONTENT_TYPE="audio/mpeg" ;;
    wav) CONTENT_TYPE="audio/wav" ;;
    *) CONTENT_TYPE="application/octet-stream" ;;
esac

echo "Uploading $FILENAME ($CONTENT_TYPE)..." >&2

# Step 1: Get CDN token
TOKEN_RESPONSE=$(curl -s -X POST "$FAL_TOKEN_ENDPOINT" \
    -H "Authorization: Key $FAL_KEY" \
    -H "Content-Type: application/json" \
    -d '{}')

CDN_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
CDN_TOKEN_TYPE=$(echo "$TOKEN_RESPONSE" | grep -o '"token_type":"[^"]*"' | cut -d'"' -f4)
CDN_BASE_URL=$(echo "$TOKEN_RESPONSE" | grep -o '"base_url":"[^"]*"' | cut -d'"' -f4)

if [ -z "$CDN_TOKEN" ] || [ -z "$CDN_BASE_URL" ]; then
    echo "Error: Failed to get CDN token" >&2
    exit 1
fi

# Step 2: Upload
UPLOAD_RESPONSE=$(curl -s -X POST "${CDN_BASE_URL}/files/upload" \
    -H "Authorization: $CDN_TOKEN_TYPE $CDN_TOKEN" \
    -H "Content-Type: $CONTENT_TYPE" \
    -H "X-Fal-File-Name: $FILENAME" \
    --data-binary "@$FILE_PATH")

if echo "$UPLOAD_RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$UPLOAD_RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Upload error: $ERROR_MSG" >&2
    exit 1
fi

ACCESS_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"access_url":"[^"]*"' | cut -d'"' -f4)

if [ -z "$ACCESS_URL" ]; then
    echo "Error: No URL in upload response" >&2
    exit 1
fi

echo "Uploaded: $ACCESS_URL" >&2
echo "$ACCESS_URL"
