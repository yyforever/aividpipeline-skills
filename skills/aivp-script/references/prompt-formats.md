# AI Video Model Prompt Formats

Per-shot technical prompts must match the target model's syntax. This reference covers the two primary models as of Feb 2026.

## Universal Prompt Formula

```
[Shot Type] + [Subject Action] + [Emotional State] + [Lighting/Atmosphere] + [Camera Movement] + [Duration]
```

Front-load the most important elements — AI models weight the first 20-30 words most heavily.

---

## Kling 3.0 (Kuaishou)

### Single Shot

```
[Camera: medium close-up, slowly tracking right]
A woman in a dark red dress stands at a rain-soaked window,
her fingers tracing the glass, expression shifting from calm to anguish.
Warm interior light contrasts with cold blue rain outside.
Soft piano note fades in.
```

### Multi-Shot (up to 6 shots per generation)

```
Master Prompt: A tense confrontation in a dimly lit kitchen late at night.

Multi-shot Prompt 1: Medium shot, a woman sets down a plate too hard,
ceramic clinks sharply. Warm overhead light, shadows on walls.
[Elena, trembling frustrated voice]: "You never listen to me." (Duration: 5s)

Multi-shot Prompt 2: Close-up reaction, the other partner turns around,
eyes wide. Camera holds steady.
[Marco, shouting loudly]: "Because you never stop blaming!" (Duration: 4s)

Multi-shot Prompt 3: Medium two-shot, both visible.
Elena exhales shakily.
[Elena, voice cracking]: "I'm not blaming… I'm begging."
Silence. Sad piano chord enters quietly. (Duration: 6s)
```

### Kling 3.0 Key Rules

- **Anchor subjects early** — define characters at prompt start, keep descriptions consistent across shots
- **Explicit motion** — "slowly tracking right" not "camera moves"
- **Cinematic vocabulary** — profile shot, macro close-up, tracking shot, POV, shot-reverse-shot
- **Dialogue format:** `[Character Name, tone description]: "dialogue text"` — name must match character sheet exactly
- **Tone keywords in dialogue tags** improve output: controlled, trembling, whispering, shouting
- **Max 6 shots** per generation, **max 15s** per shot
- **Duration tag** at end of each shot

---

## Seedance 2.0 (ByteDance)

### Basic Structure

```
Prompt = [Subject] + [Motion] + [Scene] + [Lens] + [Style]
```

### Image-to-Video

Focus ONLY on motion/change (don't describe what's already in the reference image):

```
The woman slowly turns her head toward camera,
eyes narrowing with suspicion.
Camera: slow zoom in. Dramatic side lighting.
```

### Multi-Shot (via "lens switch")

```
Close-up of hands gripping a letter, trembling slightly.
Lens switch.
Medium shot, the woman looks up from the letter,
face shifting from confusion to fury.
Lens switch.
Wide shot of the room, she stands abruptly,
chair scraping back, letter falling to the floor.
```

### All-Round Reference Mode

When using reference files (up to 12: images/videos/audio):

```
@Image1 is the main character.
@Image2 is the office environment.
The character walks into the office, looks around nervously,
then sits down at the desk.
Camera: follows from behind, then orbits to face.
```

### Seedance 2.0 Key Rules

- **Degree adverbs are critical** — "quickly" not "moves", "violently" not "pushes"
- **"Lens switch"** triggers multi-shot within one generation
- **Negative prompts don't work** — describe what you want, not what you don't
- **Camera keywords:** surround, aerial, zoom, pan, follow, handheld
- **For unfixed camera prompts, select "unfixed camera" in parameters**
- **Gentle motion words** for smooth results: slow, gentle, continuous, natural, smooth

---

## Structured Shot Metadata

Every shot in `prompts-v{N}.md` must include these structured fields (not buried in prose):

### Required Metadata Per Shot

