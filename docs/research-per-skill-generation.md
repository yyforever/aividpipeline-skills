# AIVP 素材生成阶段竞品深度调研报告

> 调研日期: 2026-02-21
> 调研范围: aivp-image / aivp-video / aivp-audio 三个 skill 与 OpenClaw 社区 + skills.sh 上的竞品对比

---

## 目录

1. [aivp-image 图像生成对比](#1-aivp-image-图像生成对比)
2. [aivp-video 视频生成对比](#2-aivp-video-视频生成对比)
3. [aivp-audio 音频生成对比](#3-aivp-audio-音频生成对比)
4. [缺失能力分析与新增 Skill 建议](#4-缺失能力分析与新增-skill-建议)
5. [总结与优先级建议](#5-总结与优先级建议)

---

## 1. aivp-image 图像生成对比

### 1.1 竞品概览

| 竞品 | 作者 | 定位 | 实现方式 |
|------|------|------|----------|
| **delorenj/fal-text-to-image** | delorenj | 专业图像生成/编辑全流程 | Python (uv) + fal SDK |
| **hexiaochun/seedream-image** | hexiaochun | Seedream 4.5 专项 | MCP submit_task |
| **hexiaochun/flux2-flash** | hexiaochun | Flux 2 Flash 快速生图 | MCP submit_task |
| **hexiaochun/nano-hub** | hexiaochun | 提示词模板中心 | MCP + 子代理 |
| **apekshik/fal** | apekshik | 通用 fal.ai 接口 | Bash (curl/jq) |
| **inference-sh/ai-image-generation** | inference-sh | 50+ 模型平台 | infsh CLI |

### 1.2 功能覆盖对比表

| 功能 | aivp-image | fal-text-to-image | seedream | flux2-flash | nano-hub | apekshik/fal | inference-sh |
|------|:----------:|:-----------------:|:--------:|:-----------:|:--------:|:------------:|:------------:|
| 文生图 (T2I) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 图生图 (I2I) / 风格迁移 | ✅ (edit.sh) | ✅ (fal-image-remix) | ✅ | ✅ | ✅ | ✅ | ❌ |
| 图像编辑 / Inpainting | ✅ (edit.sh) | ✅ (fal-image-edit) | ✅ | ✅ | ❌ | ❌ | ❌ |
| Mask 编辑（手动/文本） | ❌ | ✅ (--mask-prompt) | ❌ | ❌ | ❌ | ❌ | ❌ |
| 多图输入/引用 | ❌ | ❌ | ✅ (Figure 1/2) | ✅ (1-4张) | ❌ | ❌ | ❌ |
| 模型自动选择 | ❌ | ✅ (智能路由) | ❌ | ❌ | ❌ | ❌ | ❌ |
| 提示词模板系统 | ❌ | ❌ | ❌ | ❌ | ✅ (9种模板) | ❌ | ❌ |
| 队列模式 | ✅ | ❌ (SDK处理) | ✅ | ✅ | ✅ | ✅ | ✅ |
| 本地文件上传 | ✅ (upload.sh) | ✅ (内置) | ❌ | ❌ | ✅ (catbox) | ✅ (upload) | ❌ |
| 图像放大 | ✅ (文档推荐) | ❌ (文档提及) | ❌ | ❌ | ❌ | ❌ | ✅ (Topaz) |
| 背景移除 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 输出格式控制 | ❌ | ✅ (png/jpeg/webp) | ✅ (jpeg/png/webp) | ✅ (jpeg/png/webp) | ❌ | ❌ | ❌ |
| Seed 控制 | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| guidance_scale | ❌ | ✅ | ❌ | ✅ | ❌ | ✅ | ❌ |
| 推理步数控制 | ❌ | ✅ (--steps) | ❌ | ❌ | ❌ | ✅ | ❌ |
| 多模型覆盖 | ✅ (5 T2I) | ✅ (10+ 模型) | ❌ (1模型) | ❌ (1模型) | ❌ (1模型) | ✅ (50+ 模型) | ✅ (50+ 模型) |
| 4K 输出 | ❌ | ✅ (2048x2048) | ✅ (auto_4K) | ❌ | ✅ (4K) | ❌ | ✅ (Seedream) |
| LoRA / ControlNet | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ |
| 文字排版专项 | ✅ (Ideogram) | ✅ (Recraft/Ideogram) | ❌ | ✅ | ❌ | ❌ | ✅ (Reve) |
| 商用安全模型 | ❌ | ✅ (Bria) | ❌ | ❌ | ❌ | ❌ | ❌ |
| 批量生成 | ✅ (num_images) | ✅ | ✅ (1-6) | ✅ (1-4) | ❌ | ✅ | ❌ |
| 费用文档 | ❌ | ✅ (详细) | ❌ | ✅ (2积分/次) | ❌ | ❌ | ❌ |

### 1.3 竞品做得好的地方

#### delorenj/fal-text-to-image — 最全面的图像 Skill

这是调研中功能最完善的图像 skill。它的核心优势：

**1) 三合一工具设计**

> "Three Modes of Operation: 1. Text-to-Image (fal-text-to-image) — Generate images from scratch; 2. Image Remix (fal-image-remix) — Transform existing images while preserving composition; 3. Image Edit (fal-image-edit) — Targeted inpainting and masked editing"

将生图、remix、编辑分为三个独立工具（fal-text-to-image / fal-image-remix / fal-image-edit），职责清晰。

**2) 智能模型选择逻辑**

> "The script automatically selects the best model when -m is not specified: 1. If -i provided: Uses flux-2/lora/edit for style transfer; 2. If prompt contains typography keywords: Uses recraft/v3; 3. If prompt suggests high-res needs: Uses flux-pro/v1.1-ultra; 5. Default: Uses flux-2"

根据 prompt 内容和输入参数自动路由到最佳模型，用户无需了解模型差异。

**3) 精细控制参数**

支持 `--strength` (变换强度 0.0-1.0)、`--guidance` (引导系数)、`--steps` (推理步数)，并有详细的参数指南表格。

**4) Mask 编辑功能**

> "Auto-generate mask from text: uv run python fal-image-edit input.jpg --mask-prompt 'sky' 'Make it sunset'"

支持 `--mask-prompt` 从文本自动生成编辑 Mask，这是我们完全缺失的能力。

**5) 丰富的参考文档**

