# Narrative Script Template

## Structure

```markdown
# {Title} — Episode {N}

## Episode Summary
- **Duration target:** {e.g., 8-10 minutes}
- **Genre:** {from brief-final.md}
- **Key emotion:** {primary emotional arc}
- **Cliffhanger type:** {revelation / danger / betrayal / choice / discovery}

## Characters in this episode
- {Name} — {role} — {one-line situation}

---

## Scene 1: {Location} — {Time of Day}

**Characters:** {who is present}
**Emotional beat:** 🔴 HOOK

> VISUAL: {What the viewer sees — set, lighting, atmosphere}

**{CHARACTER A}** (tone: {emotional state})
"{Dialogue line}"

> ACTION: {What happens physically}

**{CHARACTER B}** (tone: {emotional state})
"{Dialogue line}"

**[TRANSITION: cut / fade / match cut]**

---

## Scene 2: {Location} — {Time of Day}

**Characters:** {who}
**Emotional beat:** 🟡 BUILD

...

---

## Scene N: {Location} — {Time of Day}

**Emotional beat:** 🔴 CLIMAX → 🔵 CLIFFHANGER

> VISUAL: {final image}

**{CHARACTER}** (tone: {})
"{Final line}"

> CLIFFHANGER: {What is unresolved — stated explicitly}

---

## Episode Pacing Map

| Time | Beat | Scene | Type |
|------|------|-------|------|
| 0:00 | Hook | Scene 1 | 🔴 |
| 0:30 | Build | Scene 1 | 🟡 |
| 1:00 | Peak 1 | Scene 2 | 🟢 |
| ... | ... | ... | ... |
| 8:00 | Climax | Scene N | 🔴 |
| 8:30 | Cliffhanger | Scene N | 🔵 |
```

## Key Formatting Rules

- **VISUAL blocks** describe what the camera sees — written for the human reader, NOT as AI prompts (prompts go in prompts-v{N}.md)
- **Dialogue** always includes tone in parentheses — feeds into video prompt dialogue tags AND TTS voice direction
- **ACTION blocks** describe physical movement — translates to video prompt motion descriptions
- **SOUND blocks** describe non-dialogue audio — BGM cues and sound effects
- **Emotional beat markers** (🔴🟡🟢🔵) + intensity (↑↑↑/↑↑/↑/→/↓) at every scene head
- **TRANSITION** notes guide the editor and inform prompt sequencing
- **Pacing map** at the end = quick validation of emotional rhythm

## Shot-Level Annotations

When writing VISUAL and ACTION blocks, annotate with structured metadata:

```markdown
> VISUAL: [var:small | CU | eye-level | static] Close-up of Elena's face, soft lamplight.
> ACTION: [var:medium | MS | eye-level | static] She reaches for the phone, hand trembling, then pulls back.
> VISUAL: [var:large | LS | low | static] Door bursts open, Marcus stands in the doorway silhouetted against hallway light.
> SOUND: [bgm] Tense strings swell. [sfx] Door slam echoes.
```

Annotation format: `[var:X | shot_type | angle | movement]`
- These tags are used when generating technical prompts
- `var:X` determines reference frame count (1 for small, 2 for medium/large)
- Shot type/angle/movement map directly to structured metadata in prompts-v{N}.md
