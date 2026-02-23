# Storyboard Design Guidelines

10 rules for shot composition (distilled from ViMax multi-agent architecture). Apply when writing shot decompositions in Step 3.

## The 10 Rules

1. **Every shot must have a clear narrative purpose** — if you can't state why this shot exists in one sentence, cut it
2. **Close-up = emotion, wide shot = context** — match shot type to narrative function
3. **Reuse camera positions** — only introduce a new camera angle when the framing/angle is significantly different from existing shots in the scene
4. **Mark character names with @tags** — `@Maya` in metadata fields, but use visual descriptions in motion/prompt text
5. **Specify element positions in frame** — "standing at screen-left", "visible in background right" — not just "in the scene"
6. **Only describe what is visible** — if a character is behind the camera or off-screen, don't describe them in the visual prompt
7. **One line of dialogue per character per shot** — if a character speaks twice, split into two shots
8. **Each shot description is self-contained** — never reference another shot ("same as Shot 1.2" is forbidden)
9. **When focusing on a character, specify the body part** — "close-up of her hands" not just "close-up of Maya"
10. **Always specify facing direction** — "facing camera", "facing screen-left", "back to camera" — critical for selecting the correct portrait angle (front/side/back)

## Shot Type Selection Guide

| Narrative Need | Shot Type | Code | When |
|---------------|-----------|:----:|------|
| Establish location | Extreme long shot | ELS | Scene opening, location change |
| Show full scene | Long shot / wide | LS | Multiple characters interacting |
| Balanced dialogue | Medium shot | MS | Normal conversation |
| Emotional nuance | Medium close-up | MCU | Important dialogue delivery |
| Intense emotion | Close-up | CU | Reactions, revelations |
| Detail / symbol | Extreme close-up | ECU | Objects, micro-expressions |

## Camera Angle Meaning

| Angle | Psychological Effect |
|-------|---------------------|
| Eye-level | Neutral, objective |
| Low angle | Power, dominance, threat |
| High angle | Vulnerability, smallness |
| Dutch/tilted | Unease, instability |
| Overhead | Surveillance, god's-eye detachment |

## Pacing Through Shot Selection

- **Tension rising** → shots get progressively tighter (LS → MS → CU → ECU)
- **Release / breath** → cut to wider shot
- **Surprise / reversal** → abrupt shot type change (ECU → LS, or static → sudden movement)
- **Sustained tension** → hold on uncomfortable close-up longer than expected
