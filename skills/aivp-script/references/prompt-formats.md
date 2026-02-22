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
[Character A: Exhausted Partner, trembling frustrated voice]:
"You never listen to me." (Duration: 5s)

Multi-shot Prompt 2: Close-up reaction, the other partner turns around,
eyes wide. Camera holds steady.
[Character B: Defensive Partner, shouting loudly]:
"Because you never stop blaming!" (Duration: 4s)

Multi-shot Prompt 3: Medium two-shot, both visible.
Exhausted Partner exhales shakily.
[Exhausted Partner, voice cracking]: "I'm not blaming… I'm begging."
Silence. Sad piano chord enters quietly. (Duration: 6s)
```

### Kling 3.0 Key Rules

- **Anchor subjects early** — define characters at prompt start, keep descriptions consistent across shots
- **Explicit motion** — "slowly tracking right" not "camera moves"
- **Cinematic vocabulary** — profile shot, macro close-up, tracking shot, POV, shot-reverse-shot
- **Dialogue format:** `[Character A: Role, tone description]: "dialogue text"`
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

## Prompt-per-Scene Output Format

When generating prompts-v{N}.md, use this structure:

```markdown
# Technical Prompts — v{N}

## Target Model: Kling 3.0 / Seedance 2.0

### Scene 1: {scene title from narrative}

**Shot 1.1** (5s)
{full prompt text}
- Character refs: @CharA, @CharB
- Audio: native dialogue / silent + TTS later

**Shot 1.2** (4s)
{full prompt text}

### Scene 2: {scene title}
...
```

Each shot prompt must be **self-contained** — copyable directly into the model's input.