包含独立的 `model-comparison.md`（含基准评测、速度/质量排名、费用对比）和 `usage-examples.md`（20+ 个实际场景示例）。

#### hexiaochun/seedream-image — 多图引用语法

> "提示词中可以用 Figure 1、Figure 2 等引用 image_urls 中的图片: '将 Figure 1 中的人物放到 Figure 2 的场景中'"

支持多图输入和 Figure 引用语法，适合合成/组合编辑场景。

#### hexiaochun/nano-hub — 模板驱动的工作流

> "Nano Banana Pro 提示词模板中心，支持文生图和图像编辑"

提供 9 种预设模板（手绘信息图、角色三视图、电商详情页、浮世绘闪卡等），每种模板有独立的 Markdown 文件详细描述提示词规范。通过 AskQuestion 交互让用户选择类型，再用子代理生成高质量提示词。

**这种"模板中心"思路非常适合 AIVP 的 storyboard→keyframe 工作流**，可以为不同镜头类型（特写、全景、角色表情等）预设模板。

#### hexiaochun/flux2-flash — 参数文档化

> "guidance_scale: number, 否, 2.5, 引导强度（0-20），控制遵循提示词程度"
> "enable_prompt_expansion: boolean, 否, false, 启用提示词扩展以获得更好的结果"

明确文档化了 `guidance_scale`、`enable_prompt_expansion` 等高级参数，且提供了 `output_format` (jpeg/png/webp) 控制。

#### inference-sh/ai-image-generation — 平台级覆盖

覆盖 50+ 模型，包括 Gemini 3 Pro、Grok Imagine、Reve（文字渲染专项）、ImagineArt 1.5 Pro（4K）等我们未覆盖的模型。还包含 `stitch-images`（图片拼接）和 `topaz-image-upscaler`（专业放大）等实用工具。

### 1.4 AIVP-Image 脚本质量评估

#### generate.sh

**优点**：
- 完整的队列模式实现（submit → poll → result）
- 支持 sync / async / queue 三种模式
- 本地文件上传集成（CDN token → upload → get URL）
- 错误处理覆盖了 FAL_KEY 缺失、文件不存在、request_id 空、超时等场景

**问题**：
1. **JSON 构建不安全** — 使用字符串拼接构建 JSON payload：
   ```bash
   PAYLOAD="{\"prompt\": \"$PROMPT\", \"image_size\": \"$IMAGE_SIZE\", \"num_images\": $NUM_IMAGES"
   ```
   如果 prompt 包含引号、反斜杠或换行符，JSON 会损坏。应使用 `jq` 构建。

2. **JSON 解析脆弱** — 用 `grep -o` + `cut` 解析 JSON 响应：
   ```bash
   REQUEST_ID=$(echo "$SUBMIT" | grep -oE '"request_id"[[:space:]]*:[[:space:]]*"[^"]*"' | ...)
   ```
   建议使用 `jq` 替代。

3. **缺少 guidance_scale / steps / output_format 参数** — 对比竞品，缺少精细控制。

4. **SKILL.md 中提到 edit.sh 但文件系统中不存在** — scripts/ 目录下只有 generate.sh，没有 edit.sh 和 upload.sh。

5. **缺少 prompt expansion 能力** — Flux 2 Flash 支持 `enable_prompt_expansion`，可以显著提升生图质量。

6. **错误信息不够结构化** — 竞品 fal-text-to-image 会解析 API 返回的错误消息并友好展示。

### 1.5 具体改进建议

#### 建议 1: 使用 jq 构建和解析 JSON

```bash
# 构建 payload（安全处理特殊字符）
PAYLOAD=$(jq -n \
  --arg prompt "$PROMPT" \
  --arg image_size "$IMAGE_SIZE" \
  --argjson num_images "$NUM_IMAGES" \
  '{prompt: $prompt, image_size: $image_size, num_images: $num_images}')

# 可选字段
[ -n "$IMAGE_URL" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg url "$IMAGE_URL" '. + {image_url: $url}')
[ -n "$SEED" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --argjson seed "$SEED" '. + {seed: $seed}')

# 解析响应
REQUEST_ID=$(echo "$SUBMIT" | jq -r '.request_id')
STATUS=$(echo "$SR" | jq -r '.status')
```

#### 建议 2: 补全 edit.sh 和 upload.sh

SKILL.md 文档中声明了 3 个脚本但实际只有 1 个。需要：
- `edit.sh` — 支持 I2I、style transfer、inpainting（参考 fal-text-to-image 的三种编辑模式）
- `upload.sh` — 独立上传脚本（可复用 aivp-video 的 upload.sh）

#### 建议 3: 增加 output_format 和高级参数

```bash
# 新增参数
--output-format     # jpeg, png, webp（默认 png）
--guidance-scale    # 引导系数（默认模型默认值）
--steps             # 推理步数
--prompt-expansion  # 启用提示词扩展
```

#### 建议 4: 添加模型自动选择逻辑

