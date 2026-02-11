---
name: seedance-script
description: >
  Generate structured video scripts for AI video production.
  Use when user requests "write a script", "video script", "screenplay",
  "narration text", "dialogue", "script outline", or needs to create
  scripts for shorts, tutorials, stories, or explainer videos.
  Supports multiple formats including short-form (TikTok/Reels),
  tutorial/how-to, narrative/story, and documentary styles.
---

# Seedance Script

Generate structured video scripts with proper formatting for AI video production.

<!-- TODO: Implement all sections below -->

## References

- [Script Formats](references/formats.md) — Format templates for different video types
- [Script Examples](references/examples.md) — High-performing script examples

## Script Formats

<!-- TODO: Define format specs for each type -->

### Short-form (< 60s)
- Hook (0-3s) → Problem/Context (3-15s) → Solution/Content (15-45s) → CTA (45-60s)

### Tutorial / How-to
- Intro + Promise → Step-by-step sections → Recap + CTA

### Narrative / Story
- Act structure (3-act or 5-act) with scene breaks, dialogue, and action lines

### Documentary / Explainer
- Thesis → Evidence sections → Counterpoint → Conclusion

## Output Format

<!-- TODO: Define JSON schema for structured script output -->

```json
{
  "title": "...",
  "format": "short-form|tutorial|narrative|documentary",
  "duration_estimate": "60s",
  "sections": [
    {
      "id": 1,
      "type": "hook|body|cta",
      "duration": "3s",
      "narration": "...",
      "visual_notes": "...",
      "on_screen_text": "..."
    }
  ]
}
```
