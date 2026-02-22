#!/bin/bash
# AIVP Competitor Scan — Format competitor research data
# Usage: ./competitor-scan.sh --channel "@handle" --data /path/to/raw.json
#
# This script POST-PROCESSES competitor data gathered via web_search/web_fetch.
# It does NOT fetch data from YouTube directly (YouTube blocks curl).
#
# Workflow:
#   1. Agent uses web_search to find channel's recent videos
#   2. Agent writes raw results to a JSON file
#   3. This script structures and analyzes the data
#
# Input JSON format (array of objects):
#   [{"title": "...", "views": "...", "published": "...", "url": "..."}]
#
# Output: Structured analysis with title patterns, common words, etc.

set -euo pipefail

CHANNEL=""
DATA_FILE=""
OUTPUT_FILE=""

usage() {
    cat <<EOF
Usage: $(basename "$0") --channel "@handle" --data FILE [options]

Options:
  --channel HANDLE   Channel name/handle (for labeling)
  --data FILE        Input JSON file with video data
  --output FILE      Write analysis to file (default: stdout)
  -h, --help         Show this help

Input JSON format:
  [
    {"title": "Video Title", "views": "1.2M views", "published": "2 weeks ago", "url": "https://..."},
    ...
  ]

Examples:
  ./competitor-scan.sh --channel "@mkbhd" --data /tmp/mkbhd-raw.json
  ./competitor-scan.sh --channel "@fireship" --data /tmp/data.json --output analysis.json
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --channel) CHANNEL="$2"; shift 2 ;;
        --data) DATA_FILE="$2"; shift 2 ;;
        --output) OUTPUT_FILE="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$DATA_FILE" ]]; then
    echo "Error: --data is required" >&2
    usage
fi

if [[ ! -f "$DATA_FILE" ]]; then
    echo "Error: Data file not found: $DATA_FILE" >&2
    exit 1
fi

VIDEOS=$(cat "$DATA_FILE")
COUNT=$(echo "$VIDEOS" | jq 'length' 2>/dev/null || echo 0)

if [[ "$COUNT" -eq 0 ]]; then
    echo "Warning: No videos in input data" >&2
    jq -n --arg ch "$CHANNEL" '{"channel": $ch, "videos": 0, "analysis": {}}'
    exit 0
fi

# Analyze title patterns
ANALYSIS=$(echo "$VIDEOS" | jq '{
    total_videos: length,
    titles: [.[].title],
    avg_title_length: ([.[].title | length] | add / length | floor),
    title_word_freq: (
        [.[].title | ascii_downcase | gsub("[^a-z0-9 ]"; "") | split(" ")[] |
        select(length > 3)] |
        group_by(.) |
        map({word: .[0], count: length}) |
        sort_by(-.count) |
        .[:15]
    ),
    has_numbers: ([.[].title | test("[0-9]")] | map(select(. == true)) | length),
    has_question: ([.[].title | test("\\?")] | map(select(. == true)) | length),
    has_how_to: ([.[].title | ascii_downcase | test("how to|tutorial|guide")] | map(select(. == true)) | length)
}' 2>/dev/null) || ANALYSIS="{}"

OUTPUT=$(jq -n \
    --arg channel "${CHANNEL:-unknown}" \
    --arg analyzed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --argjson videos "$VIDEOS" \
    --argjson analysis "$ANALYSIS" \
    '{
        channel: $channel,
        analyzed_at: $analyzed_at,
        video_count: ($videos | length),
        videos: $videos,
        analysis: $analysis
    }')

if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$OUTPUT" > "$OUTPUT_FILE"
    echo "Analysis written to $OUTPUT_FILE ($COUNT videos)" >&2
else
    echo "$OUTPUT"
fi
