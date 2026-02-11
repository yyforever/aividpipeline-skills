# AIVidPipeline Skills

A collection of AI agent skills for end-to-end AI video production. From topic ideation to publishing, covering the complete video creation pipeline.

Built for [Claude Code](https://claude.ai), [OpenClaw](https://openclaw.ai), [Codex](https://openai.com), and any agent supporting the [Agent Skills](https://agentskills.io/) format.

## Installation

```bash
# Install all skills
npx skills add yyforever/aividpipeline-skills

# Install specific skill
npx skills add yyforever/aividpipeline-skills --skill aivp-video
```

## Available Skills

### Pre-Production

| Skill | Description |
|-------|-------------|
| [aivp-ideation](skills/aivp-ideation/) | Topic research, competitor analysis, trend tracking, and post-publish analytics feedback loop |
| [aivp-script](skills/aivp-script/) | Video script writing with structured formats for shorts, tutorials, and narratives |
| [aivp-storyboard](skills/aivp-storyboard/) | Shot list design with camera language, composition, and timing |

### Asset Generation

| Skill | Description |
|-------|-------------|
| [aivp-image](skills/aivp-image/) | Keyframe and character reference image generation with consistency techniques |
| [aivp-video](skills/aivp-video/) | Video clip generation via Seedance, Kling, Sora, and other models |
| [aivp-audio](skills/aivp-audio/) | Voiceover (TTS), background music, and sound effects generation |

### Post-Production

| Skill | Description |
|-------|-------------|
| [aivp-edit](skills/aivp-edit/) | Video editing with ffmpeg — cutting, merging, transitions, subtitles |
| [aivp-review](skills/aivp-review/) | Automated quality checks (resolution, audio levels, format) and content safety review |

### Distribution

| Skill | Description |
|-------|-------------|
| [aivp-publish](skills/aivp-publish/) | Metadata/SEO optimization, thumbnail generation, multi-platform repurposing and upload |

### Orchestration

| Skill | Description |
|-------|-------------|
| [aivp-pipeline](skills/aivp-pipeline/) | Workflow orchestration — chain skills together for end-to-end video production |

## Pipeline Overview

```
ideation → script → storyboard → image → video → audio
                                                    ↓
                                    edit ←──────────┘
                                      ↓
                              review → publish → ideation (feedback loop)
```

## License

MIT
