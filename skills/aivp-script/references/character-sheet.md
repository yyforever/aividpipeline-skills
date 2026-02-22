# Character Sheet Template

Define every character BEFORE writing scenes. These sheets are reused by:
- `aivp-image` — generate consistent reference images
- `aivp-video` — character anchoring in Kling 3.0 Omni / Seedance 2.0
- `aivp-audio` — voice profile for TTS

## Template

```markdown
# Character: {Name}

## Role
- **Function:** Protagonist / Antagonist / Supporting
- **Core conflict (4 words):** {e.g., "vengeful bride vs cheating fiancé"}

## Visual Appearance
- **Age:** {range, e.g., late 20s}
- **Build:** {slim / athletic / heavy}
- **Hair:** {color, length, style}
- **Skin:** {tone}
- **Clothing style:** {e.g., always in dark formal wear / casual streetwear}
- **Visual tell:** {distinguishing mark for instant recognition — ring, scar, tattoo, specific accessory}
- **Silhouette test:** {can this character be identified from silhouette alone?}

## Voice Profile
- **Tone:** {warm / cold / gravelly / smooth}
- **Accent:** {if any}
- **Speech pattern:** {short sentences / formal / slang-heavy / whispers}
- **Emotional range:** {controlled → explosive / always calm / nervous energy}

## Prompt Anchor Phrase
A single-paragraph description for use as character reference in AI video prompts:

> "{Age} {gender} with {hair} and {build}, wearing {clothing}. {Visual tell}. Expression: {default emotional state}."

Example:
> "Late-20s woman with shoulder-length dark hair and athletic build, wearing a tailored black coat. A thin scar runs along her left jawline. Expression: composed but watchful."
```

## Rules

- **Visual tell is mandatory** — without it, characters blur together in AI-generated video
- **Prompt anchor phrase must be consistent** — copy the exact same text into every shot prompt featuring this character
- Keep clothing changes minimal (1-2 outfits max per episode) for AI consistency
- If two characters appear together, their silhouettes must be distinctly different (height, build, hair, clothing contrast)
