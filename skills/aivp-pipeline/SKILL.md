---
name: aivp-pipeline
description: Orchestrate end-to-end AI video production by chaining aivp skills together. Use when the user requests "Make a video from scratch", "Full video pipeline", "End to end video", or wants to run the complete production workflow.
metadata:
  author: aividpipeline
  version: "0.1.0"
  tags: pipeline, orchestration, workflow, end-to-end
---

# AIVP Pipeline — End-to-End Video Production Orchestrator

Lightweight orchestrator that chains aivp skills into a complete video production workflow. Defines project structure, data flow conventions, and execution order.

**This skill does NOT hardcode a fixed workflow.** It defines conventions so that each skill can interoperate. The agent decides which steps to run based on user intent.

## Quick Start

```
Make a 3-minute YouTube video about "5 Morning Habits of Successful People"
```

The agent will execute:

```
1. aivp-ideation  → validate topic, check competition
2. aivp-script    → generate structured script (JSON)
3. aivp-storyboard → convert script to shot list with prompts
4. aivp-image     → generate keyframes from storyboard prompts
5. aivp-video     → animate keyframes to video clips (I2V)
6. aivp-audio     → generate voiceover (TTS) + background music
7. aivp-edit      → concat clips + mix audio + burn subtitles
8. aivp-review    → technical quality check
9. aivp-publish   → thumbnail + metadata + platform formatting
```

## Project Directory Structure

Every pipeline run creates a project directory:

```
project-name/
├── ideation/
│   └── ideas.json              ← topic validation & scoring
├── script.json                 ← structured script with scenes
├── storyboard.json             ← shot list with AI prompts
├── references/
│   ├── character_main.png      ← character reference sheet
│   └── style_frame.png         ← visual style reference
├── keyframes/
│   ├── shot_01.png             ← generated from storyboard
│   ├── shot_02.png
│   └── ...
├── clips/
│   ├── shot_01.mp4             ← animated from keyframes
│   ├── shot_02.mp4
│   └── ...
├── audio/
│   ├── voiceover.mp3           ← full narration
│   ├── voiceover_scene_01.mp3  ← per-scene (optional)
│   ├── bgm.mp3                 ← background music
│   └── sfx/                    ← sound effects (optional)
├── subtitles/
│   └── transcript.srt          ← from speech-to-text
├── output/
│   ├── final.mp4               ← master output
│   ├── final_shorts.mp4        ← vertical cut (optional)
│   ├── final_tiktok.mp4        ← platform variant (optional)
│   └── thumbnail.jpg           ← generated thumbnail
├── review/
│   └── report.json             ← quality check results
├── publish/
│   └── metadata.json           ← per-platform metadata
└── metadata/
    ├── pipeline.json           ← execution log
    ├── shot_01.json            ← per-shot generation params
    └── ...
```

## Pipeline Modes

### Full Pipeline
Run everything from topic to publish-ready video:
```
Create a complete video about [topic]
```

### Partial Pipeline
Start from any point:

| Start From | When To Use |
|------------|-------------|
| Script → | User already has a topic/outline |
| Storyboard → | User already has a script |
| Image → | User already has a storyboard |
| Video → | User already has keyframes |
| Edit → | User already has clips + audio |
| Review → | User already has final video |

```
I have a script ready at project/script.json, generate the video from there
```

### Single Skill
Run any skill independently:
```
Generate a voiceover for this text: "..."
```

## Data Flow

```
                    ┌─────────────┐
                    │  ideation   │ ← analytics feedback
                    └──────┬──────┘
                           │ topic + validation
                    ┌──────▼──────┐
                    │   script    │
                    └──────┬──────┘
                           │ script.json (scenes + narration)
                    ┌──────▼──────┐
                    │ storyboard  │
                    └──────┬──────┘
                           │ storyboard.json (shots + prompts)
                ┌──────────┼──────────┐
                │          │          │
         ┌──────▼──┐ ┌────▼────┐ ┌───▼─────┐
         │  image   │ │  video  │ │  audio  │
         │(keyframe)│ │(T2V/I2V)│ │(VO+BGM) │
         └──────┬───┘ └────┬────┘ └───┬─────┘
                │          │          │
                └──────────┼──────────┘
                    ┌──────▼──────┐
                    │    edit     │ ← concat + mix + subs
                    └──────┬──────┘
                           │ final.mp4
                    ┌──────▼──────┐
                    │   review    │
                    └──────┬──────┘
                           │ PASS / FAIL
                    ┌──────▼──────┐
                    │   publish   │ → thumbnail + metadata
                    └──────┬──────┘
                           │ analytics
                    ┌──────▼──────┐
                    │  ideation   │ ← feedback loop
                    └─────────────┘
```

