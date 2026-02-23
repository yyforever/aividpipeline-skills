# Variation Type System

Every shot is classified into one of three variation types based on how much the visual content changes from first frame to last frame. This classification directly determines the generation strategy.

## Classification

| Type | Visual Change | Examples | Generation Strategy |
|------|--------------|----------|-------------------|
| `small` | Subtle — expression, slight gesture, minimal camera motion | Smile appears, hand moves to chin, slow pan | **First-frame only** → video model interpolates |
| `medium` | Moderate — new character enters, character turns, significant gesture | Person enters frame, turns from back to face camera, stands up | **First + last frame** → video model interpolates between |
| `large` | Major — composition shift, dramatic camera movement, scene transition | Drone flyover, dolly from wide to close-up, cross-cut | **First + last frame** → video model interpolates between |

## Decision Rules (from ViMax)

### Small Variation
- Expression changes only (neutral → smile, calm → angry)
- Subtle body movement (nod, shrug, tilt head)
- Minor hand/arm gestures (wave, point, pick up object)
- Minimal camera movement (slow pan < 15°, slight tilt)
- **No new characters appear or disappear**
- **No significant change in what's visible in frame**

### Medium Variation
- A new character enters the frame (wasn't visible → now visible)
- A character turns from back/side to face camera (major pose change)
- Character sits down / stands up (significant vertical movement)
- A character exits the frame
- Moderate camera movement (tracking, dolly in/out)
- **Frame composition changes but setting remains the same**

### Large Variation
- Dramatic camera movement (crane shot, drone flyover, orbit)
- Smooth transition between two very different framings (wide → extreme close-up in one shot)
- Major compositional shift (foreground/background swap)
- Scene elements transform significantly
- **First frame and last frame look like they could be different shots**

## Impact on Generation Pipeline

### Small → 1 reference image
```
aivp-image generates: first_frame.png
aivp-video receives: first_frame.png + motion prompt
Video model: First-Frame-to-Video mode
```

### Medium → 2 reference images
```
aivp-image generates: first_frame.png + last_frame.png
aivp-video receives: first_frame.png + last_frame.png + motion prompt
Video model: First+Last-Frame-to-Video mode (Seedance 2.0, Veo 3.1)
```

### Large → 2 reference images + extra care
```
aivp-image generates: first_frame.png + last_frame.png
aivp-video receives: first_frame.png + last_frame.png + motion prompt
Video model: First+Last-Frame-to-Video mode with explicit camera motion keywords
Note: Large variation shots need careful prompt engineering to avoid visual artifacts
```

## Cost Implications

| Type | Image Gen Calls | Video Gen Complexity | Typical Quality |
|------|:-:|:-:|:-:|
| small | 1 | Low | High (model handles subtle motion well) |
| medium | 2 | Medium | Medium-High (ensure character consistency between frames) |
| large | 2 | High | Variable (may need retakes for smooth transition) |

**Optimization**: Classify aggressively toward `small` when possible. Video models (especially Kling 3.0 and Seedance 2.0) are excellent at interpolating subtle motion from a single frame. Reserve `medium`/`large` for shots where the first and last frames truly look different.

## Labeling in Shot Specs

Every shot spec must include:

```markdown
**Variation**: medium
**Reason**: New character enters from screen-right; first frame shows only Elena, last frame shows both Elena and Marco facing each other.
```

The reason field is critical for review — it explains WHY this classification was chosen and makes it easy to challenge/revise.

## From Huobao Drama: Duration Correlation

Variation type loosely correlates with duration:
- `small` shots: typically 3-6s (subtle change, quick beat)
- `medium` shots: typically 5-10s (need time for change to register)
- `large` shots: typically 8-15s (dramatic visual journey needs time)

But duration is primarily driven by dialogue length + action complexity (see aivp-script quality checks), not variation type alone.
