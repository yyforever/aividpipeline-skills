#!/bin/bash
# AIVP HN Scan — Hacker News trend extraction
# Usage: ./hn-scan.sh --niche "AI" [--limit 10] [--output FILE]
#
# Fetches Hacker News top stories and filters by niche keyword.
# HN API is public and works reliably via curl (no auth needed).
#
# Output: JSON with filtered stories sorted by score.

set -euo pipefail

NICHE=""
LIMIT=10
OUTPUT_FILE=""

usage() {
    cat <<EOF
Usage: $(basename "$0") --niche "topic" [options]

Options:
  --niche TOPIC    Filter keyword (required)
  --limit N        Max results (default: 10)
  --output FILE    Write JSON to file (default: stdout)
  -h, --help       Show this help

Examples:
  ./hn-scan.sh --niche "AI"
  ./hn-scan.sh --niche "video generation" --limit 5 --output /tmp/hn.json
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --niche) NICHE="$2"; shift 2 ;;
        --limit) LIMIT="$2"; shift 2 ;;
        --output) OUTPUT_FILE="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$NICHE" ]]; then
    echo "Error: --niche is required" >&2
    usage
fi

echo "Scanning HN top stories for: $NICHE ..." >&2

# Fetch top story IDs (returns ~500 IDs)
IDS=$(curl -sf "https://hacker-news.firebaseio.com/v0/topstories.json") || {
    echo '{"error":"Failed to fetch HN top stories","items":[]}'
    exit 1
}

# Take top 50 to scan (balance between coverage and speed)
TOP_IDS=$(echo "$IDS" | jq -r '.[:50][]')

ITEMS="[]"
MATCHED=0

for id in $TOP_IDS; do
    [[ "$MATCHED" -ge "$LIMIT" ]] && break
    
    item=$(curl -sf "https://hacker-news.firebaseio.com/v0/item/${id}.json") || continue
    title=$(echo "$item" | jq -r '.title // ""')
    
    # Case-insensitive niche match on title
    if echo "$title" | grep -qi "$NICHE"; then
        ITEMS=$(echo "$ITEMS" | jq --argjson item "$item" '. + [{
            source: "hackernews",
            title: ($item.title // ""),
            score: ($item.score // 0),
            url: ($item.url // ("https://news.ycombinator.com/item?id=" + ($item.id | tostring))),
            hn_url: ("https://news.ycombinator.com/item?id=" + ($item.id | tostring)),
            comments: ($item.descendants // 0),
            by: ($item.by // ""),
            time: ($item.time // 0)
        }]')
        MATCHED=$((MATCHED + 1))
        echo "  ✓ [$MATCHED/$LIMIT] $title" >&2
    fi
done

# Sort by score
ITEMS=$(echo "$ITEMS" | jq 'sort_by(-.score)')

OUTPUT=$(jq -n \
    --arg niche "$NICHE" \
    --arg scanned_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --argjson items "$ITEMS" \
    '{
        source: "hackernews",
        niche: $niche,
        scanned_at: $scanned_at,
        total: ($items | length),
        items: $items
    }')

if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$OUTPUT" > "$OUTPUT_FILE"
    echo "Done: $MATCHED items written to $OUTPUT_FILE" >&2
else
    echo "$OUTPUT"
fi
