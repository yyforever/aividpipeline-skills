# Script Quality Checks

Run these checks before presenting each draft to the user.

## Structure Checks

- [ ] **Hook window** — Does the first 15 seconds grab attention? (mid-crisis, not exposition)
- [ ] **Emotional pacing** — Is there a spike every 60-90 seconds? (count 🟢 markers in pacing map)
- [ ] **Cliffhanger** — Does every episode/segment end with unresolved tension?
- [ ] **Scene count** — ≤ 5 distinct locations per episode?
- [ ] **Duration** — Total estimated time within target range?

## Dialogue Checks

- [ ] **Compression** — Does every line advance plot OR reveal character? (cut lines that do neither)
- [ ] **Tone tags** — Does every dialogue line have an emotional tone in parentheses?
- [ ] **Binary conflict** — Can each character's core conflict be stated in 4 words?

## Technical Alignment Checks

- [ ] **1:1 coverage** — Does every narrative scene have corresponding technical prompts?
- [ ] **Character consistency** — Do prompt descriptions match character sheets exactly? (use prompt anchor phrase)
- [ ] **Motion specificity** — Are camera movements explicit (not "camera moves" but "slow tracking right")?
- [ ] **Duration feasibility** — Is each shot ≤ 15 seconds? (Kling 3.0 max)
- [ ] **Shot count feasibility** — ≤ 6 shots per multi-shot prompt? (Kling 3.0 max)
- [ ] **Audio tags** — Are dialogue lines in correct `[Character Name, tone]: "text"` format? Name must match character sheet exactly.
- [ ] **Variation type labeled** — Every shot has `small`/`medium`/`large` tag?
- [ ] **Frame decomposition** — medium/large shots have both first-frame and last-frame descriptions?
- [ ] **First-frame describes static state** — No motion verbs in first-frame descriptions?
- [ ] **Last-frame describes static state** — No motion verbs in last-frame either (use "standing mid-stride" not "walking")?
- [ ] **Dual format sync** — Shot decomposition and multi-shot prompts cover same scenes, same shot count?

## Micro-Drama Specific

- [ ] **3-7-21 rule** — Attention grabbed in 3s, conflict in 7s, first emotional cycle in 21s?
- [ ] **Visual tells** — Are character visual tells present in at least the first appearance?
- [ ] **No connective tissue** — Are filler/transition moments cut or minimized?

## Report Format

After running checks, output:

```markdown
### Quality Check Results — script-v{N}

✅ Passed: {count}/{total}
⚠️ Issues:
1. {description} — Scene {X}, Line {Y}
2. {description}

Recommendation: {fix / minor tweak / ready for review}
```
