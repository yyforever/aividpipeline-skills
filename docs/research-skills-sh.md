# Skills.sh 平台调研报告：AI 视频制作相关 Skill

> 调研日期：2026-02-21
> 平台地址：https://skills.sh
> GitHub 仓库：https://github.com/vercel-labs/skills

---

## 一、平台概况

### 1.1 什么是 Skills.sh

Skills.sh 是 Vercel 推出的**开放 Agent Skills 生态系统**（The Open Agent Skills Ecosystem）。Skill 是 AI Agent 的可复用能力模块——本质是包含 `SKILL.md` 文件的目录，通过 YAML frontmatter 定义名称和描述，正文是 Markdown 格式的指令和知识。

**核心理念**：Skill 不是传统意义上的代码插件，而是**程序性知识（procedural knowledge）**——告诉 AI Agent 如何做某件事的文档。

### 1.2 关键数据

| 指标 | 数值 |
|------|------|
| 总安装量 | 70,047+ |
| 支持的 Agent 数量 | 40+（Claude Code, Cursor, Codex, OpenCode, OpenClaw 等） |
| Top 1 Skill 安装量 | find-skills: 282K |
| 排行榜分类 | All Time / Trending (24h) / Hot |

### 1.3 Skill 格式规范

```markdown
---
name: my-skill
description: What this skill does and when to use it
metadata:
  internal: false  # 可选，设为 true 隐藏
---

# My Skill

Instructions for the agent...

## When to Use
...

## Steps
1. First, do this
2. Then, do that
```

**安装方式**：
```bash
npx skills add <owner/repo>                    # 安装仓库中所有 skill
npx skills add <owner/repo> --skill <name>     # 安装特定 skill
npx skills add <owner/repo> -a claude-code     # 指定 agent
npx skills add <owner/repo> -g                 # 全局安装
```

**Skill 发现路径**：CLI 会在仓库的 `skills/`、`.claude/skills/`、`.agents/skills/` 等多个目录中搜索 `SKILL.md` 文件。

### 1.4 支持的 Agent（部分）

| Agent | --agent 参数 | 项目路径 |
|-------|-------------|---------|
| Claude Code | claude-code | .claude/skills/ |
| **OpenClaw** | openclaw | skills/ |
| Cursor | cursor | .agents/skills/ |
| Codex | codex | .agents/skills/ |
| Windsurf | windsurf | .windsurf/skills/ |
| Gemini CLI | gemini-cli | .agents/skills/ |

> ✅ **OpenClaw 已被原生支持**，安装路径为 `skills/` 和 `~/.openclaw/skills/`。

---

## 二、AI 视频制作相关 Skill 详细调研

### 2.1 视频生成（Text-to-Video / Image-to-Video）

#### inference-sh/skills — ai-video-generation ⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-video-generation |
| **作者** | inference-sh/skills |
| **安装量** | 16 |
| **安装命令** | `npx skills add inference-sh/skills@ai-video-generation` |
| **描述** | 通过 inference.sh CLI 使用 40+ AI 模型生成视频 |
| **支持模型** | Veo 3.1, Veo 3, Seedance 1.5 Pro, Wan 2.5, Grok Video, OmniHuman, Fabric, HunyuanVideo |

**关键能力**：
- **Text-to-Video**：Veo 3.1 (Fast/Standard)、Grok Video、Seedance 1.5 Pro
- **Image-to-Video**：Wan 2.5、Seedance Lite
- **Avatar/Lipsync**：OmniHuman 1.5/1.0、Fabric 1.0、PixVerse Lipsync
- **工具类**：HunyuanVideo Foley（音效）、Topaz 视频增强、Media Merger（合并）

**使用示例**：
```bash
# Text-to-Video
infsh app run google/veo-3-1-fast --input '{"prompt": "drone shot flying over a forest"}'

# Image-to-Video
infsh app run falai/wan-2-5 --input '{"image_url": "https://your-image.jpg"}'

# 视频合并
infsh app run infsh/media-merger --input '{"videos": ["clip1.mp4", "clip2.mp4"], "transition": "fade"}'
```

---

