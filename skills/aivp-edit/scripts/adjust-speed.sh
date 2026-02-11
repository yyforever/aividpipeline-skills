#!/bin/bash

# AIVP Adjust Speed — Speed up or slow down video
# Usage: ./adjust-speed.sh --input video.mp4 --speed 2.0 --output fast.mp4

set -e

INPUT=""
SPEED=1.0
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --input|-i) INPUT="$2"; shift 2 ;;
        --speed) SPEED="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --help|-h)
            echo "Adjust video speed" >&2
            echo "Usage: ./adjust-speed.sh --input v.mp4 --speed 2.0 --output out.mp4" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Error: --input and --output required" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

# Calculate inverse for video PTS
VIDEO_PTS=$(echo "scale=4; 1/$SPEED" | bc)
# Audio atempo accepts 0.5-2.0, chain for extremes
AUDIO_SPEED=$SPEED

echo "Adjusting speed to ${SPEED}x..." >&2

ffmpeg -i "$INPUT" \
    -filter_complex "[0:v]setpts=${VIDEO_PTS}*PTS[v];[0:a]atempo=$AUDIO_SPEED[a]" \
    -map "[v]" -map "[a]" \
    -y "$OUTPUT"

echo "Output: $OUTPUT" >&2
