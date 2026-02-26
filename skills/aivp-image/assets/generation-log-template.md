# Image Generation Log — {project_name}

## Summary

| Metric | Value |
|--------|-------|
| Total frames generated | {N} |
| Total cost | ${total} |
| Model(s) used | {model_list} |
| Generation time | {duration} |

## Per-Frame Log

### Shot {scene_id}.{shot_num} — {frame_type}

| Field | Value |
|-------|-------|
| File | `image/frames/shot-{NN}-{ff/lf}.png` |
| Model | {model_id} |
| Provider | {provider} |
| Cost | ${cost} |
| Format | {png/jpeg} |
| Size | {KB} KB |
| Timestamp | {ISO-8601} |
| Seed | {seed or "random"} |

**Prompt used:**
> {actual prompt sent to API}

**Reference images:**
1. {ref_1 — role}
2. {ref_2 — role}

**Notes:** {any quality issues, regeneration needed, etc.}

---

### Shot {next}...