#### inference-sh/skills — ai-avatar-video ⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-avatar-video |
| **作者** | inference-sh/skills |
| **安装量** | 15 |
| **安装命令** | `npx skills add inference-sh/skills@ai-avatar-video` |
| **描述** | 创建 AI 虚拟人和口型同步视频 |
| **支持模型** | OmniHuman 1.5/1.0, Fabric 1.0, PixVerse Lipsync |

**关键能力**：
- 图片+音频→说话视频（Talking Head）
- 多人场景中驱动指定角色
- 完整的 TTS + Avatar 工作流
- 视频配音/翻译工作流（转录→翻译→TTS→Lipsync）

---

#### inference-sh/skills — ai-marketing-videos ⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-marketing-videos |
| **作者** | inference-sh/skills |
| **安装量** | 14 |
| **安装命令** | `npx skills add inference-sh/skills@ai-marketing-videos` |
| **描述** | 创建专业营销视频（广告、产品演示、品牌内容） |

**关键能力**：
- 完整的 30 秒广告制作工作流（Hook→问题→解决方案→收益→CTA→配音→合并）
- Instagram/TikTok 竖版广告
- 解释型视频（Explainer Video）
- A/B 测试变体批量生成
- 包含平台特定格式指南（YouTube Pre-Roll、LinkedIn、TikTok 等）

---

#### davila7/claude-code-templates — heygen-best-practices ⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | heygen-best-practices |
| **作者** | davila7/claude-code-templates |
| **描述** | HeyGen API 最佳实践：AI 虚拟人视频、视频生成工作流 |

**关键能力**：
- HeyGen API 完整集成指南
- Avatar 管理、语音选择、脚本编写
- 多场景视频生成
- 视频翻译/配音
- 流式虚拟人（实时交互）
- Remotion 集成（将 HeyGen 视频用于 Remotion 合成）

---

#### inference-sh/skills — video-prompting-guide ⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | video-prompting-guide |
| **作者** | inference-sh/skills |
| **安装量** | 14 |
| **描述** | AI 视频生成 Prompt 工程最佳实践 |

**关键能力**：
- 覆盖 Veo、Seedance、Wan、Grok 等主流模型的提示词策略
- 镜头类型、运镜、打光、节奏、风格关键词
- Prompt 结构公式：[Shot Type] + [Subject] + [Action] + [Setting] + [Lighting] + [Style] + [Technical]

---

### 2.2 图片生成（Text-to-Image / Image Editing）

#### inference-sh/skills — ai-image-generation ⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-image-generation |
| **作者** | inference-sh/skills |
| **安装量** | 16 |
| **安装命令** | `npx skills add inference-sh/skills@ai-image-generation` |
| **描述** | 使用 50+ AI 模型生成图片 |

**支持模型**：

| 模型 | App ID | 用途 |
|------|--------|------|
| FLUX Dev LoRA | falai/flux-dev-lora | 高质量+自定义风格 |
| FLUX.2 Klein LoRA | falai/flux-2-klein-lora | 快速+LoRA (4B/9B) |
| Gemini 3 Pro | google/gemini-3-pro-image-preview | Google 最新 |
| Grok Imagine | xai/grok-imagine-image | xAI，多宽高比 |
| Seedream 4.5 | bytedance/seedream-4-5 | 2K-4K 电影级 |
| Reve | falai/reve | 自然语言编辑+文字渲染 |
| ImagineArt 1.5 Pro | falai/imagine-art-1-5-pro-preview | 超高保真 4K |
| Topaz Upscaler | falai/topaz-image-upscaler | 专业放大 |

**能力**：text-to-image, image-to-image, inpainting, LoRA, image editing, upscaling, text rendering

---

#### black-forest-labs/skills — flux-best-practices ⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | flux-best-practices |
| **作者** | black-forest-labs/skills（FLUX 官方） |
| **描述** | FLUX 模型提示词最佳实践 |

**关键能力**：
- FLUX 全系列模型选型指南（klein/max/pro/flex/dev）
- Prompt 结构：[Subject] + [Action/Pose] + [Style/Medium] + [Context/Setting] + [Lighting] + [Camera/Technical]
- 关键规则：不支持负面提示词、使用自然语言、指定灯光
- 覆盖 T2I、I2I、JSON 结构化提示、HEX 颜色、排版文字渲染等

