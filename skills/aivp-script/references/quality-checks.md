# Script Quality Checks

Run these checks before presenting each draft to the user.

## Structure Checks

- [ ] **Hook window** — Does the first 15 seconds grab attention? (mid-crisis, not exposition)
- [ ] **Emotional pacing** — Is there a spike (↑↑ or ↑↑↑) every 60-90 seconds? (count in pacing map)
- [ ] **Cliffhanger** — Does every episode/segment end with unresolved tension?
- [ ] **Scene count** — ≤ 5 distinct locations per episode?
- [ ] **Duration** — Total estimated time within target range?

## Dialogue Checks

- [ ] **Compression** — Does every line advance plot OR reveal character? (cut lines that do neither)
- [ ] **Tone tags** — Does every dialogue line have an emotional tone in parentheses?
- [ ] **Binary conflict** — Can each character's core conflict be stated in 4 words?
- [ ] **One line per character per shot** — No character speaks twice in a single shot?

## Character Checks

- [ ] **Static/dynamic split** — Are character sheets split into static features (immutable) and dynamic features (per-scene)?
- [ ] **Visual tells present** — Are character visual tells mentioned in at least first appearance?
- [ ] **Silhouette distinction** — Can any two characters sharing a shot be told apart by silhouette?
- [ ] **Facing direction** — Is every character's facing direction specified in shot metadata?
- [ ] **Prompt anchor consistency** — Does the prompt anchor phrase use ONLY static features + default outfit?

## Scene Checks

- [ ] **Scene sheets exist** — Does every unique location have a `scenes/{slug}.md` file?
- [ ] **Scene prompts character-free** — Do scene background prompts contain "No people"?
- [ ] **Lighting specified** — Does every scene sheet have source, color temperature, time of day?

## Technical Alignment Checks

- [ ] **1:1 coverage** — Does every narrative scene have corresponding technical prompts?
- [ ] **Structured metadata** — Does every shot have: variation, shot_type, angle, movement, duration, emotion?
- [ ] **Character consistency** — Do prompt descriptions match character sheets exactly? (prompt anchor phrase)
- [ ] **Motion specificity** — Are camera movements explicit (not "camera moves" but "slow tracking right")?
- [ ] **Duration feasibility** — Is each shot ≤ 15 seconds? (Kling 3.0 max)
- [ ] **Shot count feasibility** — ≤ 6 shots per multi-shot prompt? (Kling 3.0 max)
- [ ] **Audio tags** — Are dialogue lines in correct `[Character Name, tone]: "text"` format?
- [ ] **Variation type labeled** — Every shot has `small`/`medium`/`large` tag?
- [ ] **Frame decomposition** — medium/large shots have both first-frame and last-frame descriptions?
- [ ] **Frames are static** — No motion verbs in first-frame or last-frame descriptions?
- [ ] **Motion uses visual descriptions** — No character names in motion_desc (use appearance instead)?
- [ ] **Character visibility tracked** — First-frame and last-frame list visible characters with facing direction?
- [ ] **Dual format sync** — Shot decomposition and multi-shot prompts cover same scenes, same shot count?

## Audio Checks

- [ ] **Three-layer audio** — Does every shot have dialogue + bgm + sfx fields (even if "(none)" or "(continue)")?
- [ ] **BGM continuity** — Are BGM prompts marked "(continue)" when music carries over between shots?
- [ ] **SFX specificity** — Are sound effects concrete ("glass clinking", not "ambient sounds")?

## Micro-Drama Specific

- [ ] **3-7-21 rule** — Attention grabbed in 3s, conflict in 7s, first emotional cycle in 21s?
- [ ] **No connective tissue** — Are filler/transition moments cut or minimized?
- [ ] **Storyboard guideline #8** — Is every shot description self-contained (no cross-references)?

## Report Format

After running checks, output:

```markdown
### Quality Check Results — script-v{N}

✅ Passed: {count}/{total}
⚠️ Issues:
1. {description} — Scene {X}, Shot {Y}
2. {description}

Recommendation: {fix / minor tweak / ready for review}
```
