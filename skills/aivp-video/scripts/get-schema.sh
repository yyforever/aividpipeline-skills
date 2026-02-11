#!/bin/bash

# AIVP Get Schema — Fetch OpenAPI schema for any fal.ai model
# Usage: ./get-schema.sh --model "fal-ai/bytedance/seedance/v1.5/pro" [--input]

set -e

MODEL=""
INPUT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --model|-m)
            MODEL="$2"
            shift 2
            ;;
        --input)
            INPUT_ONLY=true
            shift
            ;;
        --help|-h)
            echo "Get OpenAPI schema for a fal.ai model" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./get-schema.sh --model \"fal-ai/veo3.1\"" >&2
            echo "  ./get-schema.sh --model \"fal-ai/kling-video/v2.6/pro\" --input" >&2
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z "$MODEL" ]; then
    echo "Error: --model is required" >&2
    exit 1
fi

ENCODED=$(echo "$MODEL" | sed 's/\//%2F/g')

echo "Fetching schema for $MODEL..." >&2

RESPONSE=$(curl -s "https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=$ENCODED")

if [ "$INPUT_ONLY" = true ]; then
    echo "$RESPONSE" | python3 -c "
import sys, json
schema = json.load(sys.stdin)
paths = schema.get('paths', {})
for path, methods in paths.items():
    if 'post' in methods:
        body = methods['post'].get('requestBody', {})
        content = body.get('content', {}).get('application/json', {})
        input_schema = content.get('schema', {})
        print(json.dumps(input_schema, indent=2))
        break
" 2>/dev/null || echo "$RESPONSE"
else
    echo "$RESPONSE"
fi