---

#### inference-sh/skills — image-upscaling / background-removal ⭐

| 名称 | 描述 | 安装量 |
|------|------|--------|
| image-upscaling | Real-ESRGAN, Thera, Topaz, FLUX Upscaler 放大增强 | 10 |
| background-removal | BiRefNet 高精度背景去除 | 12 |

---

### 2.3 音频生成（TTS / Text-to-Music）

#### inference-sh/skills — ai-voice-cloning ⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-voice-cloning |
| **作者** | inference-sh/skills |
| **安装量** | 14 |
| **安装命令** | `npx skills add inference-sh/skills@ai-voice-cloning` |
| **描述** | AI 语音生成、TTS、语音合成 |

**支持模型**：

| 模型 | App ID | 特点 |
|------|--------|------|
| Kokoro TTS | infsh/kokoro-tts | 自然多声线，多种情感 |
| DIA | infsh/dia-tts | 对话式、富有表现力 |
| Chatterbox | infsh/chatterbox | 休闲娱乐 |
| Higgs | infsh/higgs-tts | 专业旁白 |
| VibeVoice | infsh/vibevoice | 情感丰富 |

**Voice 库**（Kokoro）：美式英语（af_sarah, am_michael 等）、英式英语（bf_emma, bm_george 等）

**关键能力**：
- 多声线对话生成
- 长文本分段处理+合并
- Voice + Video 工作流（配音→合并）
- 语速控制（0.8-1.2x）

---

#### inference-sh/skills — ai-podcast-creation ⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-podcast-creation |
| **作者** | inference-sh/skills |
| **安装量** | 14 |
| **描述** | AI 播客、有声书、音频内容创建 |

**关键能力**：
- 多声线对话播客
- AI 音乐生成（`infsh/ai-music`）
- 完整播客制作流程：脚本→配音→背景音乐→合并
- NotebookLM 风格：文档→讨论型播客
- 音频增强：背景音乐混音、音效转场

---

#### inference-sh/skills — speech-to-text ⭐

| 属性 | 内容 |
|------|------|
| **名称** | speech-to-text |
| **作者** | inference-sh/skills |
| **安装量** | 10 |
| **描述** | Whisper 模型语音转文字（Fast Whisper Large V3） |
| **能力** | 转录、翻译、多语言、时间戳 |

---

### 2.4 视频编辑（FFmpeg / Remotion）

#### remotion-dev/skills — remotion-best-practices ⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | remotion-best-practices |
| **作者** | remotion-dev/skills（Remotion 官方） |
| **安装量** | 102.5K（#4 全站） |
| **安装命令** | `npx skills add remotion-dev/skills` |
| **描述** | Remotion — React 驱动的视频创建最佳实践 |

**涵盖知识文件（28 个子规则）**：

| 规则文件 | 内容 |
|----------|------|
| 3d.md | Three.js / React Three Fiber 3D 内容 |
| animations.md | 基础动画技能 |
| assets.md | 导入图片、视频、音频、字体 |
| audio.md | 音频使用（导入、裁剪、音量、速度、音高） |
| ffmpeg.md | FFmpeg 视频操作（裁剪、静音检测等） |
| audio-visualization.md | 音频可视化（频谱条、波形、低音反应） |
| subtitles.md | 字幕/captions |
| text-animations.md | 排版和文字动画 |
| transitions.md | 场景转场 |
| voiceover.md | ElevenLabs TTS AI 配音集成 |
| parameters.md | Zod Schema 参数化视频 |
| charts.md | 图表和数据可视化 |
| maps.md | Mapbox 地图+动画 |
| ...等 | 共 28 个详细规则文件 |

---

#### google-labs-code/stitch-skills — remotion ⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | remotion (Stitch to Remotion Walkthrough Videos) |
| **作者** | google-labs-code/stitch-skills |
| **描述** | 将 Stitch 设计稿自动制作为 Remotion 演示视频 |

**关键能力**：
- 从 Stitch 项目获取设计稿截图
- 自动编排为 Remotion 视频组合
- 专业转场（fade, slide, zoom）
- 文字叠加、进度指示器