参考 fal-text-to-image 的实现，在 SKILL.md 中为 agent 添加选择指导：

```markdown
## 模型选择指南（Agent 决策树）

1. 如果提供了参考图 → 使用 I2I 模型（flux/dev/image-to-image）
2. 如果 prompt 包含文字内容需求（logo、海报、标题）→ 使用 ideogram/v3
3. 如果需要 4K 输出 → 使用 seedream 4.5
4. 如果需要快速预览 → 使用 flux/schnell（<1秒）
5. 默认 → nano-banana-pro
```

#### 建议 5: 引入 "角色一致性" 专项工作流

借鉴 nano-hub 的角色三视图模板和 Seedance R2V 的参考图机制，在 SKILL.md 中增加：

```markdown
## 角色一致性工作流

### 步骤 1: 生成角色参考表
bash scripts/generate.sh \
  --prompt "Character sheet, [角色描述], multiple views, white background" \
  --model "fal-ai/nano-banana-pro" \
  --size square --num-images 4 --seed 42

### 步骤 2: 使用参考表生成场景
bash scripts/edit.sh \
  --image-url "[角色参考表URL]" \
  --prompt "[场景描述], same character from reference" \
  --model "fal-ai/flux-kontext"
```

---

## 2. aivp-video 视频生成对比

### 2.1 竞品概览

| 竞品 | 作者 | 定位 | 实现方式 |
|------|------|------|----------|
| **hexiaochun/seedance-video** | hexiaochun | Seedance 全系列（最全面） | MCP submit_task |
| **hexiaochun/sora-2** | hexiaochun | OpenAI Sora 2 | MCP submit_task |
| **hexiaochun/hailuo-video** | hexiaochun | MiniMax Hailuo 2.3 | MCP submit_task |
| **hexiaochun/wan-video** | hexiaochun | Wan 2.6（多镜头） | MCP submit_task |
| **hexiaochun/omnihuman-video** | hexiaochun | 口型同步（音频驱动） | MCP submit_task |
| **hexiaochun/dreamactor-video** | hexiaochun | 动作迁移 | MCP submit_task |
| **inference-sh/ai-video-generation** | inference-sh | 40+ 模型平台 | infsh CLI |

### 2.2 功能覆盖对比表

| 功能 | aivp-video | seedance | sora-2 | hailuo | wan | omnihuman | dreamactor | inference-sh |
|------|:----------:|:--------:|:------:|:------:|:---:|:---------:|:----------:|:------------:|
| 文生视频 (T2V) | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| 图生视频 (I2V) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| 视频转视频 (V2V) | ✅ (文档) | ❌ | ✅ (remix) | ❌ | ❌ | ❌ | ✅ | ❌ |
| 参考图生视频 (R2V) | ❌ | ✅ (Lite R2V) | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| 首尾帧控制 | ❌ | ✅ (end_image_url) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 原生音频生成 | ❌ | ✅ (对话+音效+BGM) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 唇形同步 | ❌ | ✅ (v1.5 Pro) | ✅ | ❌ | ❌ | ✅ (核心) | ✅ | ✅ |
| 音频驱动视频 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| 动作迁移 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| 多镜头分割 | ❌ | ❌ | ❌ | ❌ | ✅ (multi_shots) | ❌ | ❌ | ❌ |
| 摄像机固定 | ❌ | ✅ (camera_fixed) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 负面提示词 | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| 提示词扩展 | ❌ | ❌ | ❌ | ✅ (prompt_optimizer) | ✅ | ❌ | ❌ | ❌ |
| 分辨率选择 | ❌ | ✅ (480p/720p/1080p) | ✅ (720p/1080p) | ✅ (768p/1080p) | ✅ (720p/1080p) | ✅ (720p/1080p) | ❌ | ❌ |
| 时长控制 | ✅ (duration) | ✅ (2-12s) | ✅ (4/8/12s) | ✅ (6/10s) | ✅ (5/10/15s) | ❌ (由音频决定) | ❌ (由视频决定) | ✅ |
| 背景音频输入 | ❌ | ❌ | ❌ | ❌ | ✅ (audio_url) | ✅ | ❌ | ❌ |
| 队列模式 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 本地文件上传 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Schema 查询 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 模型搜索 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 详细计费文档 | ❌ | ✅ (按秒计费表) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| 过渡裁剪 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (trim_first_second) | ❌ |
| 安全检查开关 | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Foley (后期配音) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 视频放大 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (Topaz) |
| 视频合并 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (media-merger) |

### 2.3 竞品做得好的地方

#### hexiaochun/seedance-video — 最全面的视频 Skill

**1) 5 个子模型完整覆盖**

> 包含 `v1.5/pro/text-to-video`、`v1.5/pro/image-to-video`、`v1/pro/fast/image-to-video`、`v1/lite/image-to-video`、`v1/lite/reference-to-video` 五个端点

每个子模型都有独立的参数表、调用示例、最佳场景推荐。

**2) 原生音频生成文档极为详细**

> "Seedance 1.5 Pro 文生视频可以生成带音频的视频，包括对话、音效和背景音乐。支持唇形同步"

提示词技巧中专门分列了场景、动作、对话、镜头、音效五个维度：

> "对话用引号包裹并描述情绪：'I can't believe it,' voice breaking with emotion"
> "描述环境音效：room reverb, crowd murmur, wind through trees"

**3) 详细的计费文档**

提供按分辨率（480p/720p/1080p）× 音频（有/无）的详细计费矩阵，帮助用户做成本决策。例如 720p 带音频 5 秒 = 105 积分 vs 不带音频 = 55 积分。

**4) 首尾帧控制**

> "`end_image_url`: 尾帧图片 URL，模型会生成两帧之间的运动"