## Execution Log

The pipeline tracks what was run in `metadata/pipeline.json`:

```json
{
  "project": "morning-habits",
  "created": "2026-02-11T14:00:00Z",
  "steps": [
    {
      "skill": "aivp-script",
      "status": "completed",
      "started": "2026-02-11T14:00:05Z",
      "completed": "2026-02-11T14:00:12Z",
      "output": "script.json"
    },
    {
      "skill": "aivp-storyboard",
      "status": "completed",
      "started": "2026-02-11T14:00:12Z",
      "completed": "2026-02-11T14:00:18Z",
      "output": "storyboard.json"
    },
    {
      "skill": "aivp-video",
      "status": "completed",
      "started": "2026-02-11T14:00:18Z",
      "completed": "2026-02-11T14:05:30Z",
      "output": "clips/",
      "details": {
        "model": "fal-ai/bytedance/seedance/v1.5/pro",
        "clips_generated": 8,
        "total_duration": "2:45"
      }
    }
  ],
  "total_cost_estimate": "$2.40",
  "total_time": "5:30"
}
```

## Configuration

### Default Models

Override defaults per project by setting environment variables or passing to scripts:

| Component | Default Model | Env Variable |
|-----------|---------------|-------------|
| Video (T2V) | `fal-ai/bytedance/seedance/v1.5/pro` | `AIVP_VIDEO_MODEL` |
| Video (I2V) | `fal-ai/kling-video/v2.6/pro/image-to-video` | `AIVP_I2V_MODEL` |
| Image | `fal-ai/nano-banana-pro` | `AIVP_IMAGE_MODEL` |
| TTS | `fal-ai/minimax/speech-2.6-turbo` | `AIVP_TTS_MODEL` |
| Music | `fal-ai/minimax-music/v2` | `AIVP_MUSIC_MODEL` |
| STT | `fal-ai/whisper` | `AIVP_STT_MODEL` |

### API Keys

```bash
# Required
export FAL_KEY=your_fal_key

# Optional (for specific providers)
export REPLICATE_API_TOKEN=your_token
export PEXELS_API_KEY=your_key
```

## Video Templates

Pre-built production pipelines for common video types. Each template defines the full workflow — script structure, shot types, models, pacing, and publish format — so users just provide a topic and get a finished video.

Templates are stored as JSON files in `templates/` and loaded by the agent at runtime.

### How to Use Templates

Simply reference a template name in your prompt:

```
Use the "YouTube Short" template to make a video about "5 AI tools that replaced my team"
```

```
Make a Product Demo video for my wireless earbuds — noise-canceling, 40h battery, $79
```

```
Talking Head template: explain quantum computing in 2 minutes using this portrait photo
```

The agent will:
1. Load the template JSON from `templates/`
2. Use the pre-configured step sequence, models, and parameters
3. Execute the pipeline with user's topic/content
4. Override any defaults if the user specifies preferences

You can also customize any template parameter:
```
Use "YouTube Short" template but make it 90 seconds, use a professional tone, and skip the CTA
```

---

### Template 1: YouTube Short

**60-second vertical short video** optimized for YouTube Shorts, TikTok, and Instagram Reels.

| Property | Value |
|----------|-------|
| Duration | 60s |
| Aspect Ratio | 9:16 (1080×1920) |
| Input | Topic / idea |
| Cost | $1-3 |
| Time | 10-15 min |

**Pipeline:**
```
script(hook+3点+CTA) → storyboard(5-8镜头,9:16) → image → video(I2V) → audio(TTS+BGM) → edit(concat+subtitles) → publish(shorts)
```

**Script Structure:**
| Part | Time | Purpose |
|------|------|---------|
| Hook | 0-5s | Stop the scroll. Bold claim or question. |
| Point 1 | 5-20s | First key insight with visual proof. |
| Point 2 | 20-35s | Second insight, build momentum. |
| Point 3 | 35-50s | Strongest or most surprising point. |
| CTA | 50-60s | Follow + like + comment prompt. |

