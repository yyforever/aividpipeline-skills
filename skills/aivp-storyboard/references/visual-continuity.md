# Visual Continuity Guide

Cross-shot visual consistency is the #1 challenge in AI video production. This guide covers four layers of consistency — the same approach ViMax uses to maintain coherence across shots.

## Layer 1: Character Feature Consistency

### Static vs Dynamic Features

From character sheets (`script/characters/*.md`):
- **Static features** (immutable): face shape, hair color/style, body type, eye color, skin tone, distinguishing marks
- **Dynamic features** (per-scene): outfit, accessories, hairstyle changes, makeup

**Rule**: Static features must be IDENTICAL across all shots. Dynamic features can change only at explicitly scripted moments.

### Prompt Anchor Consistency

Each character has a **prompt anchor phrase** (from character sheet) — a fixed text description used in every frame they appear in.

```
Elena prompt anchor: "woman, early 30s, shoulder-length auburn hair, gray blazer over white blouse"
```

Check: Every ff_desc and lf_desc that includes Elena must use this exact anchor or a subset of it. Never introduce new physical traits not in the character sheet.

### Silhouette Distinction

Any two characters sharing a frame must be distinguishable by silhouette alone:
- Different heights
- Different hair styles
- Different clothing shapes
- Different postures

If two characters are too similar, flag in quality checks.

## Layer 2: Character Portrait Angle Matching

### Facing Direction → Portrait Selection

The character sheet specifies front/side/back portraits. Frame descriptions specify facing direction. These must align:

| Description Says | Portrait Used | Correct? |
|:---:|:---:|:---:|
| "facing camera" | Front | ✅ |
| "profile, facing right" | Side | ✅ |
| "back to camera" | Back | ✅ |
| "facing camera" | Side | ❌ |

### Tracking Across Shots

Build a character visibility matrix (see frame-planning.md) and verify:
- Character doesn't teleport (if facing left in shot 3, they should have turned by shot 4)
- Character outfit doesn't change without script reason
- Character's visible body parts match the shot type (don't describe face in a hands-only CU)

## Layer 3: Environment Consistency

### Within-Scene Consistency

All shots in the same scene must share:
- Same lighting conditions (unless time passes in the script)
- Same color palette
- Same background elements (furniture, props, architectural details)
- Same weather/atmosphere

### Camera Tree Enforcement

The camera tree guarantees this structurally:
- Child camera frames are derived from parent frames
- Background elements in a CU must match what's visible in the establishing LS
- Props on a desk in a MS must match their position in the wide shot

### Scene Background Prompts

From `script/scenes/*.md`, each scene has a character-free background prompt. This prompt must be referenced in EVERY frame generation for that scene.

## Layer 4: Temporal Consistency

### Shot-to-Shot Transitions

When cutting between shots in the same scene:
1. **180° Rule**: Camera shouldn't cross the "axis of action" between two characters (they should stay on the same side of frame)
2. **30° Rule**: Each new camera angle should differ by at least 30° from the previous to avoid "jump cut" feel
3. **Match on Action**: If a character is mid-gesture at end of shot A, they should be in the same gesture at start of shot B

### Inter-Shot Frame Pairs (from STAGE)

STAGE validates that the pair (F_i^E, F_{i+1}^S) — end-frame of shot i, start-frame of shot i+1 — is critical:
- Characters should maintain consistent appearance
- Lighting should transition smoothly
- Spatial layout should be coherent

**Check**: For every consecutive shot pair, verify that the last-frame of shot i and first-frame of shot i+1 don't have jarring inconsistencies.

## Consistency Checklist

Run for every storyboard draft:

### Character Checks
- [ ] Every character uses their prompt anchor phrase consistently
- [ ] Static features never change across shots
- [ ] Dynamic features only change at scripted moments
- [ ] Facing direction matches portrait angle in frame plan
- [ ] Character positions within frame are spatially logical
- [ ] Characters don't teleport between consecutive shots
- [ ] Any two characters in same frame are silhouette-distinguishable

### Environment Checks
- [ ] All shots in same scene reference the same scene background prompt
- [ ] Lighting consistent within scene (unless scripted time change)
- [ ] Color palette consistent within scene
- [ ] Props and furniture placement consistent across different angles
- [ ] Background elements visible in CU match what's in the establishing LS

### Temporal Checks
- [ ] 180° rule maintained within dialogue sequences
- [ ] No jump cuts (>30° angle change between consecutive shots)
- [ ] Match on action: ongoing gestures continue across cuts
- [ ] Character outfits match between consecutive shots in same scene
- [ ] Lighting direction consistent between shots in same scene

### Camera Tree Checks
- [ ] Every child camera's content is spatially present in parent's frame
- [ ] Missing info correctly identified for partially covered children
- [ ] Root cameras establish complete scene environment
- [ ] No orphan cameras (every non-root has a parent)

## Common Failures

| Problem | Cause | Fix |
|---------|-------|-----|
| Character's hair color changes | Different wording in different shot descriptions | Use exact prompt anchor phrase |
| Background elements shift | No scene reference in frame generation | Always include scene bg prompt |
| Character teleports | No spatial tracking between shots | Build character position timeline |
| Lighting changes mid-scene | Inconsistent atmosphere descriptions | Copy lighting from scene sheet |
| Outfit changes randomly | Dynamic features described differently | Reference character sheet per shot |
