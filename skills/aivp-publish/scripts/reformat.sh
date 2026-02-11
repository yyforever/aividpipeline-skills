#!/bin/bash

# AIVP Reformat — Convert video to platform-specific format
# Usage: ./reformat.sh --input video.mp4 --platform tiktok --output out.mp4

set -e

INPUT=""
OUTPUT=""
PLATFORM="youtube"

while [[ $# -gt 0 ]]; do
    case $1 in
        --input|-i) INPUT="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --platform|-p) PLATFORM="$2"; shift 2 ;;
        --help|-h)
            echo "Reformat video for platform" >&2
            echo "Usage: ./reformat.sh --input v.mp4 --platform tiktok --output out.mp4" >&2
            echo "Platforms: youtube, shorts, tiktok, reels, instagram, twitter" >&2
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

case $PLATFORM in
    youtube)
        # 16:9, 1080p
        ffmpeg -i "$INPUT" \
            -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
            -c:v libx264 -crf 23 -c:a aac -y "$OUTPUT"
        ;;
    shorts|tiktok|reels)
        # 9:16, 1080x1920
        ffmpeg -i "$INPUT" \
            -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" \
            -c:v libx264 -crf 23 -c:a aac -y "$OUTPUT"
        ;;
    instagram)
        # 1:1, 1080x1080
        ffmpeg -i "$INPUT" \
            -vf "scale=1080:1080:force_original_aspect_ratio=decrease,pad=1080:1080:(ow-iw)/2:(oh-ih)/2" \
            -c:v libx264 -crf 23 -c:a aac -y "$OUTPUT"
        ;;
    twitter)
        # 16:9, max 512MB, 2:20
        ffmpeg -i "$INPUT" \
            -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
            -t 140 -fs 512M \
            -c:v libx264 -crf 23 -c:a aac -y "$OUTPUT"
        ;;
    *)
        echo "Unknown platform: $PLATFORM" >&2
        exit 1
        ;;
esac

echo "Reformatted for $PLATFORM: $OUTPUT" >&2