这对 AIVP 的镜头衔接工作流非常有价值——可以用前一镜头的最后帧作为下一镜头的首帧。

**5) 模型选择矩阵**

> 按"场景"维度给出推荐：纯文字创作带音频 → v1.5 Pro T2V；说话角色 → v1.5 Pro T2V/I2V；快速原型测试 → Pro Fast I2V 480p

#### hexiaochun/wan-video — 多镜头与参考视频

**1) 多镜头分割**

> "Shot 1 [0-4s] 镜头从远景推进到人物面前\nShot 2 [4-8s] 切换到侧面特写..."
> "需要同时启用 enable_prompt_expansion: true 和 multi_shots: true"

这是唯一支持在单次生成中实现多镜头分割的模型文档，非常适合 AIVP 的分镜→视频工作流。

**2) 参考视频生视频 (R2V)**

> "使用 @Video1/@Video2/@Video3 引用主体（最大 800 字符）"
> "参考视频 URL 列表（1-3 个，帧率需 ≥16 FPS）"

通过参考视频保持角色一致性，是 Seedance Lite R2V 用图片的进阶版。

**3) 背景音频输入**

> "`audio_url`: 背景音乐 URL（WAV/MP3，3-30秒）"

支持直接在视频生成时注入背景音乐。

**4) 负面提示词**

> "`negative_prompt`: 负面提示词（最大 500 字符）"
> 示例: "low resolution, error, worst quality, low quality, defects"

#### hexiaochun/sora-2 — 视频重混

> "video-to-video/remix: 对 Sora 生成的视频进行风格转换"
> "delete_video 参数：默认为 true，生成后视频会被删除以保护隐私。如需保留视频用于后续重混，需设为 false"

视频重混（Video Remix）是独特能力，可以对已生成的视频进行风格转换。

#### hexiaochun/omnihuman-video — 音频驱动口型同步

> "输入一张人物图片和一段音频，即可生成口型同步、表情生动的高质量视频"
> "角色的情感和动作与音频高度关联"
> "1080p 最大音频时长 30 秒；720p 最大 60 秒"

这是 **AIVP 完全缺失的核心能力**。在视频制作中，让角色说话并口型同步是刚需。

#### hexiaochun/dreamactor-video — 动作迁移

> "输入一张参考图片和一个驱动视频，将视频中的动作、表情和口型迁移到图片中的角色上"
> "支持真人、动画、宠物等多种角色类型"
> "最大驱动视频时长 30 秒"

动作迁移也是 AIVP 缺失的重要能力，适合：舞蹈视频、表情包制作、角色动画等。

#### inference-sh/ai-video-generation — 视频后处理工具链

> 包含 `infsh/hunyuanvideo-foley`（后期配音）、`falai/topaz-video-upscaler`（视频放大）、`infsh/media-merger`（视频合并+转场）

这些后期处理工具是 AIVP 的 `aivp-edit` 阶段可能需要的。

### 2.4 AIVP-Video 脚本质量评估

#### generate.sh

**优点**：
- **最完善的脚本** — 所有四个脚本（generate.sh, upload.sh, search-models.sh, get-schema.sh）都存在且功能完整
- 队列系统实现完整（submit → poll with logs → result + download）
- 良好的错误处理：API 错误、超时、文件缺失都有处理
- 支持 `--logs` 实时显示生成日志
- `build_payload()` 函数根据模型类型动态构建参数（如 I2V 模型自动要求 image_url）
- 本地文件上传有完整的 CDN token 流程

**问题**：
1. **JSON 构建不安全** — 同样使用字符串拼接（PAYLOAD_PARTS 数组 + IFS 拼接），prompt 中的特殊字符会导致 JSON 损坏。

2. **缺少 resolution 参数** — 竞品都支持 480p/720p/1080p 选择，我们只有 aspect_ratio 没有 resolution。

3. **缺少原生音频支持** — Seedance v1.5 的 `generate_audio`、`camera_fixed` 参数在我们的脚本中没有支持。

4. **缺少首尾帧控制** — 没有 `--end-image-url` 参数。

5. **缺少负面提示词** — 没有 `--negative-prompt` 参数。

6. **缺少 prompt expansion** — 没有 `--prompt-expansion` 参数。

7. **模型特定参数路由不完整** — `build_payload()` 只处理了 seedance 和 kling 的 aspect_ratio，但实际上不同模型有不同的参数结构（如 Wan 的 multi_shots、Hailuo 的 prompt_optimizer）。

#### upload.sh

质量良好，完整的文件上传流程，支持多种文件类型，有错误处理。

#### search-models.sh / get-schema.sh

**优势功能** — 这两个工具是竞品中独有的，让 agent 可以动态发现和理解新模型。`get-schema.sh --input` 可以只输出输入 schema，非常实用。

### 2.5 具体改进建议

#### 建议 1: 使用 jq 构建 JSON payload

```bash
build_payload() {
    local PAYLOAD=$(jq -n --arg prompt "$PROMPT" '{prompt: $prompt}')
    
    # 条件添加字段
    if [[ "$MODEL" == *"image-to-video"* ]]; then
        [ -z "$IMAGE_URL" ] && { echo "Error: --image-url required for I2V" >&2; exit 1; }
        PAYLOAD=$(echo "$PAYLOAD" | jq --arg url "$IMAGE_URL" '. + {image_url: $url}')
    fi
    
    [ -n "$DURATION" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --argjson d "$DURATION" '. + {duration: $d}')
    [ -n "$SEED" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --argjson s "$SEED" '. + {seed: $s}')
    [ -n "$ASPECT_RATIO" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg ar "$ASPECT_RATIO" '. + {aspect_ratio: $ar}')
    [ -n "$RESOLUTION" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg r "$RESOLUTION" '. + {resolution: $r}')
    [ -n "$NEGATIVE_PROMPT" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg np "$NEGATIVE_PROMPT" '. + {negative_prompt: $np}')
    [ "$GENERATE_AUDIO" = "true" ] && PAYLOAD=$(echo "$PAYLOAD" | jq '. + {generate_audio: true}')
    [ "$CAMERA_FIXED" = "true" ] && PAYLOAD=$(echo "$PAYLOAD" | jq '. + {camera_fixed: true}')
    [ -n "$END_IMAGE_URL" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg e "$END_IMAGE_URL" '. + {end_image_url: $e}')
    
    echo "$PAYLOAD"
}
```

