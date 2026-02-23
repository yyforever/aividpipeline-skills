# Camera Tree Construction Guide

The Camera Tree is the core innovation from ViMax — a spatial hierarchy that ensures visual consistency across shots by establishing explicit parent-child relationships between camera positions.

## Why Camera Tree?

Without a camera tree, each shot is generated independently, leading to:
- Inconsistent backgrounds between wide and close-up shots of the same scene
- Characters appearing in wrong positions when cutting between angles
- Environment details changing between shots

The camera tree solves this by ensuring child camera frames are spatially derived from parent camera frames.

## Core Concepts

### Camera Position

A unique combination of:
- **Location** — where in the scene the camera sits
- **Framing** — what portion of the scene is visible (ELS → LS → MS → MCU → CU → ECU)
- **Angle** — camera orientation (eye-level, low, high, dutch, overhead)

Two shots share a camera position if they have the same location + framing + angle, differing only in what happens within the frame (character actions, dialogue).

### Parent-Child Relationship

Camera B is a **child** of Camera A when:
- Camera A's frame **spatially contains** the content visible in Camera B
- Typically: wider shot (parent) → tighter shot (child)

```
Camera 0: Wide shot of office        ← Root (widest view)
  ├── Camera 1: Medium shot of desk  ← Child (subset of Camera 0's frame)
  │   └── Camera 3: CU of hands     ← Grandchild (subset of Camera 1's frame)
  └── Camera 2: Medium shot of door  ← Child (different part of Camera 0's frame)
```

### Fully Covers vs Partially Covers

- **Fully covers**: Parent frame contains ALL visual elements needed for child frame
  - Example: Wide shot of room → Close-up of table (table is fully visible in wide shot)
- **Partially covers**: Parent frame shows the area but misses some elements
  - Example: Wide shot showing character's back → Close-up of character's face
  - The `missing_info` field records what's not visible: "Character's front face and expression"

## Construction Process

### Step 1: Group Shots by Scene

```markdown
Scene: office-corner
  Shot 1.1 — LS, eye-level (establishing)
  Shot 1.2 — MS, eye-level (dialogue)
  Shot 1.3 — CU, eye-level (reaction)
  Shot 1.4 — MCU, low-angle (power moment)
```

### Step 2: Identify Unique Camera Positions

Within each scene, cluster shots that share the same camera setup:

```markdown
Camera 0: LS eye-level → [Shot 1.1]
Camera 1: MS eye-level → [Shot 1.2]
Camera 2: CU eye-level → [Shot 1.3]
Camera 3: MCU low-angle → [Shot 1.4]
```

### Step 3: Assign cam_idx to Each Shot

Each shot gets its camera position index. Shots sharing a camera position share `cam_idx`.

### Step 4: Build Parent-Child Relationships

For each non-root camera, determine:
1. Which camera is its parent? (the tightest camera that still contains this one's content)
2. Which specific shot from the parent is the best reference? (`parent_shot_idx`)
3. Does the parent fully cover the child? (`is_parent_fully_covers_child`)
4. What's missing? (`missing_info`)

### Step 5: Determine Generation Order

**Parents first, children after.** Within the same level, follow shot timeline order.

```
Generation Order:
1. Camera 0, Shot 1.1 (root — no parent, generate from scene bg + character portraits)
2. Camera 1, Shot 1.2 (child of Cam 0 — use Shot 1.1 as spatial reference)
3. Camera 2, Shot 1.3 (child of Cam 1 — use Shot 1.2 as spatial reference)
4. Camera 3, Shot 1.4 (child of Cam 0 — different angle, needs character front portrait)
```

## Camera Tree Document Format

```markdown
# Camera Tree — [Project Name]

## Scene: office-corner

### Camera Positions

| cam_idx | Type | Angle | Shots | Parent | Covers? | Missing |
|---------|------|-------|-------|--------|---------|---------|
| 0 | LS | eye-level | 1.1 | — (root) | — | — |
| 1 | MS | eye-level | 1.2 | cam_0 (shot 1.1) | yes | — |
| 2 | CU | eye-level | 1.3 | cam_1 (shot 1.2) | yes | — |
| 3 | MCU | low-angle | 1.4 | cam_0 (shot 1.1) | no | Front face detail, low-angle perspective |

### Tree Visualization

​```
cam_0 [LS eye-level] ← root
  ├── cam_1 [MS eye-level] ← fully covered
  │   └── cam_2 [CU eye-level] ← fully covered
  └── cam_3 [MCU low-angle] ← partially covered (missing: front face)
​```

### Transition Notes

- cam_0 → cam_1: Standard cut, same angle, tighter framing
- cam_1 → cam_2: Push-in to close-up, continuous motion possible
- cam_0 → cam_3: Angle change (eye → low), needs separate generation with character portrait supplement
```

## Rules

1. **Every scene needs at least one root camera** — typically the establishing/wide shot
2. **Minimize camera count** — reuse positions across shots when possible (ViMax guideline #3)
3. **One camera move = one camera position** — if a camera pans significantly, it becomes a new position afterward
4. **Cross-scene cameras are independent** — camera trees don't span across different locations
5. **Missing info drives reference selection** — if parent doesn't fully cover child, the frame plan must include additional references (character portraits, new angle renders)

## From MovieAgent: Hierarchical CoT Planning

MovieAgent extends the camera tree concept with Chain-of-Thought reasoning:

1. **Scene-level planning**: Director agent determines scene purpose and mood
2. **Shot-level planning**: Storyboard artist decomposes scenes into shots
3. **Camera-level planning**: Cinematographer assigns camera setups

This hierarchical approach can be adapted: think about WHY each camera position exists (narrative purpose) before HOW it relates to other cameras (spatial relationship).
