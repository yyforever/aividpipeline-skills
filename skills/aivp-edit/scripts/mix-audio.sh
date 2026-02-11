#!/bin/bash

# AIVP Mix Audio — Add voiceover and/or BGM to video
# Usage: ./mix-audio.sh --video input.mp4 --voiceover vo.mp3 --bgm bgm.mp3 --output out.mp4

set -e

VIDEO=""
VOICEOVER=""
BGM=""
BGM_VOLUME=0.15
VO_VOLUME=1.0
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --video) VIDEO="$2"; shift 2 ;;
        --voiceover) VOICEOVER="$2"; shift 2 ;;
        --bgm) BGM="$2"; shift 2 ;;
        --bgm-volume) BGM_VOLUME="$2"; shift 2 ;;
        --vo-volume) VO_VOLUME="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --help|-h)
            echo "Mix audio into video" >&2
            echo "Usage: ./mix-audio.sh --video v.mp4 --voiceover vo.mp3 --output out.mp4" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$VIDEO" ] || [ -z "$OUTPUT" ]; then
    echo "Error: --video and --output are required" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

if [ -n "$VOICEOVER" ] && [ -n "$BGM" ]; then
    echo "Mixing voiceover + BGM..." >&2
    ffmpeg -i "$VIDEO" -i "$VOICEOVER" -i "$BGM" \
        -filter_complex "[1:a]volume=$VO_VOLUME[vo];[2:a]volume=$BGM_VOLUME[bgm];[vo][bgm]amix=inputs=2:duration=longest[aout]" \
        -map 0:v -map "[aout]" \
        -c:v copy -c:a aac -shortest \
        -y "$OUTPUT"
elif [ -n "$VOICEOVER" ]; then
    echo "Adding voiceover..." >&2
    ffmpeg -i "$VIDEO" -i "$VOICEOVER" \
        -filter_complex "[1:a]volume=$VO_VOLUME[vo]" \
        -map 0:v -map "[vo]" \
        -c:v copy -c:a aac -shortest \
        -y "$OUTPUT"
elif [ -n "$BGM" ]; then
    echo "Adding BGM..." >&2
    ffmpeg -i "$VIDEO" -i "$BGM" \
        -filter_complex "[1:a]volume=$BGM_VOLUME[bgm]" \
        -map 0:v -map "[bgm]" \
        -c:v copy -c:a aac -shortest \
        -y "$OUTPUT"
else
    echo "Error: Provide --voiceover and/or --bgm" >&2
    exit 1
fi

echo "Output: $OUTPUT" >&2
