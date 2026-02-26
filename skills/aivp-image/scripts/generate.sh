#!/bin/bash
set -euo pipefail

# AIVP Image Generation via OpenRouter API
# Usage: ./generate.sh --prompt "..." --model "..." [options]
# Returns: Saved image path + JSON metadata to stdout

OPENROUTER_API_URL="https://openrouter.ai/api/v1/chat/completions"

# Defaults
PROMPT=""
MODEL=""
REFERENCE=""
OUTPUT="./output.png"
MODALITIES=""
SIZE=""
WIDTH=""
HEIGHT=""
SEED=""

# ── Help ──────────────────────────────────────────────
show_help() {
    cat >&2 << 'EOF'
AIVP Image Generation (OpenRouter)

Usage: ./generate.sh --prompt "..." --model "..." [options]

Required:
  --prompt, -p      Image description
  --model, -m       OpenRouter model ID (e.g. black-forest-labs/flux.2-pro)

Optional:
  --reference, -r   Reference image path (for I2I / multi-modal)
  --output, -o      Output image path (default: ./output.png)
  --modalities      "image" or "image,text" (auto-detected if omitted)
  --size            square / portrait / landscape
  --width           Explicit width in pixels
  --height          Explicit height in pixels
  --seed            Reproducibility seed

Environment:
  OPENROUTER_API_KEY  API key (or set in .env / ~/.env / ~/.aivp/.env)

Examples:
  # Text-to-image with Flux
  ./generate.sh -p "A sunlit kitchen, cinematic" -m "black-forest-labs/flux.2-pro" -o kitchen.png

  # Multi-modal with Gemini (includes text response)
  ./generate.sh -p "Portrait of a young woman" -m "google/gemini-2.5-flash-image" -o portrait.png

  # With reference image
  ./generate.sh -p "Same woman, different angle" -m "google/gemini-2.5-flash-image" -r portrait.png -o portrait2.png
EOF
    exit 0
}

# ── Load .env ─────────────────────────────────────────
for envfile in ".env" "$HOME/.env" "$HOME/.aivp/.env"; do
    if [ -f "$envfile" ]; then
        # shellcheck disable=SC1090
        source "$envfile" 2>/dev/null || true
    fi
done

# ── Parse arguments ───────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --prompt|-p)    PROMPT="$2"; shift 2 ;;
        --model|-m)     MODEL="$2"; shift 2 ;;
        --reference|-r) REFERENCE="$2"; shift 2 ;;
        --output|-o)    OUTPUT="$2"; shift 2 ;;
        --modalities)   MODALITIES="$2"; shift 2 ;;
        --size)         SIZE="$2"; shift 2 ;;
        --width)        WIDTH="$2"; shift 2 ;;
        --height)       HEIGHT="$2"; shift 2 ;;
        --seed)         SEED="$2"; shift 2 ;;
        --help|-h)      show_help ;;
        *)              echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# ── Validate ──────────────────────────────────────────
if [ -z "$OPENROUTER_API_KEY" ]; then
    echo "Error: OPENROUTER_API_KEY not set." >&2
    echo "Set it via environment variable or .env file." >&2
    exit 1
fi

if [ -z "$PROMPT" ]; then
    echo "Error: --prompt is required" >&2
    exit 1
fi

if [ -z "$MODEL" ]; then
    echo "Error: --model is required" >&2
    exit 1
fi