---

#### anthropics/skills — slack-gif-creator ⭐

| 属性 | 内容 |
|------|------|
| **名称** | slack-gif-creator |
| **作者** | anthropics/skills（Anthropic 官方） |
| **安装量** | 6.1K |
| **描述** | 创建优化的 Slack GIF 动画 |
| **能力** | PIL 绘图+动画、GIF Builder、Easing 函数、尺寸验证 |

---

### 2.5 内容发布（Social Media / Twitter）

#### inference-sh/skills — twitter-automation ⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | twitter-automation |
| **作者** | inference-sh/skills |
| **安装量** | 16 |
| **描述** | Twitter/X 自动化 |

**支持操作**：

| 操作 | App ID |
|------|--------|
| 发推 | x/post-tweet |
| 带媒体发推 | x/post-create |
| 点赞 | x/post-like |
| 转推 | x/post-retweet |
| 发 DM | x/dm-send |
| 关注 | x/user-follow |

**关键工作流**：生成 AI 图片/视频 → 自动发布到 Twitter

---

#### inference-sh/skills — ai-social-media-content ⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-social-media-content |
| **作者** | inference-sh/skills |
| **安装量** | 14 |
| **描述** | 全平台社交媒体内容创建 |

**关键能力**：

| 平台 | 宽高比 | 时长 | 分辨率 |
|------|--------|------|--------|
| TikTok | 9:16 | 15-60s | 1080x1920 |
| Instagram Reels | 9:16 | 15-90s | 1080x1920 |
| YouTube Shorts | 9:16 | <60s | 1080x1920 |
| Twitter/X | 16:9 / 1:1 | <140s | 1920x1080 |
| YouTube Thumbnail | 16:9 | - | 1280x720 |

包含：Talking Head 内容流程、批量创作、Hook 公式、标题/标签生成、多平台复用

---

### 2.6 内容编排 / Pipeline

#### inference-sh/skills — ai-content-pipeline ⭐⭐⭐⭐（最接近我们的 aividpipeline）

| 属性 | 内容 |
|------|------|
| **名称** | ai-content-pipeline |
| **作者** | inference-sh/skills |
| **安装量** | 14 |
| **安装命令** | `npx skills add inference-sh/skills@ai-content-pipeline` |
| **描述** | 多步骤 AI 内容创建 Pipeline |

**Pipeline 模式**：

| 模式 | 流程 |
|------|------|
| Pattern 1 | Image → Video → Audio |
| Pattern 2 | Script → Speech → Avatar |
| Pattern 3 | Research → Content → Distribution |

**完整工作流示例**：

1. **YouTube Short Pipeline**：Claude 写脚本 → Kokoro TTS → FLUX 背景图 → Wan 动画 → Media Merger
2. **Talking Head Pipeline**：Claude 脚本 → TTS → FLUX 肖像 → OmniHuman Avatar
3. **Product Demo Pipeline**：FLUX 产品图 → Wan 动画 → Topaz 增强 → 配音合并
4. **Blog to Video Pipeline**：Claude 总结 → FLUX 配图×5 → Wan 动画×5 → TTS → 合并

**Pipeline Building Blocks**：

| 阶段 | 工具 | 用途 |
|------|------|------|
| 内容生成 | Claude Sonnet 4.5 | 写脚本 |
| 调研 | Tavily Search | 收集信息 |
| 视觉素材 | FLUX Dev / Imagen 3 | 生成图片 |
| 动画 | Wan 2.5 / Veo 3.1 | I2V / T2V |
| 虚拟人 | OmniHuman 1.5 | Talking Head |
| 音频 | Kokoro TTS | 配音 |
| 音乐 | infsh/ai-music | 背景音乐 |
| 音效 | HunyuanVideo Foley | 视频配音效 |
| 后期 | Topaz Upscaler | 增强视频 |
| 合并 | Media Merger | 组合最终视频 |
| 字幕 | infsh/caption-video | 添加字幕 |

---

#### inference-sh/skills — ai-automation-workflows ⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | ai-automation-workflows |
| **作者** | inference-sh/skills |
| **安装量** | 14 |
| **描述** | 构建自动化 AI 工作流 |

