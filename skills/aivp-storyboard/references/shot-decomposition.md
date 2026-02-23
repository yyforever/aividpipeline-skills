# Shot Decomposition Rules

Every shot decomposes into a **3-tuple**: first-frame (static) + last-frame (static) + motion (dynamic).

This matches how modern video generation models work:
- **First-frame-to-video**: Kling 3.0, Seedance 2.0 (first_last_frames mode), Veo 3.1
- **First+Last-frame-to-video**: Seedance 2.0, Veo 3.1, STAGE framework

## The 3-Tuple

### First Frame (ff_desc)

A **pure static snapshot** of the very first moment of the shot.

Rules:
- ✅ Describe compositional elements, character postures, environment, lighting, color
- ✅ Include shot type, angle, and composition
- ✅ Specify character positions within frame ("screen-left", "center", "background-right")
- ✅ Specify character facing directions ("facing camera", "profile facing left", "back to camera")
- ✅ Describe only what is visible
- ❌ No ongoing actions ("He is about to stand up" → "He is sitting on the chair, leaning slightly forward")
- ❌ No motion verbs ("walking" → "mid-stride, left foot forward")
- ❌ No character names in the description (use visual features instead for video model compatibility)

Example:
```
Medium shot at eye level. A tall man in a blue shirt (short brown hair, angular jaw)
stands at screen-right, captured in profile facing right. A young woman with pixie-cut
black hair in a green cardigan stands at screen-left, both hands on a shopping cart handle,
gaze lowered. Shelves of colorful product packaging line both sides. Cool fluorescent
overhead lighting. Stable horizontal composition, shallow depth of field on subjects.
```

### Last Frame (lf_desc)

A **pure static snapshot** of the final moment of the shot. Only required for `medium` and `large` variation shots.

Rules:
- Same rules as first frame
- Must be logically consistent with first frame + motion description
- Must reflect the final state after all described motion completes
- All character position/posture changes from motion must be reflected

Example (continuing from above, after the man turns around):
```
Medium shot at eye level. The tall man in blue shirt now faces screen-left toward
the woman, expression shifting to surprise, mouth slightly open. The woman has looked up
from the cart, meeting his gaze, one hand still on the cart handle. Same aisle environment,
same lighting. Characters now face each other across center frame.
```

### Motion Description (motion_desc)

Describes all movement between first and last frame.

Rules:
- **Separate camera movement from subject movement**
  - Camera: "Static camera" / "Slow dolly in" / "Pan left to right" / "Crane up"
  - Subject: "The man in blue shirt slowly turns to face screen-left"
- **Use visual appearance, NOT character names** (critical for video models)
  - ❌ "Maya walks to the door"
  - ✅ "The woman in the gray blazer with blue-light glasses walks to the door"
- **Use degree adverbs** for Seedance 2.0 compatibility
  - ❌ "moves" → ✅ "slowly moves"
  - ❌ "pushes" → ✅ "gently pushes" or "violently pushes"
- **Include dialogue delivery if present** (for lip sync reference)
  - "The man in blue shirt says: 'I didn't expect to see you here.' — tone: surprised, soft"

Example:
```
Static camera. The tall man in blue shirt (short brown hair, angular jaw) slowly turns
from profile to face screen-left, expression shifting from neutral to surprised recognition.
The woman with pixie-cut black hair raises her gaze from the shopping cart to meet his eyes.
```

## Self-Contained Rule

Each shot's decomposition must be **completely self-contained** — never reference another shot:
- ❌ "Same as Shot 1.2 but tighter"
- ❌ "Continuing from previous shot"
- ✅ Full standalone description including all environmental context

This is ViMax storyboard guideline #8 and is critical because:
1. Shots may be generated out of order (camera tree determines generation sequence)
2. Video model prompts are processed independently
3. Downstream tools (aivp-image) need complete context per frame

## Character References in Descriptions

Within ff_desc and lf_desc, introduce characters with parenthetical visual features on first mention:

```
A woman (early 30s, shoulder-length auburn hair, gray blazer over white blouse)
sits at screen-center facing camera...
```

After first mention within the same description, use shortened visual reference:
```
...the auburn-haired woman lifts her coffee cup...
```

Map these to character sheet prompt anchors in the shot metadata (not in the description text).

## Body Part Specificity

When the shot focuses on a character, specify WHICH body part is the focus:
- ❌ "Close-up of Maya"
- ✅ "Close-up of her hands gripping the letter, knuckles white"
- ✅ "Extreme close-up of his eyes, pupils dilating slightly"

This directly tells aivp-image what to generate and which character portrait angle to use.

## From STAGE: Start-End Frame Pairs

The STAGE framework (2025) validates this decomposition approach at scale:
- Start-end frame pairs provide **structured narrative control**
- The pair (F_i^E, F_{i+1}^S) — end of shot i, start of shot i+1 — explicitly models **inter-shot transitions**
- Multi-shot memory packs ensure **long-range entity consistency**
- Their ConStoryBoard dataset (100K clips) confirms this is the optimal representation for multi-shot video generation
