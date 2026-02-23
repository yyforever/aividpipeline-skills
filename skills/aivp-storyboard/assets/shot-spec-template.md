# Shot {SCENE_ID}.{SHOT_NUM}

## Metadata

| Field | Value |
|-------|-------|
| Shot ID | {scene_id}.{shot_num} |
| Scene | {scene_slug} |
| Camera | cam_{idx} ({shot_type}, {angle}) |
| Variation | {small/medium/large} |
| Duration | {N}s |
| Emotion | {↑↑↑/↑↑/↑/→/↓} ({description}) |
| Is Primary | {true/false} |

## Characters

| Character | First Frame | Last Frame | Portrait Angle | Facing |
|-----------|:-----------:|:----------:|:--------------:|:------:|
| @{Name} | {visible/hidden} | {visible/hidden} | {front/side/back} | {direction} |

## Shot Decomposition

### First Frame
> {Pure static snapshot description. No motion verbs. Include shot type, angle,
> composition, character positions with facing directions, lighting, color.
> Use visual features not character names for video model compatibility.}

### Last Frame
> {For medium/large variation only. Pure static snapshot of final state.
> For small variation: "(small variation — not required)"}

### Motion
> {Camera movement + subject movement. Use visual appearance not names.
> Include degree adverbs. Include dialogue delivery if present.}

## Audio

| Layer | Content |
|-------|---------|
| Dialogue | {[Character, tone]: "text" / (none)} |
| BGM | {music description / (continue)} |
| SFX | {concrete sound effects / (none)} |

---

## For aivp-image

### Frame: first-frame

**Generation mode**: {Text-to-image / Image-to-image}

**Reference images**:
1. {Reference 1 — role description}
2. {Reference 2 — role description}

**Prompt**:
> {Image generation prompt — self-contained, includes all visual details}

**Resolution**: {W}×{H} ({aspect_ratio})

### Frame: last-frame (if medium/large)

**Generation mode**: {Image-to-image}

**Reference images**:
1. {Shot first-frame — starting state}
2. {Additional references}

**Prompt**:
> {Image generation prompt for final state}

---

## For aivp-video

### Kling 3.0

```
[Camera: {movement}, {shot_type}, {angle}]
{Subject action using visual appearance}
{Lighting/atmosphere}
[{Character}, {tone}]: "{dialogue}" 
(Duration: {N}s)
```

### Seedance 2.0

```
{Subject motion with degree adverbs}
Camera: {movement keyword}
{Scene/atmosphere}
```

**Input frames**: {first-frame only / first + last frame}
**Duration**: {N}s
**Aspect ratio**: {ratio}
**Camera mode**: {fixed / unfixed}