#### 建议 2: 新增关键参数

```bash
# SKILL.md 新增参数文档
| `--resolution` | 480p, 720p, 1080p | model default |
| `--end-image-url` | End frame for I2V | - |
| `--negative-prompt` | What to avoid | - |
| `--generate-audio` | Enable native audio | false |
| `--camera-fixed` | Lock camera position | false |
| `--prompt-expansion` | AI-enhance prompt | false |
| `--multi-shots` | Multi-shot mode (Wan) | false |
```

#### 建议 3: SKILL.md 增加 "音频生成" 工作流

```markdown
### 带音频的视频生成

Seedance v1.5 Pro 支持原生音频（对话 + 音效 + BGM）：

\`\`\`bash
# 带对话的视频
bash scripts/generate.sh \
  --prompt 'A woman says "Welcome to our show" with warm smile, studio background' \
  --model "fal-ai/bytedance/seedance/v1.5/pro" \
  --resolution 720p \
  --generate-audio
\`\`\`

**提示词技巧**：
- 对话用英文引号包裹: `"Hello, welcome!"`
- 描述情绪: `voice breaking with emotion`
- 描述环境音: `rain on metal, distant traffic`
```

#### 建议 4: 增加镜头衔接工作流文档

```markdown
### 镜头衔接（首尾帧控制）

利用首尾帧控制实现镜头间平滑过渡：

\`\`\`bash
# 镜头 1: 角色走向摄像头
bash scripts/generate.sh \
  --prompt "Character walks toward camera" \
  --model "fal-ai/bytedance/seedance/v1/lite/image-to-video" \
  --file "./keyframes/scene_01.png" \
  --end-image-url "https://...scene_01_end.png" \
  --duration 5
  
# 镜头 2: 使用镜头 1 的最后帧作为首帧
bash scripts/generate.sh \
  --prompt "Character turns and looks at the city" \
  --model "fal-ai/bytedance/seedance/v1/lite/image-to-video" \
  --image-url "[镜头1最后帧URL]" \
  --duration 5
\`\`\`
```

---

## 3. aivp-audio 音频生成对比

### 3.1 竞品概览

| 竞品 | 作者 | 定位 | 实现方式 |
|------|------|------|----------|
| **odrobnik/elevenlabs** | odrobnik | ElevenLabs 全功能 | Python 脚本 |
| **hexiaochun/minimax-audio** | hexiaochun | MiniMax 语音合成+克隆 | MCP 工具 |
| **hexiaochun/sutui-minimax-tts** | hexiaochun | 多人对话语音合成 | MCP + 脚本 |

### 3.2 功能覆盖对比表

| 功能 | aivp-audio | elevenlabs | minimax-audio | sutui-minimax-tts |
|------|:----------:|:----------:|:-------------:|:-----------------:|
| 文本转语音 (TTS) | ✅ | ✅ | ✅ | ✅ |
| 文本转音乐 | ✅ | ✅ | ❌ | ❌ |
| 语音转文字 (STT) | ✅ | ❌ | ❌ | ❌ |
| 音效生成 | ❌ | ✅ (sfx.py) | ❌ | ❌ |
| 声音克隆 | ❌ | ✅ (voiceclone.py) | ✅ | ❌ |
| 多人对话合成 | ❌ | ✅ (dialogs.py) | ❌ | ✅ (核心功能) |
| 语音设计（文字描述创建音色） | ❌ | ❌ | ✅ | ❌ |
| Voice 列表/管理 | ❌ | ✅ (voices.py) | ✅ (list_voices) | ✅ |
| 用量/配额查询 | ❌ | ✅ (quota.py) | ❌ | ❌ |
| Audio Tags（情感标签） | ❌ | ✅ ([laughs], [sighs]等) | ✅ (breath, laughs等) | ✅ (emotion-tags.md) |
| 输出格式控制 | ❌ | ✅ (16种格式) | ❌ | ❌ |
| 语速控制 | ❌ | ❌ | ✅ (speed 0.5-2) | ❌ |
| 音调控制 | ❌ | ❌ | ✅ (pitch -12~12) | ❌ |
| 音量控制 | ❌ | ❌ | ✅ (vol 0-10) | ❌ |
| Voice 设置（stability/similarity） | ❌ | ✅ | ❌ | ❌ |
| Speaker Boost | ❌ | ✅ | ❌ | ❌ |
| 多语言支持 | ✅ (文档提及) | ✅ (multilingual_v2) | ✅ (language_boost) | ✅ |
| 语言增强 | ❌ | ❌ | ✅ (language_boost) | ✅ |
| 音频合并 | ❌ | ❌ | ❌ | ✅ (merge_audio.py) |
| HTML 可视化输出 | ❌ | ❌ | ❌ | ✅ (dialogue-template.html) |
| 角色音色匹配系统 | ❌ | ❌ | ❌ | ✅ (303个音色映射) |
| 循环音频 | ❌ | ✅ (--loop) | ❌ | ❌ |
| 安全路径保护 | ❌ | ✅ (_pathguard.py) | ❌ | ❌ |
| 队列模式 | ✅ (text-to-music) | ❌ (同步API) | ❌ | ❌ |
| 本地文件保存 | ✅ (--output) | ✅ (-o) | ❌ | ✅ |