| Field | Values | Purpose |
|-------|--------|---------|
| `variation` | small / medium / large | Determines ref image count |
| `shot_type` | ELS / LS / MS / MCU / CU / ECU | Framing — 远景/全景/中景/中近景/近景/特写 |
| `angle` | eye-level / low / high / dutch / overhead | Camera angle |
| `movement` | static / push / pull / pan / track / follow / crane | Camera movement |
| `duration` | 3-15s | Shot length |
| `emotion` | ↑↑↑ / ↑↑ / ↑ / → / ↓ | Intensity marker |
| `characters` | [@Name, facing:direction] | Who is visible + which way they face |
| `scene_ref` | scene slug | Links to scene sheet |
| `is_primary` | true/false | Is this the establishing shot for this scene? |

### Three-Layer Audio

Every shot has three audio fields:

| Field | Content | Downstream |
|-------|---------|-----------|
| `dialogue` | `[Name, tone]: "text"` or `(none)` | aivp-video (native) + aivp-audio (TTS) |
| `bgm` | Music description or `(continue)` | aivp-audio (music generation) |
| `sfx` | Sound effects description or `(none)` | aivp-audio (foley/SFX) |

---

## Shot Decomposition

Each shot decomposes into **static snapshot pair + motion instruction**, matching how video models work (first-frame → last-frame interpolation).

### Variation Type

| Type | Meaning | Reference Images | Video Model Mode |
|------|---------|:----------------:|-----------------|
| `small` | Subtle motion (expression change, slight turn) | 1 (first frame only) | First-Frame-to-Video |
| `medium` | Moderate change (character moves, gesture) | 2 (first + last frame) | First+Last-Frame-to-Video |
| `large` | Major change (new character enters, scene shift) | 2 (first + last frame) | First+Last-Frame-to-Video |

### Frame Types

| Type | Purpose | When to Use |
|------|---------|------------|
| `first` | Static state before action begins | Every shot |
| `key` | Peak tension / emotional climax moment | High-emotion shots |
| `last` | Final state after action completes | medium/large variation shots |

### Motion Description Rules (from ViMax)

- **No character names in motion_desc** — use visual appearance instead
  - ❌ "Maya walks to the door"
  - ✅ "The woman in the gray blazer with blue-light glasses walks to the door"
- Why: video models don't understand character names, only visual descriptions
- Character names go in the `characters` metadata field, not in motion text

### Character Visibility Tracking

Track which characters are visible in first-frame vs last-frame:

```markdown
- Characters (first frame): [@Maya, facing:camera], [@Ravi, facing:away]
- Characters (last frame): [@Maya, facing:camera]  ← Ravi has exited
```

This tells aivp-image exactly which character portraits to composite into each frame.

---

## Dual Output Format

Technical prompts have two complementary formats per scene in `prompts-v{N}.md`:

### 1. Shot Decomposition (for aivp-image + aivp-storyboard)

```markdown
**Shot 2.1** (5s) | var:medium | CU | eye-level | static | ↑↑
- Scene: office-corner
- Characters (ff): [@Elena, facing:camera, hand only]
- Characters (lf): [@Elena, facing:camera, hand open]
- First frame: "Close-up of woman's hand gripping a crumpled letter,
  knuckles white, warm side lighting from window"
- Last frame: "Same close-up, hand now open, letter mid-fall,
  fingers trembling slightly"
- Motion: "The hand in gray blazer sleeve slowly unclenches,
  letter slips and begins to fall"
- Dialogue: [Elena, barely audible]: "It was all a lie."
- BGM: (continue — tense strings from previous shot)
- SFX: paper rustling, sharp exhale
```

### 2. Multi-Shot Prompts (for aivp-video — Kling 3.0)

```markdown
Master Prompt: {scene context — location, lighting, mood}

Multi-shot Prompt 1: {shot description with visual appearance, not names}
[Character Name, tone]: "dialogue" (Duration: Xs)

Multi-shot Prompt 2: ...
```

**Rules for multi-shot groups:**
- Max 6 shots per group (Kling limit)
- Dialogue-heavy → group by conversation beat
- Action-heavy → group by continuous motion sequence
- Master Prompt = shared context (location, lighting, mood)

Both formats cover the same scenes — decomposition is the detailed spec, multi-shot is the production-ready input. They must stay in sync.