**Example Prompts:**
```
Use the "YouTube Short" template to make a video about "5 AI tools that replaced my team"
Use the "YouTube Short" template: "3 morning habits that changed my productivity"
Make a YouTube Short about "Why 90% of startups fail in year one"
```

**Tips:**
- Hook must grab in under 2 seconds — bold text + surprising visual
- Subtitles are mandatory — 85% of Shorts are watched muted
- One idea per point, one visual per idea — no overload
- End with a question to boost comments

---

### Template 2: Product Demo

**30-90 second product showcase** with problem-solution structure. Works for e-commerce, SaaS, and physical products.

| Property | Value |
|----------|-------|
| Duration | 30-90s |
| Aspect Ratio | 16:9 (+ 9:16, 1:1 variants) |
| Input | Product description + images (optional) |
| Cost | $2-5 |
| Time | 15-25 min |

**Pipeline:**
```
script(problem→solution→features→proof→CTA) → storyboard(product shots+usage scenes) → image(enhance product photos) → video(I2V) → audio(VO+BGM+SFX) → edit(concat+subtitles+logo) → publish(multi-platform)
```

**Script Structure:**
| Part | Time | Purpose |
|------|------|---------|
| Problem | 0-8s | Show the pain point. Relatable frustration. |
| Solution Reveal | 8-20s | Introduce product. Hero shot. |
| Features | 20-50s | 3 key features with visual demos. |
| Social Proof | 50-60s | Testimonial, stats, or trust signals. |
| CTA | 60-90s | Clear next step: buy, try, learn more. |

**Example Prompts:**
```
Use the "Product Demo" template for my wireless earbuds: noise-canceling, 40h battery, $79. Here are 3 product photos.
Make a product demo video for our SaaS dashboard — it helps teams track OKRs in real-time.
Product Demo template: showcase this smart water bottle that tracks hydration and syncs with Apple Health.
```

**Tips:**
- Use actual product images as reference — AI-generated product shots look generic
- Lead with the problem, not the product
- Show the product in use, not just sitting on a table
- Max 3 features in 90 seconds

---

### Template 3: Talking Head

**AI avatar/digital human explainer** with lip-synced speech. No camera needed — just a portrait photo and script.

| Property | Value |
|----------|-------|
| Duration | 60-180s |
| Aspect Ratio | 16:9 (+ 9:16 variant) |
| Input | Script text + portrait photo (optional) |
| Cost | $0.50-2 |
| Time | 5-10 min |

**Pipeline:**
```
audio(TTS) → lipsync(portrait+audio→video) → edit(title+subtitles+lower-third) → publish
```

**Script Structure:**
| Part | Time | Purpose |
|------|------|---------|
| Intro | 0-10s | Greet + introduce topic. |
| Body | 10-150s | Main content, 2-4 sections. |
| Summary | 150-170s | Recap key takeaways. |
| CTA | 170-180s | Subscribe / follow / visit. |

**Example Prompts:**
```
Use the "Talking Head" template: script is "AI is changing how we write code. Here are 3 ways..." with this portrait photo.
Make a talking head video explaining our Q4 earnings summary. Use a professional female voice.
Talking Head template: create a 2-minute explainer about blockchain for beginners.
```

**Tips:**
- Use a high-quality, front-facing portrait with good lighting
- Write conversational scripts — read aloud before generating
- Keep under 90s for best retention; 3+ min needs B-roll
- Add lower-third name/title for credibility

---

### Template 4: Tutorial

**3-5 minute horizontal how-to video** with step-by-step instructions and chapter markers.

| Property | Value |
|----------|-------|
| Duration | 3-5 min |
| Aspect Ratio | 16:9 (1920×1080) |
| Input | Topic |
| Cost | $3-8 |
| Time | 20-40 min |

**Pipeline:**
```
script(step-by-step分解) → storyboard(操作示意+结果) → image → video(I2V) → audio(TTS+ambient BGM) → edit(subtitles+chapters+step titles) → publish(YouTube w/ chapters)
```

