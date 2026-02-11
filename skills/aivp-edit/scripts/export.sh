#!/bin/bash

# AIVP Export — Full pipeline: concat + audio + subtitles
# Usage: ./export.sh --clips-dir clips/ --voiceover vo.mp3 --output final.mp4

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CLIPS_DIR=""
CLIPS_LIST=""
VOICEOVER=""
BGM=""
BGM_VOLUME=0.15
SRT=""
OUTPUT=""
RESOLUTION=""
FPS=""
CODEC="libx264"
QUALITY=23

while [[ $# -gt 0 ]]; do
    case $1 in
        --clips-dir) CLIPS_DIR="$2"; shift 2 ;;
        --clips-list) CLIPS_LIST="$2"; shift 2 ;;
        --voiceover) VOICEOVER="$2"; shift 2 ;;
        --bgm) BGM="$2"; shift 2 ;;
        --bgm-volume) BGM_VOLUME="$2"; shift 2 ;;
        --srt) SRT="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --resolution) RESOLUTION="$2"; shift 2 ;;
        --fps) FPS="$2"; shift 2 ;;
        --codec) CODEC="$2"; shift 2 ;;
        --quality) QUALITY="$2"; shift 2 ;;
        --help|-h)
            echo "AIVP Full Export Pipeline" >&2
            echo "Usage: ./export.sh --clips-dir clips/ --output final.mp4" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$OUTPUT" ]; then
    echo "Error: --output is required" >&2
    exit 1
fi

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

CURRENT="$TEMP_DIR/step0.mp4"

# Step 1: Concat
echo "=== Step 1: Concat ===" >&2
if [ -n "$CLIPS_DIR" ]; then
    CONCAT_ARGS=""
    for f in "$CLIPS_DIR"/*.mp4; do
        CONCAT_ARGS="$CONCAT_ARGS --input \"$f\""
    done
    eval bash "$SCRIPT_DIR/concat.sh" $CONCAT_ARGS --output "$CURRENT"
elif [ -n "$CLIPS_LIST" ]; then
    bash "$SCRIPT_DIR/concat.sh" --list "$CLIPS_LIST" --output "$CURRENT"
else
    echo "Error: Provide --clips-dir or --clips-list" >&2
    exit 1
fi

# Step 2: Mix audio
if [ -n "$VOICEOVER" ] || [ -n "$BGM" ]; then
    echo "=== Step 2: Mix Audio ===" >&2
    NEXT="$TEMP_DIR/step1.mp4"
    AUDIO_ARGS="--video \"$CURRENT\" --output \"$NEXT\""
    [ -n "$VOICEOVER" ] && AUDIO_ARGS="$AUDIO_ARGS --voiceover \"$VOICEOVER\""
    [ -n "$BGM" ] && AUDIO_ARGS="$AUDIO_ARGS --bgm \"$BGM\" --bgm-volume $BGM_VOLUME"
    eval bash "$SCRIPT_DIR/mix-audio.sh" $AUDIO_ARGS
    CURRENT="$NEXT"
fi

# Step 3: Subtitles
if [ -n "$SRT" ]; then
    echo "=== Step 3: Subtitles ===" >&2
    NEXT="$TEMP_DIR/step2.mp4"
    bash "$SCRIPT_DIR/add-subtitles.sh" --video "$CURRENT" --srt "$SRT" --output "$NEXT"
    CURRENT="$NEXT"
fi

# Step 4: Final encode (resolution/fps/codec if specified)
mkdir -p "$(dirname "$OUTPUT")"

if [ -n "$RESOLUTION" ] || [ -n "$FPS" ] || [ "$CODEC" != "libx264" ] || [ "$QUALITY" != 23 ]; then
    echo "=== Step 4: Final Encode ===" >&2
    VF_FILTERS=""
    [ -n "$RESOLUTION" ] && VF_FILTERS="scale=${RESOLUTION/x/:}:force_original_aspect_ratio=decrease,pad=${RESOLUTION/x/:}:(ow-iw)/2:(oh-ih)/2"

    CMD="ffmpeg -i \"$CURRENT\""
    [ -n "$VF_FILTERS" ] && CMD="$CMD -vf \"$VF_FILTERS\""
    [ -n "$FPS" ] && CMD="$CMD -r $FPS"
    CMD="$CMD -c:v $CODEC -crf $QUALITY -c:a aac -y \"$OUTPUT\""
    eval $CMD
else
    cp "$CURRENT" "$OUTPUT"
fi

echo "" >&2
echo "=== Export Complete ===" >&2
echo "Output: $OUTPUT" >&2
