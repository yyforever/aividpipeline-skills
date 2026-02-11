#!/bin/bash

# AIVP Concat — Concatenate video clips
# Usage: ./concat.sh --input clip1.mp4 --input clip2.mp4 --output combined.mp4

set -e

INPUTS=()
LIST_FILE=""
OUTPUT=""
TRANSITION="none"
CROSSFADE_DURATION=0.5

while [[ $# -gt 0 ]]; do
    case $1 in
        --input|-i) INPUTS+=("$2"); shift 2 ;;
        --list) LIST_FILE="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --transition) TRANSITION="$2"; shift 2 ;;
        --crossfade-duration) CROSSFADE_DURATION="$2"; shift 2 ;;
        --help|-h)
            echo "Concatenate video clips" >&2
            echo "Usage: ./concat.sh --input a.mp4 --input b.mp4 --output out.mp4" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$OUTPUT" ]; then
    echo "Error: --output is required" >&2
    exit 1
fi

# Create output directory
mkdir -p "$(dirname "$OUTPUT")"

if [ -n "$LIST_FILE" ]; then
    # Use provided file list
    echo "Concatenating from list: $LIST_FILE" >&2
    ffmpeg -f concat -safe 0 -i "$LIST_FILE" -c copy -y "$OUTPUT"
elif [ ${#INPUTS[@]} -gt 0 ]; then
    if [ "$TRANSITION" = "crossfade" ] && [ ${#INPUTS[@]} -eq 2 ]; then
        echo "Crossfade concat (${CROSSFADE_DURATION}s)..." >&2
        # Get duration of first clip
        DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "${INPUTS[0]}" | cut -d'.' -f1)
        OFFSET=$((DUR - ${CROSSFADE_DURATION%.*}))
        ffmpeg -i "${INPUTS[0]}" -i "${INPUTS[1]}" \
            -filter_complex "xfade=transition=fade:duration=$CROSSFADE_DURATION:offset=$OFFSET" \
            -y "$OUTPUT"
    else
        # Simple concat via file list
        TEMP_LIST=$(mktemp)
        trap "rm -f $TEMP_LIST" EXIT
        for f in "${INPUTS[@]}"; do
            echo "file '$(realpath "$f")'" >> "$TEMP_LIST"
        done
        echo "Concatenating ${#INPUTS[@]} clips..." >&2
        ffmpeg -f concat -safe 0 -i "$TEMP_LIST" -c copy -y "$OUTPUT"
    fi
else
    echo "Error: Provide --input files or --list" >&2
    exit 1
fi

echo "Output: $OUTPUT" >&2