### 3.3 竞品做得好的地方

#### odrobnik/elevenlabs — 最完善的音频 Skill

**1) 六个独立工具覆盖全场景**

> 包含 `speech.py`（TTS）、`sfx.py`（音效）、`music.py`（音乐）、`voices.py`（音色管理）、`voiceclone.py`（声音克隆）、`quota.py`（用量查询）、`dialogs.py`（多人对话）

每个工具都是独立的 Python 脚本，可以单独调用，也可以作为模块导入。

**2) Audio Tags 情感表达系统**

> "v3 Audio Tags: [laughs], [chuckles], [sighs], [clears throat], [whispers], [shouts], [excited], [sad], [angry], [warmly], [deadpan], [sarcastic], [grumpy voice], [philosophical], [whiny voice], [resigned], [laughs hard], [sighs deeply], [pause]"

ElevenLabs v3 支持方括号标签注入情感，这在视频配音中非常有用。

**3) 声音克隆的安全设计**

> "Security: by default this script will only read files from: ~/.openclaw/elevenlabs/voiceclone-samples/"
> 使用 `_pathguard.py` 限制文件读取路径，防止路径遍历攻击

这种安全意识值得学习。

**4) 多人对话生成**

> `dialogs.py` 支持输入 JSON 格式的对话列表，自动生成带时间戳的多人对话音频
> 支持 `--split-speakers` 按说话人分割音频

**5) 16 种输出格式**

> 从 `mp3_44100_128`（默认）到 `opus_48000_192`（最佳 AirPlay）到 `pcm_16000`（低延迟），覆盖所有使用场景。

**6) Voice 设置精细控制**

> `--stability`（稳定性）、`--similarity`（相似度）、`--style`（风格）、`--speaker-boost`（扬声器增强）

**7) 音效生成（sfx.py）**

> "Generate sound effects and short audio clips"
> 支持 `--duration`（0.5-30s）、`--loop`（循环音效）、`--prompt-influence`（提示词影响力）

这是 AIVP 完全缺失的能力。视频制作中音效是必备的。

**8) 音乐生成支持 composition plan**

> `music.py` 支持 `--prompt`（文字描述）和 `--composition-plan`（JSON 结构化音乐计划），以及 `--allow-vocals`（允许人声）

#### hexiaochun/minimax-audio — 语音设计与克隆

**1) 语音设计（Voice Design）**

> "用自然语言描述创建自定义音色，无需上传音频样本"
> 示例: `"年轻女性，声音甜美温柔，语速适中，适合讲故事和温馨内容"`

这个能力非常独特——不需要音频样本，用文字描述就能创建新音色。

**2) 语速、音调、音量三维控制**

> `speed: 0.5-2`（语速）、`pitch: -12~12`（音调）、`vol: 0-10`（音量）

比 ElevenLabs 的 stability/similarity 更直观。

**3) 语言增强**

> `language_boost`: Chinese/English/Japanese/Korean/auto

针对特定语言优化发音。

#### hexiaochun/sutui-minimax-tts — 多人对话工作流

**1) 完整的多人对话制作流水线**

> 分析需求 → 生成剧本 → 智能匹配音色 → 文本预处理（添加语气词）→ 分段合成 → 合并长音频 → HTML 展示

这是一个完整的端到端工作流，从需求到成品。

**2) 303 个系统音色的详细分类映射**

> `voice-mapping.md` 按年龄（儿童/青年/中年/老年）× 性格（活泼/稳重/霸气/温柔/高冷）× 场景（校园/商务/恋爱/家庭）给出推荐

**3) 情绪语气词系统**

> `emotion-tags.md` 定义了 10 种语气词标签：(laughs)、(chuckle)、(gasps)、(sighs)、(crying)、(sniffs)、(emm)、(breath)、(pant)、(clear-throat)
> 还有停顿控制：`<#0.5#>`（0.5 秒停顿）

**4) 音频合并脚本**

> `merge_audio.py` 支持自定义间隔（--gap 500ms）、保留分段音频（--keep-segments），使用 pydub + ffmpeg

### 3.4 AIVP-Audio 脚本质量评估

#### text-to-speech.sh

**优点**：
- 简洁清晰，核心功能完整
- 支持 --voice 参数
- 本地保存（--output）

**问题**：
1. **JSON 构建不安全** — 字符串拼接：`PAYLOAD="{\"text\": \"$TEXT\""` — 文本中的引号会导致 JSON 损坏。TTS 文本经常包含引号。

2. **缺少关键参数**：
   - 无 `--speed`（语速控制）
   - 无 `--pitch`（音调控制）
   - 无 `--language`（语言指定）
   - 无 `--format`（输出格式选择）
   - 无情感标签文档

3. **使用同步模式** — `curl -s -X POST "$FAL_API_ENDPOINT/$MODEL"` 是同步调用，对于长文本可能超时。

4. **缺少 voice 列表功能** — 用户不知道有哪些可用 voice，竞品都提供了列表/查询功能。

5. **缺少声音克隆** — 这是视频制作中的重要能力（克隆特定人物的声音）。

6. **缺少音效生成** — 视频需要音效（脚步声、门声、环境音等），但我们没有这个脚本。

#### text-to-music.sh

**优点**：
- 使用队列模式（适合音乐生成的长耗时）
- 代码结构清晰

