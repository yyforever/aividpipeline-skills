# Character Sheet Template

Define every character BEFORE writing scenes. These sheets are reused by:
- `aivp-image` — generate consistent reference images (multi-angle portraits)
- `aivp-video` — character anchoring in Kling 3.0 / Seedance 2.0
- `aivp-audio` — voice profile for TTS

## Template

```markdown
# Character: {Name}

## Role
- **Function:** Protagonist / Antagonist / Supporting
- **Core conflict (4 words):** {e.g., "vengeful bride vs cheating fiancé"}

## Static Features (immutable across all scenes)
- **Age:** {range, e.g., late 20s}
- **Gender:** {for prompt clarity}
- **Build:** {slim / athletic / heavy}
- **Height:** {relative — tallest / medium / shortest of cast}
- **Hair:** {color, length, style}
- **Skin:** {tone}
- **Face:** {key distinguishing facial features}
- **Visual tell:** {distinguishing mark — ring, scar, tattoo, specific accessory}
- **Silhouette test:** {can this character be identified from silhouette alone?}

## Dynamic Features (may change per scene)
- **Default outfit:** {primary clothing for most scenes}
- **Alt outfits:** {list if character changes clothes — max 2 per episode}
- **Accessories:** {items that appear/disappear}
- **Grooming state:** {e.g., starts clean-shaven, later has stubble}

## Voice Profile
- **Tone:** {warm / cold / gravelly / smooth}
- **Accent:** {if any}
- **Speech pattern:** {short sentences / formal / slang-heavy / whispers}
- **Emotional range:** {controlled → explosive / always calm / nervous energy}

## Multi-Angle Portrait Guide
Downstream aivp-image generates 3 standard portraits per character:
1. **Front** (full-body, neutral pose) — generated first from text description
2. **Side** (full-body, 3/4 angle) — generated using front portrait as reference
3. **Back** (full-body, rear view) — generated using front portrait as reference

Generation order matters: front is the anchor, side/back must reference it.

## Prompt Anchor Phrase
A single-paragraph description using ONLY static features + default outfit. This exact text is copied into every shot prompt featuring this character:

> "{Age} {gender} with {hair} and {build}, wearing {default outfit}. {Visual tell}. Expression: {default emotional state}."

For scenes with alt outfits, append: "In this scene wearing {alt outfit}" after the anchor phrase.
```

## Rules

- **Static/dynamic split is mandatory** — static features never change, dynamic features are scene-specific
- **Visual tell is mandatory** — without it, characters blur together in AI-generated video
- **Prompt anchor phrase uses static features only** — dynamic changes are appended per-scene
- **Silhouettes must be distinct** — when two characters appear together, height + build + hair + clothing must contrast
- Keep outfit changes minimal (1-2 per episode) for AI consistency
- **Face direction default** — note which way character typically faces (important for multi-angle portraits)