# ── Auto-detect modalities ───────────────────────────
if [ -z "$MODALITIES" ]; then
    case "$MODEL" in
        black-forest-labs/*|flux*|ideogram/*|recraft/*)
            MODALITIES="image"
            ;;
        *)
            MODALITIES="image,text"
            ;;
    esac
fi

# ── Build size instruction ────────────────────────────
SIZE_INSTRUCTION=""
if [ -n "$WIDTH" ] && [ -n "$HEIGHT" ]; then
    SIZE_INSTRUCTION="Generate at ${WIDTH}x${HEIGHT} resolution."
elif [ -n "$SIZE" ]; then
    case "$SIZE" in
        square)    SIZE_INSTRUCTION="Generate a square image (1:1 aspect ratio)." ;;
        portrait)  SIZE_INSTRUCTION="Generate a portrait image (3:4 or 9:16 aspect ratio)." ;;
        landscape) SIZE_INSTRUCTION="Generate a landscape image (16:9 or 4:3 aspect ratio)." ;;
    esac
fi

# ── Build prompt with optional size ───────────────────
FULL_PROMPT="$PROMPT"
if [ -n "$SIZE_INSTRUCTION" ]; then
    FULL_PROMPT="$FULL_PROMPT. $SIZE_INSTRUCTION"
fi
if [ -n "$SEED" ]; then
    FULL_PROMPT="$FULL_PROMPT [seed: $SEED]"
fi

# ── Build messages array ──────────────────────────────
# Escape prompt for JSON
ESCAPED_PROMPT=$(printf '%s' "$FULL_PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

if [ -n "$REFERENCE" ]; then
    # Multi-modal message with reference image
    if [ ! -f "$REFERENCE" ]; then
        echo "Error: Reference file not found: $REFERENCE" >&2
        exit 1
    fi

    # Detect MIME type
    EXT=$(echo "${REFERENCE##*.}" | tr '[:upper:]' '[:lower:]')
    case "$EXT" in
        jpg|jpeg) MIME="image/jpeg" ;;
        png)      MIME="image/png" ;;
        webp)     MIME="image/webp" ;;
        gif)      MIME="image/gif" ;;
        *)        MIME="image/png" ;;
    esac

    # Base64 encode reference
    REF_B64=$(base64 -w0 "$REFERENCE" 2>/dev/null || base64 "$REFERENCE" 2>/dev/null)

    MESSAGES="[{\"role\":\"user\",\"content\":[{\"type\":\"image_url\",\"image_url\":{\"url\":\"data:${MIME};base64,${REF_B64}\"}},{\"type\":\"text\",\"text\":${ESCAPED_PROMPT}}]}]"
else
    MESSAGES="[{\"role\":\"user\",\"content\":${ESCAPED_PROMPT}}]"
fi

# ── Build modalities JSON array ───────────────────────
MODALITIES_JSON=$(echo "$MODALITIES" | tr ',' '\n' | sed 's/^/"/;s/$/"/' | paste -sd',' | sed 's/^/[/;s/$/]/')

# ── Build request payload ─────────────────────────────
PAYLOAD="{\"model\":\"$MODEL\",\"messages\":$MESSAGES,\"modalities\":$MODALITIES_JSON,\"max_tokens\":1024}"

# ── Call OpenRouter API ───────────────────────────────
echo "Generating image with $MODEL..." >&2

PAYLOAD_FILE=$(mktemp /tmp/aivp-payload-XXXXXX.json)
RESP_FILE=$(mktemp /tmp/aivp-resp-XXXXXX.json)
trap "rm -f '$PAYLOAD_FILE' '$RESP_FILE'" EXIT

echo "$PAYLOAD" > "$PAYLOAD_FILE"

curl -s -X POST "$OPENROUTER_API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "HTTP-Referer: https://github.com/yyforever/aividpipeline-skills" \
    -H "X-Title: AIVP Image Generation" \
    -d "@$PAYLOAD_FILE" \
    --max-time 120 \
    -o "$RESP_FILE"

# ── Parse response ────────────────────────────────────
python3 - "$RESP_FILE" "$OUTPUT" "$MODEL" "$PROMPT" << 'PYEOF'
import json, base64, sys, os

resp_file, output_path, model, prompt = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open(resp_file, "r") as f:
    resp = json.load(f)

# Check for errors
if "error" in resp:
    msg = resp["error"].get("message", str(resp["error"]))
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)

# Extract image
choice = resp["choices"][0]
msg = choice["message"]
images = msg.get("images", [])

if not images:
    print("Warning: No images in response", file=sys.stderr)
    content = msg.get("content", "")
    if content:
        print(f"Content: {content[:200]}", file=sys.stderr)
    sys.exit(1)

# Decode and save first image
img_url = images[0].get("image_url", {}).get("url", "")

if not img_url.startswith("data:image"):
    print("Error: Unexpected image format", file=sys.stderr)
    sys.exit(1)

header, b64_data = img_url.split(",", 1)
fmt = header.split("/")[1].split(";")[0]
raw = base64.b64decode(b64_data)

# If output has no extension, add detected format
if not os.path.splitext(output_path)[1]:
    output_path += f".{fmt}"

os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)

with open(output_path, "wb") as f:
    f.write(raw)

print(f"Saved: {output_path} ({len(raw)//1024}KB, {fmt})", file=sys.stderr)

# Output JSON metadata to stdout
usage = resp.get("usage", {})
meta = {
    "output": output_path,
    "format": fmt,
    "size_bytes": len(raw),
    "model": model,
    "provider": resp.get("provider", "unknown"),
    "cost": usage.get("cost", 0),
    "prompt": prompt[:500],
}
print(json.dumps(meta, indent=2))
PYEOF
