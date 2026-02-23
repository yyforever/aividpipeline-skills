# Production Specs Format

Each shot produces two output specs — one for aivp-image (keyframe generation) and one for aivp-video (clip generation). These are the final handoff documents.

## Per-Shot Spec Format

```markdown
# Shot {scene_id}.{shot_num}

## Metadata

| Field | Value |
|-------|-------|
| Shot ID | 1.3 |
| Scene | kitchen-morning |
| Camera | cam_2 (CU, eye-level) |
| Variation | small |
| Duration | 5s |
| Emotion | ↑↑ (tension rising) |
| Is Primary | false |

## Characters

| Character | First Frame | Last Frame | Portrait Angle |
|-----------|:-----------:|:----------:|:--------------:|
| @Elena | visible, facing camera | visible, facing camera | front |

## Shot Decomposition

### First Frame
> Close-up at eye level. A woman in her early 30s (shoulder-length auburn hair,
> gray blazer over white blouse) holds a crumpled letter at chest height,
> knuckles white from gripping. Warm side lighting from a window at screen-right
> casts half her face in golden light, half in shadow. Blurred kitchen background
> with warm wood tones.

### Last Frame
> (small variation — not required)

### Motion
> Static camera. The woman's hand (gray blazer sleeve visible) slowly unclenches,
> fingers trembling. The crumpled letter begins to slip from her loosening grip.
> Her jaw tightens subtly.

## Audio

| Layer | Content |
|-------|---------|
| Dialogue | [Elena, barely audible]: "It was all a lie." |
| BGM | (continue — tense strings from previous shot) |
| SFX | Paper rustling, sharp exhale |

---

## For aivp-image

### Frame 1: first-frame

**Generation mode**: Image-to-image (refine from Shot 1.2 first-frame crop)

**Reference images** (in priority order):
1. Shot 1.2 first-frame — spatial reference (crop to CU)
2. @Elena front portrait — face detail consistency
3. Scene: kitchen-morning — background tones (low weight)

**Prompt** (for image generation model):
> Close-up portrait of a woman in her early 30s with shoulder-length auburn hair,
> wearing a gray blazer over a white blouse. She grips a crumpled white letter
> at chest height, knuckles white. Warm golden side lighting from right.
> Blurred warm kitchen background. Cinematic, shallow depth of field, 16:9.

**Negative guidance**: No text, no watermark, no extra people

**Resolution**: 1920×1080 (16:9)

---

## For aivp-video

### Clip Generation

**Input frames**: first-frame only (small variation)

**Motion prompt** (Kling 3.0 format):
> [Camera: static, close-up, eye-level]
> The woman's hand slowly unclenches, crumpled letter slipping from trembling fingers.
> Warm side lighting. Shallow depth of field.
> [Elena, barely audible]: "It was all a lie."
> (Duration: 5s)

**Motion prompt** (Seedance 2.0 format):
> The auburn-haired woman's hand gently releases its grip on the crumpled letter.
> Her fingers tremble slightly as the paper begins to slip.
> Camera: static close-up.
> Warm cinematic lighting, shallow depth of field.

**Parameters**:
- Duration: 5s
- Aspect ratio: 16:9
- Camera: static (unfixed camera = NO)
- Audio sync: Dialogue at 1.5s mark
```

## Model-Specific Prompt Guidelines

### Kling 3.0 (Kuaishou)

Structure:
```
[Camera: {movement}, {shot_type}, {angle}]
{Subject action using visual appearance, not names}
{Lighting/atmosphere}
[Character Name, tone]: "dialogue" (for lip sync)
(Duration: {N}s)
```

Key rules:
- Anchor subjects early in prompt
- Explicit camera movement keywords: "slowly tracking right", "static", "dolly in"
- Dialogue format: `[Character Name, tone]: "text"` (name needed for lip sync assignment)
- Max 6 shots per multi-shot group, max 15s per shot
- Tone keywords in dialogue tags improve output quality

### Seedance 2.0 (ByteDance)

Structure:
```
{Subject motion with degree adverbs}
Camera: {movement keyword}
{Scene/atmosphere}
```

Key rules:
- **Degree adverbs are critical**: "slowly", "gently", "violently", not just the verb
- "Lens switch" keyword triggers multi-shot within one generation
- No negative prompts (describe what you WANT)
- Camera keywords: surround, aerial, zoom, pan, follow, handheld
- For moving camera: select "unfixed camera" in parameters
- Gentle motion words for smooth results: slow, gentle, continuous, natural, smooth

### Seedance 2.0 Reference Modes

**Omni Reference** (up to 9 images + 3 videos + 3 audio):
```
@image_file_1 is the main character.
@image_file_2 is the kitchen background.
The character slowly turns, expression shifting to surprise.
Camera: static close-up.
```

**First/Last Frames** (image-to-video):
```
Smooth transition from first frame to last frame.
The woman's hand gently releases the letter.
Cinematic lighting, shallow depth of field.
```

### Veo 3.1 (Google)

- Supports first-frame and first+last-frame input
- Excellent at interpreting cinematic vocabulary
- Native audio generation — dialogue prompts can include voice tone descriptions
- Up to 2K resolution output

## Multi-Shot Grouping

For Kling 3.0 multi-shot mode (max 6 shots per group), group shots by:

1. **Conversation beats** — dialogue-heavy sequences stay together
2. **Continuous motion** — action sequences that flow visually
3. **Same scene** — don't cross scene boundaries within a group

Format:
```
Master Prompt: Kitchen, early morning, warm golden light through windows.
Elena stands at the counter, Marco sits at the table.

Multi-shot Prompt 1: Medium shot, Elena sets down a plate too hard...
[Elena, frustrated]: "You never listen." (Duration: 5s)

Multi-shot Prompt 2: Close-up reaction, Marco turns around...
[Marco, defensive]: "Because you never stop blaming!" (Duration: 4s)
```

## Dual Format Requirement

Every shot must have BOTH:
1. **Shot decomposition** (for aivp-image) — structured metadata + frame descriptions + reference list
2. **Video prompt** (for aivp-video) — model-specific motion prompt + input frame references + audio cues

These cover the same shot from two angles. They must stay in sync — any edit to the decomposition must be reflected in the video prompt and vice versa.
