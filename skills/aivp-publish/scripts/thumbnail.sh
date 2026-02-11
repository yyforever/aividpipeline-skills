#!/bin/bash

# AIVP Thumbnail — Extract thumbnail from video
# Usage: ./thumbnail.sh --video input.mp4 --output thumb.jpg [--timestamp 15]

set -e

VIDEO=""
OUTPUT=""
TIMESTAMP=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --video) VIDEO="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --timestamp|-t) TIMESTAMP="$2"; shift 2 ;;
        --help|-h)
            echo "Extract thumbnail from video" >&2
            echo "Usage: ./thumbnail.sh --video v.mp4 --output thumb.jpg" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$VIDEO" ] || [ -z "$OUTPUT" ]; then
    echo "Error: --video and --output required" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

if [ -n "$TIMESTAMP" ]; then
    # Extract at specific time
    ffmpeg -i "$VIDEO" -ss "$TIMESTAMP" -vframes 1 -q:v 2 -y "$OUTPUT"
else
    # Extract at 1/3 of duration (usually a good representative frame)
    DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO" | cut -d'.' -f1)
    TS=$((DURATION / 3))
    ffmpeg -i "$VIDEO" -ss "$TS" -vframes 1 -q:v 2 -y "$OUTPUT"
fi

echo "Thumbnail: $OUTPUT" >&2