**问题**：
1. **JSON 构建不安全** — 同样的字符串拼接问题
2. **缺少关键参数** — 无 `--instrumental`（是否纯器乐）、无 `--genre`（音乐风格）
3. **缺少参考音频** — 一些模型支持用参考音频来指导风格

#### speech-to-text.sh

**优点**：
- 功能完整（audio_url → transcription）
- 支持语言指定

**问题**：
1. **缺少 speaker diarization** — 竞品 ElevenLabs Scribe 支持说话人识别
2. **缺少本地文件支持** — 只接受 URL，不能直接处理本地音频文件
3. **缺少时间戳输出** — 对字幕生成很重要

### 3.5 具体改进建议

#### 建议 1: 新增 sound-effects.sh 脚本

```bash
#!/bin/bash
# AIVP Sound Effects Generation Script
# Usage: ./sound-effects.sh --prompt "..." [--duration SECS] [--loop]

set -e

FAL_API_ENDPOINT="https://fal.run"
MODEL="fal-ai/elevenlabs/sound-effects"
PROMPT=""
DURATION=""
LOOP=false
OUTPUT_PATH=""

# ... (参数解析)

# Build payload with jq
PAYLOAD=$(jq -n \
  --arg text "$PROMPT" \
  '{text: $text}')

[ -n "$DURATION" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --argjson d "$DURATION" '. + {duration_seconds: $d}')
[ "$LOOP" = true ] && PAYLOAD=$(echo "$PAYLOAD" | jq '. + {loop: true}')

# ... (调用 API)
```

#### 建议 2: 增强 text-to-speech.sh

```bash
# 新增参数
--speed         # 语速 0.5-2.0（默认 1.0）
--pitch         # 音调 -12~12（默认 0）
--language      # 语言代码：en, zh, ja, ko
--format        # 输出格式：mp3, wav, opus
--emotion       # 情感标签：happy, sad, angry, calm

# 使用 jq 构建 payload
PAYLOAD=$(jq -n \
  --arg text "$TEXT" \
  '{text: $text}')

[ -n "$VOICE" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg v "$VOICE" '. + {voice: $v}')
[ -n "$SPEED" ] && PAYLOAD=$(echo "$PAYLOAD" | jq --argjson s "$SPEED" '. + {speed: $s}')
```

#### 建议 3: 新增 voice-clone.sh 脚本

```bash
#!/bin/bash
# AIVP Voice Clone Script
# Usage: ./voice-clone.sh --audio-url "..." --name "MyVoice"
# Returns: voice_id for use in text-to-speech.sh

set -e

# 使用 MiniMax 的声音克隆 API
# 1. upload audio → get file_id
# 2. clone voice → get voice_id
# 3. 返回 voice_id
```

#### 建议 4: 新增 list-voices.sh 脚本

```bash
#!/bin/bash
# AIVP List Available Voices
# Usage: ./list-voices.sh [--model MODEL] [--language LANG]

# 查询可用的 voice 列表
# 输出: voice_id | name | language | gender | description
```

#### 建议 5: SKILL.md 增加音效和多人对话文档

```markdown
## Sound Effects Generation

\`\`\`bash
bash scripts/sound-effects.sh \
  --prompt "Footsteps on gravel, getting closer" \
  --duration 5 \
  --output sfx/footsteps.mp3
\`\`\`

## Multi-Speaker Dialogue

对于多人对话场景，建议工作流：
1. 用 text-to-speech.sh 逐段生成每个角色的语音
2. 使用 ffmpeg 合并音频片段
3. 或使用 fal-ai/elevenlabs/text-to-dialogue 模型一次生成

### 情感标签参考
| 标签 | 效果 | 示例 |
|------|------|------|
| [laughs] | 笑声 | "That's hilarious [laughs]" |
| [sighs] | 叹气 | "[sighs] I can't believe it" |
| [whispers] | 耳语 | "[whispers] Don't tell anyone" |
```

#### 建议 6: 所有脚本统一使用 jq 构建 JSON

这是所有三个 aivp skill 共同的最重要改进。当前的字符串拼接方式在以下场景会失败：
- prompt/text 包含英文引号: `He said "hello"`
- prompt/text 包含反斜杠: `path\to\file`
- prompt/text 包含换行符: 多行文本

---

## 4. 缺失能力分析与新增 Skill 建议

### 4.1 口型同步（Lipsync）— **强烈建议新增**

**现状**: AIVP 完全缺失口型同步能力。

**需求场景**:
- 数字人视频：角色需要说话
- 配音视频：给现有角色配上语音
- 短剧/广告：说话角色是核心

**实现方案**:

#### 方案 A: 在 aivp-video 中集成

在 SKILL.md 中增加口型同步工作流：

```markdown
### Lipsync Workflow

1. 生成语音: aivp-audio → text-to-speech.sh
2. 生成口型同步视频:
   - 方法 1: Seedance v1.5 Pro (原生音频，自动唇形同步)
   - 方法 2: OmniHuman v1.5 (图片+音频→口型视频)
```

在 generate.sh 中添加 `--audio-url` 参数，检测到时自动路由到 OmniHuman：

```bash
if [ -n "$AUDIO_URL" ]; then
    # Route to OmniHuman for lipsync
    MODEL="fal-ai/bytedance/omnihuman/v1.5"
fi
```

#### 方案 B: 新增独立的 aivp-lipsync skill（推荐）

```
skills/aivp-lipsync/
├── SKILL.md
└── scripts/
    ├── generate.sh       # 图片+音频→口型视频 (OmniHuman)
    └── upload.sh         # 复用
```

推荐方案 B，因为口型同步的输入（图片+音频）和参数（resolution, turbo_mode）与普通视频生成差异较大。

