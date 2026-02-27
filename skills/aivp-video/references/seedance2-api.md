# Seedance 2.0 API Reference

Updated: 2026-02-27. Source: WaveSpeed guide, fal.ai, community docs.

> **fal.ai availability:** As of 2026-02-27, fal.ai still lists Seedance 1.5 Pro. Seedance 2.0 is available via ByteDance official API and third-party proxies (laozhang.ai, WaveSpeed). Check fal.ai for updates.

## Core Capabilities

| Parameter | Specification |
|-----------|--------------|
| Image inputs | Up to 9 images (jpeg/png/webp/bmp/tiff/gif, < 30MB each) |
| Video inputs | Up to 3 videos (mp4/mov, 2-15s total, < 50MB each) |
| Audio inputs | Up to 3 MP3/WAV files (≤ 15s total, < 15MB each) |
| Text input | Natural language, 30-200 words optimal |
| Total file limit | **12 files per generation** |
| Output duration | 4-15 seconds (user-selectable) |
| Output resolution | Up to 2K |
| Native audio | Sound effects, dialogue, music |

## Two Modes

### 1. Omni Reference Mode (`omni_reference`)

Multi-modal mixed input with @ syntax to assign asset roles.

```
@Image1 as the main character appearance.
@Image2 as the kitchen background reference.
@Video1 for the camera movement pattern.
@Audio1 for background music rhythm.

The character slowly turns from the stove, expression shifting from calm to surprise.
Camera follows Video1's tracking shot pattern.
```

### 2. First/Last Frame Mode (`first_last_frames`)

Precise control with start/end frame images.

```
Smooth transition from first frame to last frame.
The woman's hand gently releases the crumpled letter.
Cinematic lighting, shallow depth of field.
```

## @ Reference Syntax

| Use Case | Prompt Pattern |
|----------|---------------|
| Set first frame | `@Image1 as the first frame` |
| Character reference | `@Image1 is the main character` |
| Scene reference | `@Image2 as the background setting` |
| Motion reference | `Reference @Video1 for the fighting choreography` |
| Camera work | `Follow @Video1's camera movements and transitions` |
| Music/rhythm | `Use @Audio1 for the background music` |
| Extend video | `Extend @Video1 by 5 seconds` |
| Replace character | `Replace the woman in @Video1 with @Image1` |

## Seedance 2.0 Prompt Format (Chinese Time-Axis)

This is the format the storyboard skill (aivp-storyboard) produces:

```
【整体描述】
{风格} + {时长}秒 + {画面比例} + {整体氛围/色调}

【分镜描述】
0-Xs：{景别}{运镜}，{画面内容}，{主体动作}，{光影效果}
X-Ys：{景别}{运镜}，{画面内容}，{主体动作}，{光影效果}

【声音说明】
{配乐风格} + {音效} + {对白/旁白}

【参考素材说明】（如有）
@图片1 作为角色形象参考
@图片2 作为场景风格参考

角色面部稳定不变形，动作自然流畅，4K超高清，电影质感，画面稳定
```

## Key Rules (from storyboard seedance2-guide)

1. **Degree adverbs are critical**: "slowly", "gently", "violently" — not just verbs
2. **"镜头切换" (lens switch)** keyword triggers multi-shot within one generation
3. **No negative prompts** — describe what you WANT
4. **Camera keywords**: surround, aerial, zoom, pan, follow, handheld
5. **Unfixed camera**: select in parameters for moving camera
6. **Gentle motion words** for smooth results: slow, gentle, continuous, natural, smooth
7. **Quality suffix**: always append "4K, 超高清, 细节丰富, 电影质感, 画面稳定"
8. **Character constraint**: append "角色面部稳定不变形，动作自然流畅" when people present

## API (via fal.ai — Seedance 1.5 currently)

### Seedance 1.5 Pro Endpoints (fal.ai)

| Mode | Endpoint |
|------|----------|
| T2V | `fal-ai/bytedance/seedance/v1.5/pro/text-to-video` |
| I2V | `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` |
| T2V (v1) | `fal-ai/bytedance/seedance/v1/pro` |

### Seedance 1.5 Pro Parameters

| Parameter | Type | Default | Values |
|-----------|------|---------|--------|
| `prompt` | string | — | Scene + dialogue + camera + sound |
| `aspect_ratio` | string | `"16:9"` | `21:9`, `16:9`, `4:3`, `1:1`, `3:4`, `9:16` |
| `resolution` | string | `"720p"` | `480p`, `720p`, `1080p` (T2V only) |
| `duration` | string | `"5"` | `4`-`12` seconds |
| `generate_audio` | boolean | `true` | Native audio (halve cost when false) |
| `camera_fixed` | boolean | `false` | Tripod mode |
| `seed` | integer | random | Reproducibility |

### Seedance 1.5 Pro Pricing (fal.ai)

| Resolution | With Audio | Without Audio |
|:----------:|:----------:|:-------------:|
| 480p | ~$0.024/s | ~$0.012/s |
| 720p | ~$0.052/s | ~$0.026/s |
| 1080p | ~$0.115/s | ~$0.058/s |

> Seedance 1.5 is the most cost-effective model with native audio.

### Seedance 2.0 API (when available on fal.ai)

Expected additional parameters:
- `mode`: `"omni_reference"` or `"first_last_frames"`
- `references`: array of file objects with @ identifiers
- `end_image_url`: for first/last frame mode
- Resolution up to 2K

## Comparison: 1.5 vs 2.0

| Feature | Seedance 1.5 Pro | Seedance 2.0 |
|---------|:----------------:|:------------:|
| Max inputs | 1 image (I2V) | 12 files (9 img + 3 vid + 3 audio) |
| Reference system | None | @ syntax multi-modal |
| Max duration | 12s | 15s |
| Max resolution | 1080p | 2K |
| Camera from video ref | ❌ | ✅ |
| Character from image ref | ❌ | ✅ (via @ reference) |
| Audio from audio ref | ❌ | ✅ |
| First + Last frame | I2V only (first) | Both (first_last_frames mode) |
| Availability (fal.ai) | ✅ Now | ⏳ Pending |

## When Seedance 2.0 Lands on fal.ai

The generate.sh script needs these additions:
1. `--mode omni_reference|first_last_frames` parameter
2. `--reference` accepting multiple files with @ labels
3. `--end-image` for last frame
4. Multi-file upload via upload.sh before generation
