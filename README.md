# AIVidPipeline Skills

A collection of AI agent skills for end-to-end AI video production. From topic ideation to publishing, covering the complete video creation pipeline.

Built for [Claude Code](https://claude.ai), [OpenClaw](https://openclaw.ai), [Codex](https://openai.com), and any agent supporting the [Agent Skills](https://agentskills.io/) format.

## Installation

```bash
# Install all skills
npx skills add yyforever/aividpipeline-skills

# Install specific skill
npx skills add yyforever/aividpipeline-skills --skill seedance-video
```

## Available Skills

### Pre-Production

| Skill | Description |
|-------|-------------|
| [seedance-ideation](skills/seedance-ideation/) | Topic research, competitor analysis, trend tracking, and post-publish analytics feedback loop |
| [seedance-script](skills/seedance-script/) | Video script writing with structured formats for shorts, tutorials, and narratives |
| [seedance-storyboard](skills/seedance-storyboard/) | Shot list design with camera language, composition, and timing |

### Asset Generation

| Skill | Description |
|-------|-------------|
| [seedance-image](skills/seedance-image/) | Keyframe and character reference image generation with consistency techniques |
| [seedance-video](skills/seedance-video/) | Video clip generation via Seedance, Kling, Sora, and other models |
| [seedance-audio](skills/seedance-audio/) | Voiceover (TTS), background music, and sound effects generation |

### Post-Production

| Skill | Description |
|-------|-------------|
| [seedance-edit](skills/seedance-edit/) | Video editing with ffmpeg — cutting, merging, transitions, subtitles |
| [seedance-review](skills/seedance-review/) | Automated quality checks (resolution, audio levels, format) and content safety review |

### Distribution

| Skill | Description |
|-------|-------------|
| [seedance-publish](skills/seedance-publish/) | Metadata/SEO optimization, thumbnail generation, multi-platform repurposing and upload |

### Orchestration

| Skill | Description |
|-------|-------------|
| [seedance-pipeline](skills/seedance-pipeline/) | Workflow orchestration — chain skills together for end-to-end video production |

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
