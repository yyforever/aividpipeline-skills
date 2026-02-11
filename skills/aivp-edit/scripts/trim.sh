#!/bin/bash

# AIVP Trim — Trim video by start/end time
# Usage: ./trim.sh --input video.mp4 --start 5 --end 15 --output trimmed.mp4

set -e

INPUT=""
START=""
END=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --input|-i) INPUT="$2"; shift 2 ;;
        --start|-s) START="$2"; shift 2 ;;
        --end|-e) END="$2"; shift 2 ;;
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --help|-h)
            echo "Trim video" >&2
            echo "Usage: ./trim.sh --input v.mp4 --start 5 --end 15 --output out.mp4" >&2
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

CMD="ffmpeg -i \"$INPUT\""
[ -n "$START" ] && CMD="$CMD -ss $START"
[ -n "$END" ] && CMD="$CMD -to $END"
CMD="$CMD -c copy -y \"$OUTPUT\""

echo "Trimming${START:+ from ${START}s}${END:+ to ${END}s}..." >&2
eval $CMD

echo "Output: $OUTPUT" >&2
