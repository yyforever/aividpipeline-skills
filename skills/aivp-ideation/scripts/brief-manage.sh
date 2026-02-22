#!/bin/bash
# AIVP Brief Manager — Version and manage ideation briefs
# Usage: ./brief-manage.sh <command> [options]
#
# Commands:
#   new      Create new brief version
#   list     List all brief versions
#   diff     Show diff between two versions
#   finalize Copy latest version as brief-final.md
#   status   Show current brief status

set -euo pipefail

IDEATION_DIR="${PROJECT_DIR:-.}/ideation"
CMD="${1:-status}"
shift 2>/dev/null || true

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  new [--from FILE]  Create next version (optionally from a source file)
  list               List all brief versions
  diff [v1] [v2]     Diff between versions (default: last two)
  finalize           Copy latest as brief-final.md
  status             Show brief status

Environment:
  PROJECT_DIR        Project root directory (default: current dir)

Examples:
  PROJECT_DIR=/path/to/project ./brief-manage.sh status
  PROJECT_DIR=/path/to/project ./brief-manage.sh new
  PROJECT_DIR=/path/to/project ./brief-manage.sh diff 1 3
  PROJECT_DIR=/path/to/project ./brief-manage.sh finalize
EOF
    exit 0
}

ensure_dir() {
    mkdir -p "$IDEATION_DIR" "$IDEATION_DIR/research"
}

get_latest_version() {
    ls "$IDEATION_DIR"/brief-v*.md 2>/dev/null | \
        sed 's/.*brief-v\([0-9]*\)\.md/\1/' | \
        sort -n | tail -1
}

get_all_versions() {
    ls "$IDEATION_DIR"/brief-v*.md 2>/dev/null | sort -V
}

case "$CMD" in
    new)
        ensure_dir
        LATEST=$(get_latest_version)
        NEXT=$((${LATEST:-0} + 1))
        BRIEF="$IDEATION_DIR/brief-v${NEXT}.md"
        
        FROM_FILE=""
        if [[ "${1:-}" == "--from" && -n "${2:-}" ]]; then
            FROM_FILE="$2"
        fi
        
        if [[ -n "$FROM_FILE" && -f "$FROM_FILE" ]]; then
            cp "$FROM_FILE" "$BRIEF"
        else
            cat > "$BRIEF" <<TEMPLATE
# Video Ideation Brief — v${NEXT}

## Research Summary
### Trends
- (pending research)

### Community Signals
- (pending research)

### Competitor Landscape
- (pending research)

## Candidate Topics (ranked)

### 1. TBD
- **Type:** 
- **Hook variants:**
  1. ""
  2. ""
  3. ""
- **Target audience:** 
- **Data backing:** 
- **Difficulty:** ⭐⭐⭐ (3/5)
- **Shelf life:** 
- **Score:** /5.0

## Open Questions
- 
TEMPLATE
        fi
        
        echo "Created: $BRIEF" >&2
        echo "$BRIEF"
        ;;
    
    list)
        if [[ ! -d "$IDEATION_DIR" ]]; then
            echo "No ideation directory found at $IDEATION_DIR" >&2
            exit 0
        fi
        
        echo "Brief versions in $IDEATION_DIR:" >&2
        for f in $(get_all_versions); do
            SIZE=$(wc -c < "$f" | tr -d ' ')
            MOD=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null)
            DATE=$(date -d "@$MOD" +%Y-%m-%d\ %H:%M 2>/dev/null || date -r "$MOD" +%Y-%m-%d\ %H:%M 2>/dev/null)
            echo "  $(basename "$f")  ($SIZE bytes, $DATE)"
        done
        
        if [[ -f "$IDEATION_DIR/brief-final.md" ]]; then
            echo "  ✅ brief-final.md (finalized)"
        fi
        ;;
    
    diff)
        V1="${1:-}"
        V2="${2:-}"
        
        if [[ -z "$V1" || -z "$V2" ]]; then
            # Default: diff last two versions
            VERSIONS=($(ls "$IDEATION_DIR"/brief-v*.md 2>/dev/null | sort -V))
            if [[ ${#VERSIONS[@]} -lt 2 ]]; then
                echo "Need at least 2 versions to diff" >&2
                exit 1
            fi
            F1="${VERSIONS[-2]}"
            F2="${VERSIONS[-1]}"
        else
            F1="$IDEATION_DIR/brief-v${V1}.md"
            F2="$IDEATION_DIR/brief-v${V2}.md"
        fi
        
        if [[ ! -f "$F1" || ! -f "$F2" ]]; then
            echo "Files not found: $F1 and/or $F2" >&2
            exit 1
        fi
        
        echo "Diff: $(basename "$F1") → $(basename "$F2")" >&2
        diff -u "$F1" "$F2" || true
        ;;
    
    finalize)
        LATEST=$(get_latest_version)
        if [[ -z "$LATEST" ]]; then
            echo "No brief versions found" >&2
            exit 1
        fi
        
        SRC="$IDEATION_DIR/brief-v${LATEST}.md"
        DST="$IDEATION_DIR/brief-final.md"
        cp "$SRC" "$DST"
        echo "✅ Finalized: brief-v${LATEST}.md → brief-final.md" >&2
        echo "$DST"
        ;;
    
    status)
        if [[ ! -d "$IDEATION_DIR" ]]; then
            echo "No ideation directory. Run 'new' to start." >&2
            exit 0
        fi
        
        VERSIONS=($(ls "$IDEATION_DIR"/brief-v*.md 2>/dev/null | sort -V))
        echo "Versions: ${#VERSIONS[@]}"
        
        LATEST=$(get_latest_version)
        [[ -n "$LATEST" ]] && echo "Latest: v${LATEST}"
        
        if [[ -f "$IDEATION_DIR/brief-final.md" ]]; then
            echo "Status: ✅ Finalized"
        elif [[ ${#VERSIONS[@]} -gt 0 ]]; then
            echo "Status: 🔄 In progress"
        else
            echo "Status: 📝 Not started"
        fi
        
        # Research data status
        echo "Research data:"
        for f in trends.json community.json competitors.json; do
            if [[ -f "$IDEATION_DIR/research/$f" ]]; then
                echo "  ✓ $f"
            else
                echo "  ✗ $f"
            fi
        done
        ;;
    
    -h|--help|help)
        usage
        ;;
    
    *)
        echo "Unknown command: $CMD" >&2
        usage
        ;;
esac
