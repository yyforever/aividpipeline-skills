# Storyboard Quality Checks

Run these checks before presenting each draft to the user.

## Shot Decomposition Checks

- [ ] **Static first-frame** — No motion verbs in ff_desc (no "walking", "turning", "reaching")
- [ ] **Static last-frame** — No motion verbs in lf_desc
- [ ] **Last-frame exists** — medium/large variation shots have lf_desc; small variation shots omit it
- [ ] **Motion uses appearance** — motion_desc uses visual features, never character names
- [ ] **Self-contained** — No shot references another shot ("same as Shot 1.2" is forbidden)
- [ ] **Body part specified** — CU/ECU shots specify which body part is the focus
- [ ] **Facing direction** — Every character mention includes facing direction
- [ ] **Position in frame** — Character positions specified ("screen-left", "center", "background-right")
- [ ] **Variation labeled** — Every shot has small/medium/large with reason
- [ ] **Variation correctly classified** — Review reason against classification rules

## Camera Tree Checks

- [ ] **Root exists** — Every scene has at least one root camera (establishing shot)
- [ ] **Camera reuse** — Cameras are reused where possible (not one camera per shot)
- [ ] **Parent-child logical** — Parent frames spatially contain child content
- [ ] **Missing info documented** — Partially covered children have missing_info filled
- [ ] **Generation order follows tree** — Parents generated before children
- [ ] **Camera count reasonable** — Typically 2-5 camera positions per scene

## Frame Plan Checks

- [ ] **All frames planned** — Every first-frame has a generation entry; medium/large have last-frame entry
- [ ] **References specified** — Each frame has at least one reference (character portrait or scene bg)
- [ ] **Portrait angle matches** — Character facing direction matches selected portrait angle (front/side/back)
- [ ] **Scene bg included** — Root camera frames reference scene background prompt
- [ ] **Parent referenced** — Child camera frames reference parent frame as spatial anchor
- [ ] **Total frame count** — Reasonable for project scope (not over-generating)

## Visual Continuity Checks

- [ ] **Prompt anchor consistent** — Same character described with same features in every shot
- [ ] **Static features frozen** — No character's immutable features change between shots
- [ ] **Environment consistent** — Same scene has same lighting/props/colors across shots
- [ ] **180° rule** — Camera doesn't cross action axis in dialogue sequences
- [ ] **No teleportation** — Character positions logically connected between consecutive shots
- [ ] **Outfit tracking** — Character outfits match between shots unless scripted change
- [ ] **Silhouette distinction** — Any two characters sharing a frame are distinguishable by silhouette

## Production Spec Checks

- [ ] **Dual format present** — Every shot has both image spec AND video prompt
- [ ] **Image spec complete** — Generation mode, references, prompt, resolution all specified
- [ ] **Video prompt complete** — Motion prompt, input frames, duration, audio cues all present
- [ ] **Model-specific syntax** — Prompts follow target model's format (Seedance 2.0 primary / Kling 3.0 fallback)
- [ ] **Duration specified** — Every shot has duration in seconds (3-15s range; Seedance max 15s, Kling max 10s)
- [ ] **Audio layers present** — dialogue + bgm + sfx for every shot (even if "(none)")
- [ ] **Multi-shot groups valid** — Seedance: ≤ 4 lens switches per generation; Kling: ≤ 6 shots per group, no cross-scene

## Pacing & Rhythm Checks

- [ ] **Shot type variety** — Not all same shot type in sequence (alternate wide/medium/close)
- [ ] **Tension through framing** — Progressive tightening (LS→MS→CU) during tension buildup
- [ ] **Breath shots** — Wide/establishing shots after intense close-up sequences
- [ ] **Duration rhythm** — Not all shots same length; vary 3-10s
- [ ] **Total duration** — Sum of all shot durations matches target video length (±10%)

## Structural Checks

- [ ] **Coverage complete** — Every narrative scene has corresponding storyboard shots
- [ ] **Scene transitions marked** — Clear break between scene changes
- [ ] **Establishing shots present** — Each new scene/location has an establishing shot
- [ ] **Script alignment** — Shot count and content match prompts-final.md

## Report Format

```markdown
### Storyboard Quality Check — storyboard-v{N}

**Summary**: ✅ {passed}/{total} checks passed

**Issues Found**:
1. ⚠️ Shot 2.3 ff_desc contains motion verb "reaching" → rewrite as static pose
2. ⚠️ Camera tree: Scene 2 missing root camera → add establishing LS
3. ❌ Shot 3.1 motion_desc uses character name "Elena" → replace with visual description

**Statistics**:
- Total shots: {N}
- Camera positions: {N}
- Frames to generate: {N} (ff) + {N} (lf) = {N} total
- Estimated video duration: {N}s ({N}min {N}s)
- Small/Medium/Large: {N}/{N}/{N}

**Recommendation**: {fix issues / minor tweaks / ready for approval}
```
