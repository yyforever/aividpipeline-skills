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
- **Dialogue** always includes tone in parentheses — this feeds into both video prompt dialogue tags and TTS voice direction
- **ACTION blocks** describe physical movement — important for translating to video prompt motion descriptions
- **Emotional beat markers** (🔴🟡🟢🔵) must appear at every scene head — used in quality checks
- **TRANSITION** notes guide the editor but also inform prompt sequencing
- **Pacing map** at the end = quick validation that the emotional rhythm is correct
