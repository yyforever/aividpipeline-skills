# Frame Generation Planning

The frame plan tells aivp-image exactly what to generate, in what order, and with what reference materials. This is where the Camera Tree pays off — generation order follows spatial relationships, not timeline order.

## Generation Order

### Rule: Parents Before Children

The Camera Tree determines generation order:

```
1. Root cameras first (establishing shots — widest view of each scene)
2. Then children (medium shots — derived from root frame)
3. Then grandchildren (close-ups — derived from medium shot frames)
```

### Within Same Level: Timeline Order

If two cameras are at the same depth in the tree, generate them in story timeline order.

### Cross-Scene: Scene Order

Process scenes in story order. Each scene's camera tree is independent.

### Example Generation Order

```
Scene 1: Kitchen
  1. Shot 1.1 (cam_0, LS, root) — generate first
  2. Shot 1.2 (cam_1, MS, child of cam_0) — use Shot 1.1 as reference
  3. Shot 1.3 (cam_2, CU, child of cam_1) — use Shot 1.2 as reference
  4. Shot 1.4 (cam_1, MS, same camera as 1.2) — reuse cam_1 reference

Scene 2: Street
  5. Shot 2.1 (cam_3, LS, root) — new scene, fresh generation
  6. Shot 2.2 (cam_4, MS, child of cam_3)
```

## Reference Image Selection

For each frame generation, select reference images from these sources (in priority order):

### 1. Character Portraits

From `script/characters/*.md`, each character has multi-angle portrait specifications:
- **Front** — when character faces camera
- **Side** — when character is in profile
- **Back** — when character faces away

**Match facing direction to portrait angle:**

| Character Facing | Portrait to Use |
|:---:|:---:|
| Facing camera | Front |
| Profile (left or right) | Side |
| Facing away / back to camera | Back |
| 3/4 view | Front (primary) + Side (supplementary) |

### 2. Scene Background

From `script/scenes/*.md`, load the scene background prompt. For root cameras, this is the primary spatial reference.

### 3. Prior Frames (Same Camera)

If another shot from the same `cam_idx` has already been generated, use its frame as a reference. This ensures temporal consistency within the same camera angle.

### 4. Parent Camera Frames (Camera Tree)

For child cameras, use the parent's generated frame as spatial reference:
- **Fully covered**: Parent frame contains everything needed → use parent frame as primary reference, crop/zoom mentally
- **Partially covered**: Parent frame + additional references (character portraits for missing angles, new elements from scene sheet)

### 5. Transition References (ViMax technique)

For complex parent→child transitions where the angle changes significantly:
1. Take parent camera's frame
2. Generate a short "transition video" (virtual camera movement from parent to child angle)
3. Extract the endpoint frame as the child camera's spatial reference

This is expensive (requires an extra video generation) — only use for `large` variation transitions where angle changes dramatically.

## Frame Plan Document Format

```markdown
# Frame Generation Plan — [Project Name]

## Summary

| Metric | Value |
|--------|-------|
| Total frames to generate | 24 |
| First-frame only (small var) | 16 |
| First + last frame (medium/large) | 8 |
| Unique camera positions | 7 |
| Scenes | 3 |

## Generation Queue

### Priority 1: Root Cameras (Establishing Shots)

#### Frame 1 — Shot 1.1 first-frame
- **Camera**: cam_0 (LS, eye-level)
- **Scene**: kitchen-morning
- **References**:
  - Scene bg: `scenes/kitchen-morning.md` prompt
  - Character: @Elena (front) — standing at counter
  - Character: @Marco (back) — seated at table
- **Generation mode**: Text-to-image (no prior frames exist)
- **Notes**: This is the spatial anchor for all kitchen shots

### Priority 2: Child Cameras

#### Frame 2 — Shot 1.2 first-frame
- **Camera**: cam_1 (MS, eye-level)
- **Parent**: cam_0 (Shot 1.1)
- **References**:
  - Prior frame: Shot 1.1 first-frame (spatial reference — crop to medium)
  - Character: @Elena (front) — closer view
- **Generation mode**: Image-to-image (refine from parent frame crop)

#### Frame 3 — Shot 1.3 first-frame
- **Camera**: cam_2 (CU, eye-level)
- **Parent**: cam_1 (Shot 1.2)
- **References**:
  - Prior frame: Shot 1.2 first-frame (spatial reference — crop to close-up)
  - Character: @Elena (front) — face detail
- **Generation mode**: Image-to-image (refine from parent frame crop)

### Priority 3: Last Frames (medium/large variation only)

#### Frame 4 — Shot 1.2 last-frame
- **Variation**: medium
- **References**:
  - Shot 1.2 first-frame (same camera, starting state)
  - Character: @Marco (front) — he has turned around
- **Generation mode**: Image-to-image (modify first-frame per motion description)
```

## Character Visibility Matrix

Track which characters appear in which frames — helps aivp-image know which portraits to reference:

```markdown
| Shot | Frame | @Elena | @Marco | Notes |
|------|-------|:------:|:------:|-------|
| 1.1 | ff | front | back | Elena at counter, Marco seated facing away |
| 1.2 | ff | front | — | Elena only, tighter framing |
| 1.2 | lf | front | front | Marco has turned around (medium variation) |
| 1.3 | ff | front | — | CU of Elena's hands |
```

## Optimization Tips

1. **Batch by scene** — generate all frames for one scene before moving to next (keeps environment consistent)
2. **Reuse frames across shots** — if two shots use the same camera and the scene hasn't changed, the first-frame may be reusable
3. **Skip redundant last-frames** — if a `medium` shot's last-frame is nearly identical to the next shot's first-frame, consider reusing
4. **Parallel generation** — frames from different scenes (independent camera trees) can be generated in parallel
