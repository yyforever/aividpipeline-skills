# Scene Sheet Template

Scenes (locations) are independent entities, not just narrative labels. Each scene gets a dedicated sheet used by:
- `aivp-image` — generate scene background images
- `aivp-video` — environment consistency across shots in the same location
- `aivp-edit` — transition decisions between scenes

## Template

```markdown
# Scene: {Location Name}

## Environment
- **Type:** interior / exterior / mixed
- **Specific location:** {e.g., "corner office, 40th floor, tech company HQ"}
- **Key objects:** {desk, monitors, glass walls — items that define the space}
- **Scale:** {intimate / room-sized / open / vast}

## Lighting
- **Source:** {window / overhead fluorescent / lamplight / neon}
- **Color temperature:** {warm golden / cold blue-white / mixed}
- **Time of day:** {morning / afternoon / night / unspecified}
- **Mood:** {sterile / cozy / oppressive / clinical}

## Atmosphere
- **Ambient sound:** {server hum / city traffic / silence / crowd murmur}
- **Color palette:** {dominant colors — "blue-gray with warm amber accents"}
- **Texture:** {sleek glass / rough concrete / worn wood}

## Scene Prompt
A single-paragraph description for generating the empty scene background:

> "{Interior/Exterior} of {location}. {Key objects}. {Lighting description}. {Color palette}. {Atmosphere}. No people."

## Shots in this scene
- {list shot IDs that use this location — filled during prompt generation}

## Reuse count
- {how many shots use this scene — higher count = more important to get the background right}
```

## Rules

- **One sheet per unique location** — even if the script visits it in multiple scenes
- **"No people" in scene prompt** — background images must be character-free for compositing flexibility
- **Lighting changes get a variant** — same location at night vs day = two scene sheets (or one sheet with lighting variants)
- **Max 5 unique scenes per episode** — constraint from micro-drama structure
- **Save to:** `script/scenes/{location-slug}.md`
