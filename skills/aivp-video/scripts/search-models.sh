#!/bin/bash

# AIVP Search Models — Find available video generation models on fal.ai
# Usage: ./search-models.sh [--query KEYWORD] [--category CATEGORY]

set -e

QUERY=""
CATEGORY=""

# Load .env
for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    [ -f "$envfile" ] && source "$envfile" 2>/dev/null || true
done

while [[ $# -gt 0 ]]; do
    case $1 in
        --query|-q)
            QUERY="$2"
            shift 2
            ;;
        --category|-c)
            CATEGORY="$2"
            shift 2
            ;;
        --help|-h)
            echo "Search fal.ai models for video generation" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./search-models.sh --query \"seedance\"" >&2
            echo "  ./search-models.sh --category \"text-to-video\"" >&2
            echo "" >&2
            echo "Categories: text-to-video, image-to-video, video-to-video" >&2
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

# Build URL
URL="https://fal.ai/api/models"
PARAMS=""

if [ -n "$QUERY" ]; then
    ENCODED_QUERY=$(echo "$QUERY" | sed 's/ /%20/g')
    PARAMS="?q=$ENCODED_QUERY"
fi

if [ -n "$CATEGORY" ]; then
    if [ -n "$PARAMS" ]; then
        PARAMS="${PARAMS}&category=$CATEGORY"
    else
        PARAMS="?category=$CATEGORY"
    fi
fi

echo "Searching models${QUERY:+: $QUERY}${CATEGORY:+ (category: $CATEGORY)}..." >&2

RESPONSE=$(curl -s "${URL}${PARAMS}" \
    -H "Authorization: Key $FAL_KEY")

echo "$RESPONSE"