**自动化模式**：
- 批量处理（Batch Processing）
- 顺序 Pipeline（Sequential）
- 并行处理（Parallel）
- 条件分支（Conditional）
- 重试+降级（Retry with Fallback）
- 定时任务（Cron）
- Python SDK 自动化

---

#### inference-sh/skills — inference-sh（全平台 Skill）⭐⭐⭐

| 属性 | 内容 |
|------|------|
| **名称** | inference-sh |
| **作者** | inference-sh/skills |
| **安装量** | 21 |
| **描述** | 150+ AI 应用的统一 CLI 入口 |

**覆盖类别**：

| 类别 | 代表应用 |
|------|---------|
| 图片 | FLUX, Gemini 3 Pro, Grok, Seedream 4.5, Reve, Topaz |
| 视频 | Veo 3.1, Seedance, Wan 2.5, OmniHuman, Fabric, HunyuanVideo Foley |
| LLM | Claude Opus/Sonnet/Haiku, Gemini 3 Pro, Kimi K2, GLM-4 |
| 搜索 | Tavily, Exa |
| 3D | Rodin 3D Generator |
| Twitter/X | post-tweet, post-create, dm-send, user-follow 等 |
| 工具 | Media merger, caption videos, image stitching |

---

## 三、Skills.sh Skill 格式 vs OpenClaw/ClaWHub 格式

| 维度 | Skills.sh (Vercel) | OpenClaw / ClaWHub |
|------|-------------------|-------------------|
| **核心载体** | `SKILL.md` (Markdown + YAML frontmatter) | `SKILL.md` + 可选的 `skill.yaml` 配置 |
| **本质** | 程序性知识文档（告诉 agent 怎么做） | 知识+工具+配置的混合体 |
| **安装方式** | `npx skills add <owner/repo>` | 目录/Git 克隆到 `skills/` |
| **分发** | GitHub 仓库直接引用 | ClaWHub 或本地仓库 |
| **Agent 支持** | 40+ Agent（通用标准） | OpenClaw 特化，但格式兼容 |
| **代码执行** | 无内置代码执行，靠 agent 的工具 | 可定义工具和动作 |
| **依赖管理** | 无显式依赖声明 | 可声明依赖和环境 |
| **运行时** | 纯文档注入，agent 自行执行 | 可包含配置、环境变量、MCP 等 |
| **版本管理** | Git commit/tag | Git-based |
| **搜索/发现** | skills.sh 网站 + `npx skills find` | ClaWHub 或本地 |
| **排行/计量** | 匿名 telemetry 安装统计 | 无 |
| **子规则** | 支持 `rules/` 子目录，按需加载 | 支持 `references/` 等子目录 |

**关键区别**：
1. Skills.sh 的 skill 本质是**纯知识注入**——没有可执行代码，完全依赖 agent 的现有能力（CLI、API 调用等）
2. OpenClaw skill 可以**包含工具定义和执行逻辑**——更像传统插件
3. Skills.sh 的 **跨 agent 兼容性更好**（40+ agent），而 OpenClaw 更深度集成
4. Skills.sh 使用 **symlink** 安装到各 agent 目录，保持单一源
5. inference-sh 的 skill 实际依赖外部 CLI（`infsh`），skill 只是"教 agent 怎么用 infsh"

---

## 四、端到端视频制作 Skill 套件分析

### 4.1 最接近 aividpipeline 的方案

**inference-sh 的 skill 套件**是平台上最接近端到端视频制作的方案，包含：

| Skill | 对应 Pipeline 环节 |
|-------|-------------------|
| ai-content-pipeline | 总编排/Pipeline |
| ai-video-generation | 视频生成（T2V, I2V） |
| ai-image-generation | 图片/素材生成 |
| ai-avatar-video | 虚拟人/Talking Head |
| ai-voice-cloning | TTS/配音 |
| ai-podcast-creation | 播客/音频内容 |
| ai-marketing-videos | 营销视频模板 |
| ai-social-media-content | 社交媒体内容 |
| ai-automation-workflows | 自动化工作流 |
| twitter-automation | Twitter 发布 |
| video-prompting-guide | 视频提示词工程 |
| prompt-engineering | 通用提示词工程 |

