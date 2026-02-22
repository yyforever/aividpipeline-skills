# ClaWHub 竞品调研报告：AI 视频制作相关 Skill

**调研日期**: 2026-02-21  
**调研范围**: ClaWHub (clawhub.ai) + 本地 openclaw-skills 仓库  
**调研目的**: 了解与 aivp-* 系列 skill 相关的竞品，发现差距和机会

---

## 一、ClaWHub 平台概况

ClaWHub (https://clawhub.ai) 是 OpenClaw 生态的 skill 市场/仓库。平台以 Git 仓库方式（`openclaw-skills/skills/{作者}/{skill名}/`）管理社区贡献的 skill。每个 skill 以 `SKILL.md` 为核心描述文件，可包含脚本（`scripts/`）、参考文档（`references/`）和资产（`assets/`）。

**平台特点**：
- 社区驱动：数千作者（本地仓库含 3000+ 作者目录）
- 多语言：中英文 skill 共存
- 无审核门槛：质量参差不齐
- 以 prompt/知识型 skill 为主，真正可执行的脚本型 skill 较少

---

## 二、关键竞品 Skill 详细分析

### 2.1 视频生成类

#### hexiaochun 系列（最主要竞品，作者 hexiaochun = 速推AI）

hexiaochun 是目前 ClaWHub 上最活跃的 AI 视频/图像生成 skill 作者，共发布 **32 个 skill**，形成了较完整的模型接入矩阵。

| Skill 名称 | 模型 | 功能 | 关键特性 | 质量评分 |
|------------|------|------|----------|---------|
| **seedance-video** | Bytedance Seedance v1/v1.5 | 文生视频、图生视频、参考图生视频 | 支持音频生成、唇形同步、多分辨率(480p-1080p)、详细定价 | ⭐⭐⭐⭐⭐ |
| **sora-2** | OpenAI Sora 2 | 文生视频、图生视频、视频重混 | Pro版支持1080p、视频重混(风格转换) | ⭐⭐⭐⭐⭐ |
| **hailuo-video** | MiniMax Hailuo 2.3 | 文生视频、图生视频 | Fast/标准系列、Pro/Standard版本、可选时长 | ⭐⭐⭐⭐ |
| **wan-video** | Wan 2.6 | 图生视频、参考视频生成 | R2V主体一致性、Flash高性价比版 | ⭐⭐⭐⭐ |
| **vidu-video** | Vidu Q3 Pro | 文生视频 | 支持带音频视频、多分辨率(360p-1080p) | ⭐⭐⭐⭐ |
| **dreamactor-video** | Bytedance Dreamactor V2 | 动作迁移 | 表情/口型迁移、支持非人类角色、最大30秒 | ⭐⭐⭐⭐ |
| **omnihuman-video** | Bytedance OmniHuman v1.5 | 音频驱动视频 | 图片+音频→口型同步视频、最长60秒(720p) | ⭐⭐⭐⭐⭐ |
| **seedream-image** | Bytedance Seedream 4.5 | 文生图、图生图 | 支持2K/4K、多种尺寸预设 | ⭐⭐⭐⭐ |
| **flux2-flash** | FLUX.2 [dev] | 文生图、图像编辑 | 自动模式切换、增强写实感、文字渲染 | ⭐⭐⭐⭐ |

**hexiaochun 系列的核心特点**：
1. **统一接口设计**：所有 skill 使用相同的 MCP 工具（`submit_task` / `get_task`），统一的异步轮询模式
2. **详细的定价文档**：每个模型的按秒/按次/按分辨率定价都有完整表格
3. **中文优先**：所有文档中文撰写，面向中文用户
4. **商业化整合**：背后是"速推AI"平台，有完整的积分体系、用户管理、成本审计
5. **无脚本实现**：纯 SKILL.md 知识型，无独立脚本（依赖 MCP 服务端实现）

**额外的基础设施 skill**：
- `add-fal-model`：添加新 fal 模型的标准流程
- `fal-consumption-audit`：fal 消耗审计
- `cdn-url-transfer`：CDN 链接转存
- `fal-llms-txt`：获取 fal 模型文档
- `parse-video`：多平台视频链接解析（抖音/快手/小红书/B站等）
- `image-model-evaluation`：图像模型效果评估

#### 与 aivp-video / aivp-image 对比

| 维度 | hexiaochun 系列 | aivp-video / aivp-image |
|------|----------------|------------------------|
| **模型覆盖** | 每个模型独立 skill（精细） | 统一接口支持多模型（通用） |
| **文档深度** | 极详细（参数、定价、示例） | 中等（脚本用法为主） |
| **可执行性** | 纯知识型（依赖 MCP 后端） | 有独立 bash 脚本 |
| **定价透明** | 每个模型完整定价表 | 无定价信息 |
| **模型数量** | 8+ 视频模型，6+ 图像模型 | 泛型接口，不限模型 |
| **特色功能** | 口型同步、动作迁移、音频驱动 | queue-based 通用生成 |

---

#### 其他视频生成 Skill

| Skill | 作者 | 描述 | 特色 | 与 aivp 对比 |
|-------|------|------|------|-------------|
| **grok-imagine-video** | devvgwardo | xAI Grok API 集成 | 文生视频、图生视频、视频编辑、异步轮询 | aivp-video 不支持 Grok 模型 |
| **aimlapi-media-gen** | d1m7asis | AIMLAPI 图像/视频生成 | OpenAI 兼容接口、batch job | 类似 aivp-video 的通用接入 |
| **renderful-ai** | luv005 | Renderful.ai API | 支持加密支付、多模型(FLUX/Kling/Sora) | 又一个聚合 API |

---

### 2.2 图像生成类

| Skill | 作者 | 模型/API | 关键特性 | 质量 |
|-------|------|---------|----------|------|
| **fal-text-to-image** | delorenj | fal.ai (FLUX, Recraft, Imagen4) | 三模式（文生图/remix/编辑）、多模型智能选择、inpainting | ⭐⭐⭐⭐⭐ |
| **fal-ai** | sxela | fal.ai 多模型 | Flux/Gemini/Kling 视频编辑、Nano Banana Pro | ⭐⭐⭐⭐ |
| **fal** | apekshik | fal.ai 通用接口 | search/schema/run/upload 命令式 | ⭐⭐⭐⭐ |
| **fal-api** | agmmnn | fal.ai API | 600+ 模型、queue-based | ⭐⭐⭐ |
| **falimagegen** | xxmzdxxxm | fal.ai 图像 | 文生图/图生图基础 | ⭐⭐⭐ |
| **comfyui-imagegen** | halr9000 | 本地 ComfyUI | 结构化 JSON prompt、异步 sub-agent 轮询 | ⭐⭐⭐⭐ |
| **krea-api** | fossilizedcarlos | Krea.ai | 多模型(Flux/Imagen/Ideogram/Seedream) | ⭐⭐⭐⭐ |
| **imagerouter** | dawe35 | ImageRouter API | 聚合路由器、多模型统一接口 | ⭐⭐⭐ |
| **nano-hub** | hexiaochun | Nano Banana Pro | 模板中心（信息图/角色/电商/浮世绘等） | ⭐⭐⭐⭐ |
| **character-creator** | hexiaochun | Seedream 4.5 | 角色创建全流程、多角度参考图、HTML展示 | ⭐⭐⭐⭐⭐ |

#### 与 aivp-image 对比

| 维度 | 竞品亮点 | aivp-image |
|------|---------|-----------|
| **多模型路由** | imagerouter/fal 系列：智能选择最优模型 | 支持多 provider 但需手动指定 |
| **inpainting** | fal-text-to-image：支持 mask + inpainting | 有 edit.sh 基础编辑 |
| **模板系统** | nano-hub：10+ 场景模板 | 无预设模板 |
| **角色一致性** | character-creator：多角度参考图流程 | 无角色一致性专项 |

---

### 2.3 音频/TTS 类

| Skill | 作者 | 服务 | 关键特性 | 质量 |
|-------|------|------|----------|------|
| **elevenlabs** | odrobnik | ElevenLabs | 最完善的 TTS skill：v3 audio tags、音效、音乐、声音管理、配额检查 | ⭐⭐⭐⭐⭐ |
| **elevenlabs-music** | clawdbotborges | ElevenLabs Music | 音乐生成、3-600秒、vocals/instrumental | ⭐⭐⭐⭐ |
| **elevenlabs-stt** (hexiaochun) | hexiaochun | ElevenLabs Scribe V2 | 语音转文字、说话人分离、音频事件标注 | ⭐⭐⭐⭐ |
| **minimax-audio** | hexiaochun | MiniMax 海螺 | TTS + 声音克隆 + 音色设计 | ⭐⭐⭐⭐ |
| **sutui-minimax-tts** | hexiaochun | MiniMax | 多人对话语音合成、角色匹配 | ⭐⭐⭐⭐⭐ |
| **groq-orpheus-tts** | eid33552-maker | Groq Orpheus | 免费100次/天、阿拉伯语+英语 | ⭐⭐⭐ |
| **tts** | amstko | Hume AI / OpenAI | 基础 TTS | ⭐⭐ |
| **comfyui-tts** | yhsi5358 | 本地 ComfyUI | 本地 TTS | ⭐⭐ |

#### 与 aivp-audio 对比

| 维度 | 竞品亮点 | aivp-audio |
|------|---------|-----------|
| **TTS 深度** | odrobnik/elevenlabs：audio tags、声音管理、多格式 | 基础 text-to-speech.sh |
| **音乐生成** | elevenlabs-music：完整音乐生成 | text-to-music.sh（较简） |
| **声音克隆** | minimax-audio：声音克隆+音色设计 | 无 |
| **多人对话** | sutui-minimax-tts：多角色自动匹配+合成 | 无 |
| **STT** | elevenlabs-stt：说话人分离+事件标注 | speech-to-text.sh 基础 |

---

### 2.4 内容创作/剧本类

| Skill | 作者 | 功能 | 关键特性 | 质量 |
|-------|------|------|----------|------|
| **novel-to-script** | hexiaochun | 小说转剧本 | 标准漫剧格式、四段式节奏、情绪承诺 | ⭐⭐⭐⭐⭐ |
| **storyboard-generator** | hexiaochun | 分镜表生成 | 导演三帧法、镜头表+静帧提示词 | ⭐⭐⭐⭐⭐ |
| **tcm-video-factory** | xaotiensinh-abm | 健康视频生产计划 | Perplexity API 调研、脚本+角色+图像/视频提示词 | ⭐⭐⭐⭐ |
| **brand-story-video** (系列) | hhhh124hhhh | Sora2 视频提示词模板 | 品牌故事/产品展示/营销推广等 15+ 模板 | ⭐⭐⭐ |

#### 与 aivp-script / aivp-storyboard 对比

| 维度 | 竞品亮点 | aivp-script / aivp-storyboard |
|------|---------|------------------------------|
| **剧本格式** | novel-to-script：标准漫剧格式、情绪承诺、续看机制 | 通用 JSON 格式 |
| **分镜深度** | storyboard-generator：三帧法、资产库引用、提示词三段式 | 通用 shot-list 格式 |
| **端到端示例** | tcm-video-factory：从调研到提示词完整流程 | 依赖 pipeline 编排 |
| **模板丰富度** | hhhh124hhhh：15+ 场景模板 | 无预设模板 |

---

### 2.5 视频编辑/后期类

| Skill | 作者 | 功能 | 关键特性 | 质量 |
|-------|------|------|----------|------|
| **ffmpeg-master** | liudu2326526 | FFmpeg 百科 | 全面的 FFmpeg 操作指南、滤镜、硬件加速 | ⭐⭐⭐⭐ |
| **insaiai-intelligent-editing** | liudu2326526 | FFmpeg 编辑 | 与 ffmpeg-master 高度重复 | ⭐⭐⭐ |
| **remotion** (best-practices) | am-will | Remotion 视频框架 | 完整的 Remotion 知识库、40+ 规则文件 | ⭐⭐⭐⭐⭐ |
| **remotion-excalidraw-tts** | jack4world | Remotion + Excalidraw + TTS | Excalidraw 图→TTS→MP4、多 TTS 后端、storyboard JSON | ⭐⭐⭐⭐⭐ |

#### 与 aivp-edit 对比

| 维度 | 竞品亮点 | aivp-edit |
|------|---------|----------|
| **FFmpeg 深度** | ffmpeg-master：百科全书式参考 | 聚焦核心操作（concat/mix/subtitle/trim） |
| **程序化视频** | remotion：React 驱动、丰富动画、字幕 | 纯 FFmpeg 流程 |
| **端到端渲染** | remotion-excalidraw-tts：图+TTS→MP4 一键 | 需配合多个 skill |

---

### 2.6 端到端 Pipeline / Workflow 类

| Skill | 作者 | 功能 | 关键特性 | 质量 |
|-------|------|------|----------|------|
| **ai-video-gen** | hhhh124hhhh | 端到端视频生成 | DALL-E/Replicate/LumaAI/Runway + TTS + FFmpeg | ⭐⭐⭐⭐ |
| **remotion-excalidraw-tts** | jack4world | 图解视频 pipeline | Excalidraw→TTS→Remotion→MP4 | ⭐⭐⭐⭐⭐ |
| **tcm-video-factory** | xaotiensinh-abm | 健康视频工厂 | 调研→脚本→角色→提示词（半自动） | ⭐⭐⭐⭐ |
| **prompts-workflow** | hhhh124hhhh | 提示词自动化工作流 | 收集→转换→发布（非视频，但展示了编排模式） | ⭐⭐⭐ |

**关键发现：目前 ClaWHub 上没有真正完整的端到端视频制作 pipeline skill。**

最接近的是：
1. **ai-video-gen**（hhhh124hhhh）：有完整 pipeline 概念（图像→视频→TTS→编辑），但实现较简陋
2. **remotion-excalidraw-tts**（jack4world）：针对特定场景（图解视频）的完整 pipeline，质量最高
3. **tcm-video-factory**：针对健康视频的半自动 pipeline（只到提示词阶段，不生成视频）

hexiaochun 系列虽然模型覆盖最全，但**每个 skill 是独立的单点工具，没有 pipeline 编排层**。

#### 与 aivp-pipeline 对比

| 维度 | 竞品最佳 | aivp-pipeline |
|------|---------|--------------|
| **完整度** | ai-video-gen 有完整脚本但粗糙 | 定义了完整 10 步工作流 |
| **模块化** | 各竞品互相独立 | 10 个 skill 标准化互操作 |
| **灵活性** | 固定流程 | agent 按需决定步骤 |
| **数据流** | 无标准约定 | 项目结构 + 数据流约定 |
| **脚本质量** | remotion-excalidraw-tts 最好 | 每个 skill 有独立脚本 |

---

### 2.7 辅助工具类

| Skill | 作者 | 功能 | 与 aivp 关系 |
|-------|------|------|-------------|
| **parse-video** | hexiaochun | 多平台视频链接解析/下载 | aivp-ideation 可参考（竞品分析） |
| **gemini-yt-video-transcript** | odrobnik | YouTube 视频转文字 | aivp-ideation 可参考（内容分析） |
| **fashion-studio** | hexiaochun | 电商服装详情页一站式生成 | 垂直场景 pipeline 参考 |
| **xiaohongshu-publisher** | yuf1011 | 小红书发布 | aivp-publish 可参考 |
| **markdown-to-social** | hugosbl | Markdown→社媒内容 | aivp-publish 可参考 |

---

## 三、fal.ai 生态分析

fal.ai 是 ClaWHub 上最主流的 AI 模型后端，多个作者围绕它构建了不同层次的 skill：

| 层次 | 代表 Skill | 说明 |
|------|-----------|------|
| **通用接口层** | apekshik/fal | search/run 1000+ 模型的通用客户端 |
| **API 封装层** | agmmnn/fal-api | Python 封装，queue-based |
| **专项应用层** | delorenj/fal-text-to-image | 专注图像生成/编辑，三模式 |
| **单模型层** | hexiaochun/seedance-video 等 | 每个模型独立 skill + 详细文档 |
| **商业化层** | hexiaochun/add-fal-model 等 | 模型注册、成本审计、CDN 管理 |

**启示**：aivp-video 和 aivp-image 的 `generate.sh` 脚本设计类似通用接口层（apekshik/fal），但缺少专项应用层的深度文档和商业化层的运营工具。

---

## 四、hexiaochun（速推AI）深度分析

hexiaochun 是我们最大的"竞品"，值得深入分析：

### 优势
1. **模型覆盖广**：32 个 skill 覆盖视频(8)、图像(6)、音频(4)、工具(8)、应用(6)
2. **文档质量高**：每个 skill 有详细的参数表、定价表、示例代码
3. **商业闭环**：积分体系 + 成本审计 + CDN 管理 + 前端设计
4. **内容创作工具链**：小说转剧本 → 分镜表 → 角色创建 → 视频生成
5. **MCP 统一接口**：所有 skill 使用统一的 `submit_task`/`get_task` 模式

### 劣势
1. **无独立脚本**：所有 skill 依赖速推AI MCP 后端，离开平台无法使用
2. **无 pipeline 编排**：每个 skill 独立，无跨 skill 数据流约定
3. **平台锁定**：深度绑定速推AI积分系统
4. **无开源实现**：SKILL.md 只是 API 文档，没有可执行代码
5. **无视频后期**：没有 FFmpeg 编辑、字幕、合成相关 skill

---

## 五、总结与对 aivp 系列的启发

### 5.1 aivp 系列的核心优势

1. **唯一的端到端 pipeline**：ClaWHub 上没有任何竞品提供类似 aivp-pipeline 的完整 10 步编排
2. **模块化 + 独立可执行**：每个 skill 有独立的 bash 脚本，不依赖特定后端
3. **标准化数据流**：项目结构约定使 skill 间可以互操作
4. **agent 驱动**：不硬编码流程，由 agent 根据需求灵活编排

### 5.2 需要补强的方向

| 优先级 | 方向 | 参考竞品 | 建议 |
|--------|------|---------|------|
| 🔴 高 | **模型文档深度** | hexiaochun 系列 | 为每个支持的模型添加详细的参数表、定价信息、最佳实践 |
| 🔴 高 | **口型同步/动作迁移** | omnihuman-video, dreamactor-video | 考虑添加 aivp-lipsync 或集成到 aivp-video |
| 🔴 高 | **声音克隆/多人对话** | minimax-audio, sutui-minimax-tts | aivp-audio 应支持声音克隆和角色化 TTS |
| 🟡 中 | **角色一致性系统** | character-creator, seedance ref-to-video | 在 aivp-image 中加入角色参考图管理 |
| 🟡 中 | **分镜表深度** | storyboard-generator | aivp-storyboard 可借鉴三帧法和提示词三段式 |
| 🟡 中 | **剧本格式标准化** | novel-to-script | aivp-script 可加入漫剧/短剧专用格式 |
| 🟡 中 | **预设模板库** | nano-hub, brand-story-video 系列 | 为常见视频类型提供开箱即用的模板 |
| 🟢 低 | **视频链接解析** | parse-video | aivp-ideation 可集成竞品视频分析 |
| 🟢 低 | **图像模型评估** | image-model-evaluation | 为模型选择提供自动化评估工具 |
| 🟢 低 | **Remotion 集成** | remotion-excalidraw-tts | 考虑 aivp-edit 支持 Remotion 作为渲染后端 |

### 5.3 关键差异化机会

1. **真正的端到端 pipeline 是唯一蓝海**  
   ClaWHub 上没有任何竞品实现了从创意→脚本→分镜→生成→编辑→审核→发布的完整流程。aivp-pipeline 是独一无二的。应**大力宣传这一差异化优势**。

2. **开源可执行 vs 平台锁定**  
   hexiaochun 系列虽然文档好，但完全依赖速推AI后端。aivp 的独立 bash 脚本是重要优势——用户可以直接 fork 修改，不被任何平台锁定。

3. **agent-native 编排 vs 固定流程**  
   aivp-pipeline 的"agent 决定步骤"设计哲学是领先的。竞品要么是固定流程，要么是完全独立的单点工具。

4. **缺失的中间件**  
   在"生成"和"编辑"之间，缺少**素材管理/资产库**的概念。hexiaochun 的 cdn-url-transfer 和 upload-to-catbox 暗示了这个需求。考虑增加 `aivp-assets` skill 管理项目内的图片/视频/音频资产。

### 5.4 竞品生态全景图

```
                    ClaWHub AI 视频制作生态
                    
┌──────────────────────────────────────────────────────┐
│  创意/策划                                             │
│  ├── aivp-ideation ★唯一                              │
│  └── tcm-video-factory (单一垂直场景)                   │
├──────────────────────────────────────────────────────┤
│  脚本/分镜                                             │
│  ├── aivp-script + aivp-storyboard ★模块化            │
│  ├── novel-to-script (hexiaochun) - 漫剧专精           │
│  └── storyboard-generator (hexiaochun) - 三帧法        │
├──────────────────────────────────────────────────────┤
│  图像生成                                              │
│  ├── aivp-image ★通用接口                              │
│  ├── hexiaochun 系列 (6+ 模型) - 最全模型覆盖           │
│  ├── fal-text-to-image (delorenj) - 最佳图像 skill     │
│  └── comfyui-imagegen (halr9000) - 本地方案            │
├──────────────────────────────────────────────────────┤
│  视频生成                                              │
│  ├── aivp-video ★通用接口                              │
│  ├── hexiaochun 系列 (8+ 模型) - 最全模型覆盖           │
│  └── grok-imagine-video - xAI 方案                     │
├──────────────────────────────────────────────────────┤
│  音频/TTS                                              │
│  ├── aivp-audio ★pipeline 集成                         │
│  ├── elevenlabs (odrobnik) - 最完善 TTS                │
│  ├── minimax-audio/tts (hexiaochun) - 多人对话          │
│  └── elevenlabs-music - 音乐生成                       │
├──────────────────────────────────────────────────────┤
│  后期编辑                                              │
│  ├── aivp-edit ★pipeline 集成                          │
│  ├── ffmpeg-master - FFmpeg 百科                       │
│  └── remotion 系列 - React 视频                        │
├──────────────────────────────────────────────────────┤
│  质量审核                                              │
│  └── aivp-review ★唯一                                 │
├──────────────────────────────────────────────────────┤
│  发布                                                  │
│  ├── aivp-publish ★pipeline 集成                       │
│  └── xiaohongshu-publisher - 单平台                    │
├──────────────────────────────────────────────────────┤
│  端到端 Pipeline                                       │
│  ├── aivp-pipeline ★★★ 唯一完整方案 ★★★                │
│  ├── ai-video-gen (hhhh124hhhh) - 简陋但有概念          │
│  └── remotion-excalidraw-tts - 特定场景完整             │
└──────────────────────────────────────────────────────┘
```

### 5.5 行动建议

1. **短期（1-2周）**
   - 在 aivp-video SKILL.md 中添加主流模型的详细文档（Seedance, Sora 2, Hailuo, Wan）
   - 在 aivp-audio SKILL.md 中添加多人对话 TTS 能力说明
   - 发布 aivp-pipeline 到 ClaWHub，抢占"端到端视频pipeline"定位

2. **中期（1-2月）**
   - 添加 aivp-lipsync skill（口型同步/音频驱动视频）
   - 增强 aivp-storyboard（三帧法、角色一致性）
   - 添加 aivp-assets skill（素材管理）

3. **长期**
   - 构建视频模板库（参考 hhhh124hhhh 的模板系列）
   - 考虑 Remotion 集成为高级渲染选项
   - 声音克隆和角色化 TTS 系统

---

*报告结束。调研基于 2026-02-21 ClaWHub 本地仓库快照和公开信息。*