### 4.2 动作迁移（Motion Transfer）— **建议新增**

**现状**: AIVP 缺失动作迁移能力。

**需求场景**:
- 让静态角色做特定动作（舞蹈、手势、表情）
- 统一不同角色的动作风格
- 非真人角色（动画、宠物）的动画

**建议**: 可以先作为 aivp-video 的一种模式支持（通过 `--video-url` + `--image-url` 触发 Dreamactor 路由），后续如果复杂度增大再独立 skill。

```bash
# 在 aivp-video generate.sh 中
if [ -n "$VIDEO_URL" ] && [ -n "$IMAGE_URL" ]; then
    # Motion transfer mode → route to Dreamactor
    MODEL="fal-ai/bytedance/dreamactor/v2"
fi
```

### 4.3 音效生成（Sound Effects）— **建议新增**

**现状**: aivp-audio 只有 TTS 和音乐，没有音效。

**需求场景**:
- 脚步声、门声、环境音
- 转场音效
- UI 音效

**建议**: 在 aivp-audio 中新增 `sound-effects.sh` 脚本，使用 fal.ai 的 ElevenLabs SFX 端点或 MiniMax 的音效模型。

### 4.4 声音克隆（Voice Clone）— **建议支持**

**现状**: aivp-audio 没有声音克隆能力。

**需求场景**:
- 用特定人物的声音做配音
- 角色声音一致性（整个视频使用同一音色）

**建议**: 在 aivp-audio 中新增 `voice-clone.sh` 和 `list-voices.sh`。

### 4.5 多人对话合成 — **建议支持**

**现状**: aivp-audio 只能单人 TTS。

**需求场景**:
- 多角色对话视频
- 访谈类视频

**建议**: 参考 sutui-minimax-tts 的工作流，在 aivp-audio 中新增 `dialogue.sh`。

### 4.6 视频后处理工具链 — **建议在 aivp-edit 中覆盖**

inference-sh 提供的以下能力应在 aivp-edit 阶段覆盖：
- **Foley（后期配音）**: 给静音视频添加环境音效
- **视频放大**: 提升视频分辨率
- **视频合并**: 多个片段拼接 + 转场

---

## 5. 总结与优先级建议

### 5.1 三个 Skill 的整体质量评价

| 维度 | aivp-image | aivp-video | aivp-audio |
|------|:----------:|:----------:|:----------:|
| SKILL.md 文档质量 | ★★★★☆ | ★★★★★ | ★★★★☆ |
| 脚本完整度 | ★★☆☆☆ (缺 edit/upload) | ★★★★★ (4脚本全) | ★★★☆☆ (缺音效/克隆) |
| 脚本代码质量 | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |
| 模型覆盖广度 | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |
| 参数丰富度 | ★★☆☆☆ | ★★★☆☆ | ★★☆☆☆ |
| 错误处理 | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |
| 竞品差距 | 较大 | 中等 | 较大 |

### 5.2 改进优先级排序

#### P0 — 必须立即修复

1. **所有脚本使用 jq 构建 JSON** — 当前的字符串拼接是功能性 Bug，含引号的 prompt 会导致 API 调用失败
2. **补全 aivp-image 的 edit.sh 和 upload.sh** — SKILL.md 承诺的功能不存在

#### P1 — 高优先级改进

3. **aivp-video 增加 resolution/generate_audio/end_image_url/negative_prompt 参数** — 这些是竞品标配
4. **aivp-audio 增加 speed/pitch/language/format 参数** — 基础 TTS 控制能力
5. **新增 aivp-lipsync skill** — 口型同步是视频制作核心能力，完全缺失
6. **aivp-audio 新增 sound-effects.sh** — 视频制作必备

#### P2 — 中优先级

7. **aivp-image 增加模型自动选择逻辑** — 参考 fal-text-to-image 的智能路由
8. **aivp-audio 新增 voice-clone.sh 和 list-voices.sh** — 角色声音一致性
9. **aivp-video SKILL.md 增加首尾帧/多镜头/音频生成工作流文档** — 竞品优势功能
10. **所有 skill 增加详细的计费文档** — 帮助用户做成本决策

#### P3 — 长期改进

11. **动作迁移支持** (Dreamactor) — 可先在 aivp-video 中作为模式支持
12. **提示词模板系统** — 参考 nano-hub 为不同镜头类型预设模板
13. **LoRA / ControlNet 支持** — 高级用户的精细控制需求
14. **视频后处理工具链** (Foley/放大/合并) — 在 aivp-edit 中覆盖

### 5.3 竞品启发的架构思考

1. **MCP vs Bash 脚本**: 竞品大多使用 MCP submit_task/get_task，而我们用 Bash 脚本。Bash 脚本的优势是通用性（不依赖 MCP 服务器），但缺点是 JSON 处理不如 Python/SDK 安全。建议保持 Bash 但务必引入 `jq`。

2. **单模型 Skill vs 多模型 Skill**: hexiaochun 的每个模型一个 Skill（seedance-video、sora-2、hailuo-video...），而我们的 aivp-video 是多模型聚合。聚合方式更适合 pipeline 使用，但需要更完善的模型路由逻辑。

3. **文档即接口**: 所有竞品的 SKILL.md 都是 Agent 的"接口文档"。文档越详细（参数表、示例、选择指南），Agent 使用得越好。建议继续强化文档，特别是**模型选择决策树**和**工作流示例**。

4. **子代理/模板系统**: nano-hub 用子代理生成高质量提示词的方式值得借鉴。AIVP 可以在 storyboard → image 阶段引入类似机制，让 AI 根据镜头描述自动优化 prompt。
