#!/bin/bash

# AIVP Technical Review — Check video technical quality
# Usage: ./check-technical.sh --input video.mp4

set -e

INPUT=""
MIN_WIDTH=1280
MIN_FPS=24
MAX_SIZE_MB=4000

while [[ $# -gt 0 ]]; do
    case $1 in
        --input|-i) INPUT="$2"; shift 2 ;;
        --min-width) MIN_WIDTH="$2"; shift 2 ;;
        --min-fps) MIN_FPS="$2"; shift 2 ;;
        --help|-h)
            echo "Check video technical quality" >&2
            echo "Usage: ./check-technical.sh --input video.mp4" >&2
            exit 0
            ;;
        *) shift ;;
    esac
done

if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
    echo "Error: --input required and file must exist" >&2
    exit 1
fi

echo "Checking: $INPUT" >&2

# Get video info
INFO=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,codec_name -of json "$INPUT" 2>/dev/null)
AUDIO_INFO=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of json "$INPUT" 2>/dev/null)
FORMAT=$(ffprobe -v error -show_entries format=duration,size -of json "$INPUT" 2>/dev/null)

WIDTH=$(echo "$INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['streams'][0]['width'])" 2>/dev/null || echo "0")
HEIGHT=$(echo "$INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['streams'][0]['height'])" 2>/dev/null || echo "0")
FPS_RAW=$(echo "$INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['streams'][0]['r_frame_rate'])" 2>/dev/null || echo "0/1")
VCODEC=$(echo "$INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['streams'][0]['codec_name'])" 2>/dev/null || echo "unknown")
ACODEC=$(echo "$AUDIO_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['streams'][0]['codec_name'])" 2>/dev/null || echo "none")
DURATION=$(echo "$FORMAT" | python3 -c "import sys,json; print(json.load(sys.stdin)['format']['duration'])" 2>/dev/null || echo "0")
SIZE=$(echo "$FORMAT" | python3 -c "import sys,json; print(json.load(sys.stdin)['format']['size'])" 2>/dev/null || echo "0")

FPS=$(echo "$FPS_RAW" | python3 -c "
import sys
r = sys.stdin.read().strip()
if '/' in r:
    n, d = r.split('/')
    print(f'{int(n)/int(d):.1f}')
else:
    print(r)
" 2>/dev/null || echo "0")

SIZE_MB=$((SIZE / 1048576))

# Checks
RES_CHECK="PASS"
[ "$WIDTH" -lt "$MIN_WIDTH" ] && RES_CHECK="FAIL"

FPS_INT=$(echo "$FPS" | cut -d'.' -f1)
FPS_CHECK="PASS"
[ "$FPS_INT" -lt "$MIN_FPS" ] && FPS_CHECK="FAIL"

SIZE_CHECK="PASS"
[ "$SIZE_MB" -gt "$MAX_SIZE_MB" ] && SIZE_CHECK="FAIL"

# Black frame detection
BLACK_FRAMES=$(ffmpeg -i "$INPUT" -vf "blackdetect=d=1:pix_th=0.10" -an -f null - 2>&1 | grep "blackdetect" | wc -l | tr -d ' ')
BLACK_CHECK="PASS"
[ "$BLACK_FRAMES" -gt 0 ] && BLACK_CHECK="WARNING: $BLACK_FRAMES black sections detected"

# Silence detection
SILENCE=$(ffmpeg -i "$INPUT" -af "silencedetect=n=-30dB:d=2" -f null - 2>&1 | grep "silence_start" | wc -l | tr -d ' ')
SILENCE_CHECK="PASS"
[ "$SILENCE" -gt 0 ] && SILENCE_CHECK="WARNING: $SILENCE silent sections detected"

# Overall
OVERALL="PASS"
[[ "$RES_CHECK" == "FAIL" || "$FPS_CHECK" == "FAIL" || "$SIZE_CHECK" == "FAIL" ]] && OVERALL="FAIL"
[[ "$OVERALL" == "PASS" && ("$BLACK_CHECK" == WARNING* || "$SILENCE_CHECK" == WARNING*) ]] && OVERALL="PASS_WITH_WARNINGS"

cat <<EOF
{
  "resolution": "${WIDTH}x${HEIGHT}",
  "fps": $FPS,
  "duration": "${DURATION}s",
  "codec": "$VCODEC",
  "audio_codec": "$ACODEC",
  "file_size_mb": $SIZE_MB,
  "checks": {
    "resolution": "$RES_CHECK",
    "fps": "$FPS_CHECK",
    "file_size": "$SIZE_CHECK",
    "black_frames": "$BLACK_CHECK",
    "silence": "$SILENCE_CHECK"
  },
  "overall": "$OVERALL"
}
EOF
