#!/bin/bash

# AIVP Add Subtitles — Burn SRT subtitles into video
# Usage: ./add-subtitles.sh --video input.mp4 --srt subs.srt --output out.mp4

set -e

VIDEO=""
SRT=""
OUTPUT=""
FONT_SIZE=24
FONT_COLOR="white"
OUTLINE_COLOR="black"
POSITION="bottom"

while [[ $# -gt 0 ]]; do
    case $1 in
        --video) VIDEO="$2"; shift 2 ;;
        --srt) SRT="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --font-size) FONT_SIZE="$2"; shift 2 ;;
        --font-color) FONT_COLOR="$2"; shift 2 ;;
        --outline-color) OUTLINE_COLOR="$2"; shift 2 ;;
        --position) POSITION="$2"; shift 2 ;;
        --help|-h)
            echo "Burn subtitles into video" >&2
            echo "Usage: ./add-subtitles.sh --video v.mp4 --srt s.srt --output out.mp4" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$VIDEO" ] || [ -z "$SRT" ] || [ -z "$OUTPUT" ]; then
    echo "Error: --video, --srt, and --output are required" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

# Map position to MarginV
case $POSITION in
    top) MARGIN_V=20; ALIGNMENT=8 ;;
    center) MARGIN_V=0; ALIGNMENT=5 ;;
    bottom|*) MARGIN_V=30; ALIGNMENT=2 ;;
esac

# Escape SRT path for FFmpeg (colons and backslashes)
SRT_ESCAPED=$(echo "$SRT" | sed "s/'/\\\\'/g" | sed 's/:/\\:/g')

echo "Burning subtitles..." >&2

ffmpeg -i "$VIDEO" \
    -vf "subtitles='$SRT_ESCAPED':force_style='FontSize=$FONT_SIZE,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BorderStyle=3,Outline=2,MarginV=$MARGIN_V,Alignment=$ALIGNMENT'" \
    -c:a copy \
    -y "$OUTPUT"

echo "Output: $OUTPUT" >&2