### 4.2 与我们的 aividpipeline 对比

| 维度 | inference-sh 套件 | 我们的 aividpipeline |
|------|-------------------|---------------------|
| **集成度** | 松耦合（多个独立 skill） | 紧耦合（统一 pipeline） |
| **执行引擎** | 依赖 infsh CLI（外部服务） | 可本地执行 |
| **编辑能力** | 弱（只有 media merger） | 强（FFmpeg、Remotion） |
| **成本** | 依赖 inference.sh 付费平台 | 可用开源模型 |
| **定制化** | 有限（模板化） | 高度可定制 |
| **离线能力** | 无（纯云端） | 可本地运行 |
| **知识深度** | 每个 skill 各自独立 | Pipeline 整体知识 |

### 4.3 Remotion 作为视频编辑层

Remotion 的官方 skill（#4 全站，102.5K 安装量）是非常成熟的**视频编辑/生成知识库**，涵盖：
- 28 个详细规则文件
- FFmpeg 集成
- 字幕系统
- AI 配音集成（ElevenLabs）
- 3D/图表/地图等高级功能

但 Remotion 是**代码驱动的视频制作**（React 组件→渲染视频），不是 AI 生成视频。

---

## 五、总结与启发

### 5.1 平台总结

1. **Skills.sh 是一个快速增长的生态**：70K+ 总安装量，40+ Agent 支持，Vercel 官方推动
2. **AI 视频制作是热门方向**：inference-sh 提供了最完整的视频制作 skill 套件（约 15 个相关 skill）
3. **Skill 本质是"知识注入"**：不是代码插件，而是告诉 agent "用什么工具、怎么用"的文档
4. **inference-sh 占据主导地位**：几乎所有 AI 媒体生成 skill 都来自他们，他们实际上是在用 skill 推广自己的平台
5. **缺少真正的端到端 pipeline**：虽然有 ai-content-pipeline，但只是 shell 脚本级别的编排，缺少状态管理、错误恢复、资产管理等

### 5.2 对我们的启发

1. **✅ 发布到 skills.sh**：OpenClaw 已被 skills.sh 原生支持（`--agent openclaw`），我们应该将 aividpipeline skill 发布到 skills.sh，获取曝光
2. **✅ 采用 SKILL.md 格式**：确保我们的 skill 兼容 skills.sh 格式（YAML frontmatter + Markdown），这样可以被 40+ 个 agent 使用
3. **✅ 模块化 + 整体**：学习 inference-sh 的策略——既有整体 skill（inference-sh），也有细分 skill（ai-video-generation, ai-image-generation 等），满足不同使用场景
4. **🔥 差异化优势**：
   - inference-sh 的 skill 依赖外部付费平台，我们可以强调**本地/开源模型支持**
   - 他们缺少真正的 pipeline 编排引擎，我们有 OpenClaw 的 subagent 和工具系统
   - 他们的视频编辑能力弱（只有 media merger），我们可以整合 FFmpeg + Remotion
   - 他们的 skill 是松耦合的，我们可以提供**端到端一体化体验**
5. **📝 参考 Remotion 的知识结构**：28 个子规则文件按需加载是很好的模式——避免一次注入过多 token
6. **🎯 关注 inference.sh 作为补充工具**：其 CLI 支持 150+ AI 应用，可以作为我们 pipeline 中的一个可选后端
7. **📢 Twitter/社交媒体发布**是重要的最后一公里——inference-sh 已经做了 Twitter 自动化，我们也需要考虑内容分发环节

### 5.3 推荐行动

1. **近期**：将 aividpipeline 的核心 skill 适配 SKILL.md 格式，发布到 GitHub
2. **中期**：在 skills.sh 上架，与 inference-sh 的 skill 形成互补（我们专注 pipeline 编排 + 本地执行，他们专注云端 AI 模型）
3. **长期**：构建 ClaWHub ↔ skills.sh 的双向兼容，让 OpenClaw 用户可以无缝使用两个生态的 skill