**Script Structure:**
| Part | Time | Purpose |
|------|------|---------|
| Intro | 0-15s | What you'll learn + why it matters. |
| Prerequisites | 15-30s | What you need before starting. |
| Steps | 30-240s | Numbered steps: do → how → verify. |
| Result | 240-270s | Final outcome. Before/after if applicable. |
| Recap | 270-300s | Summary + common mistakes + CTA. |

**Example Prompts:**
```
Use the "Tutorial" template to make a video about "How to set up a Next.js project from scratch"
Tutorial template: "5 steps to create a professional resume in Canva" for job seekers
Make a tutorial video: "How to brew the perfect pour-over coffee" — beginner level, 3 minutes
```

**Tips:**
- Number every step in narration AND visual overlays
- Show expected result after each step, not just the end
- Add YouTube chapter markers — they boost SEO and retention
- Keep each step under 45 seconds; split long steps into sub-steps

---

### Template 5: Brand Story

**1-3 minute cinematic brand narrative** with emotional storytelling, premium visuals, and scored audio.

| Property | Value |
|----------|-------|
| Duration | 1-3 min |
| Aspect Ratio | 16:9 (+ 9:16 social cut) |
| Input | Brand info + core values/mission |
| Cost | $5-12 |
| Time | 30-50 min |

**Pipeline:**
```
ideation(narrative angle) → script(story arc) → storyboard(cinematic shots) → image(style frames) → video(I2V) → audio(score+VO) → edit(transitions+color grade+logo) → review → publish(multi-format)
```

**Narrative Arc:**
| Part | Time | Purpose |
|------|------|---------|
| Opening | 0-10s | Establish the world. Wide shot + ambient. No narration. |
| Setup | 10-30s | Introduce protagonist (founder/customer). |
| Tension | 30-50s | The problem. What's broken in the world? |
| Turning Point | 50-70s | The insight. Why this brand exists. |
| Building | 70-100s | The journey — building, growing, overcoming. |
| Impact | 100-130s | Lives changed, problems solved. |
| Vision | 130-160s | Where we're going. Aspirational. |
| Close | 160-180s | Brand mark + tagline. Fade to black. |

**Example Prompts:**
```
Use the "Brand Story" template for outdoor brand 'TrailForge' — mission: adventure gear from recycled ocean plastic.
Brand Story template: tell the story of AI startup 'Lumina' — we help blind people navigate cities with audio AR.
Make a brand story for my coffee roastery 'Origin' — direct sourcing from Colombia and Ethiopia, 3x fair trade prices.
```

**Tips:**
- Start with silence or ambient sound — don't rush into narration
- Find the human story behind the brand — people connect with people, not mission statements
- "Show, don't tell" — if narration says "we care," the visual must SHOW it
- Music makes or breaks brand stories — score should follow the narrative arc
- Lock the style frame before generating all keyframes — visual consistency is everything
- Under 2 min for social, up to 3 min for website hero

---

### Template Summary

| Template | Duration | Ratio | Input | Cost | Time |
|----------|----------|-------|-------|------|------|
| YouTube Short | 60s | 9:16 | Topic | $1-3 | 10-15 min |
| Product Demo | 30-90s | 16:9 | Product + photos | $2-5 | 15-25 min |
| Talking Head | 60-180s | 16:9 | Script + portrait | $0.50-2 | 5-10 min |
| Tutorial | 3-5 min | 16:9 | Topic | $3-8 | 20-40 min |
| Brand Story | 1-3 min | 16:9 | Brand info | $5-12 | 30-50 min |

### Creating Custom Templates

Copy any template JSON from `templates/` and modify:

```json
{
  "name": "My Custom Template",
  "description": "...",
  "target_duration": "120s",
  "aspect_ratio": "16:9",
  "steps": [ ... ],
  "default_models": { ... },
  "script_template": { ... }
}
```

Save to `templates/my-custom-template.json` and reference by name:
```
Use the "My Custom Template" template to make a video about ...
```

## Tips

1. **Always generate keyframes first, then animate** — I2V produces more consistent results than T2V for multi-scene videos
2. **Lock visual style early** — generate a style frame and character reference before scene keyframes
3. **Use the same model throughout** — mixing models causes style inconsistency
4. **Review before publish** — automated checks catch technical issues; human review catches creative ones
5. **Save generation params** — seeds, models, and prompts in metadata/ enable reproducibility
6. **Start small** — test with 2-3 scenes before generating a full 10-scene video
