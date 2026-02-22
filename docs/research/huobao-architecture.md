# Huobao Drama — 架构深度分析报告

> **项目定位**: AI 驱动的短剧自动化生产平台，覆盖 剧本→角色→分镜→图像→视频→合成 全链路。
>
> **技术栈**: Go 1.23 (Gin + GORM) + Vue 3 (Vite + Element Plus + Pinia)
>
> **分析日期**: 2026-02-22

---

## 目录

1. [项目总览与目录结构](#1-项目总览与目录结构)
2. [DDD 领域模型设计](#2-ddd-领域模型设计)
3. [完整 Pipeline 数据流](#3-完整-pipeline-数据流)
4. [AI 集成架构](#4-ai-集成架构)
5. [分镜脚本数据结构](#5-分镜脚本数据结构)
6. [Prompt 工程体系](#6-prompt-工程体系)
7. [前端架构](#7-前端架构)
8. [架构评价与改进建议](#8-架构评价与改进建议)

---

## 1. 项目总览与目录结构

### 1.1 分层架构

```
huobao-drama/
├── api/                    # 接口层 (HTTP Handler + Middleware + Routes)
│   ├── handlers/           #   17 个 Handler 文件
│   ├── middlewares/        #   Logger / CORS / RateLimit
│   └── routes/             #   路由注册 (/api/v1)
├── application/            # 应用服务层 (编排/协调)
│   └── services/           #   19 个 Service 文件
├── domain/                 # 领域层 (纯业务模型)
│   └── models/             #   10+ 个领域模型
├── infrastructure/         # 基础设施层
│   ├── database/           #   GORM 初始化 (SQLite/MySQL)
│   ├── storage/            #   本地文件存储
│   ├── external/           #   FFmpeg 集成
│   └── scheduler/          #   定时任务
├── pkg/                    # 共享工具包
│   ├── ai/                 #   LLM 客户端 (OpenAI, Gemini)
│   ├── image/              #   图像生成客户端 (DALL-E, VolcEngine, Gemini)
│   ├── video/              #   视频生成客户端 (Sora, MiniMax, ChatFire, VolcesArk)
│   ├── config/             #   配置管理 (Viper)
│   ├── logger/             #   日志 (Zap)
│   ├── utils/              #   JSON 解析 / 图像工具
│   └── response/           #   API 响应格式
├── web/                    # Vue 3 前端
├── cmd/migrate/            # 数据迁移工具
├── configs/                # 配置文件模板
├── migrations/             # SQL 迁移脚本
├── main.go                 # 入口
├── Dockerfile              # 三阶段构建
└── docker-compose.yml
```

### 1.2 技术选型

| 层次 | 技术 | 备注 |
|------|------|------|
| HTTP 框架 | Gin | 轻量级，高性能 |
| ORM | GORM | 支持 SQLite + MySQL |
| 数据库 | SQLite (WAL) / MySQL | 默认 SQLite，无需 CGO |
| 前端框架 | Vue 3.4 + TypeScript | Composition API |
| UI 库 | Element Plus + Tailwind CSS 4 | |
| 状态管理 | Pinia | |
| 构建工具 | Vite 5 | |
| 国际化 | vue-i18n (中/英/日) | |
| 视频处理 | FFmpeg (服务端) + FFmpeg.wasm (浏览器) | |
| 容器化 | Docker 多阶段构建 | Node → Go → Alpine |

---

## 2. DDD 领域模型设计

### 2.1 聚合根与实体关系图

```
Drama (聚合根 / 剧本项目)
│
├── Episodes[] (章节/集)
│   ├── ScriptContent          ← 剧本原文
│   ├── Storyboards[] (分镜)
│   │   ├── Characters[] (M2M) ← 出场角色
│   │   ├── Props[] (M2M)      ← 出场道具
│   │   ├── Background → Scene ← 场景背景
│   │   ├── FramePrompts[]     ← 帧级提示词
│   │   ├── ImageGeneration    ← 生成的图像
│   │   └── VideoGeneration    ← 生成的视频
│   ├── Scenes[] (场景/背景)
│   │   └── ImageGeneration    ← 场景背景图
│   └── Characters[] (M2M)     ← 本集角色
│
├── Characters[] (角色)
│   ├── ImageGeneration        ← 角色立绘
│   └── CharacterLibrary       ← 模板引用
│
├── Scenes[] (剧本级场景)
│
├── Props[] (道具)
│   └── ImageGeneration        ← 道具图
│
└── Timelines[] (时间线/合成)
    └── Tracks[]
        └── Clips[]
            ├── → Asset
            ├── → Storyboard
            ├── Transitions[]
            └── Effects[]
```

### 2.2 核心实体详解

#### Drama (剧本 — 聚合根)

```go
type Drama struct {
    ID            uint
    Title         string           // 标题
    Description   *string
    Genre         *string          // 类型 (悬疑/爱情/...)
    Style         string           // 画风 (realistic/ghibli/pixel/...)
    TotalEpisodes int
    TotalDuration int              // 秒，所有集时长之和
    Status        string           // draft → planning → production → completed → archived
    Tags          datatypes.JSON
    Metadata      datatypes.JSON   // 存储进度信息 (current_step, step_data)

    // 聚合边界
    Episodes   []Episode
    Characters []Character
    Scenes     []Scene
    Props      []Prop
}
```

**领域不变量**: Status 只能单向流转；TotalDuration 是计算值。

#### Episode (章节/集)

```go
type Episode struct {
    ID            uint
    DramaID       uint
    EpisodeNum    int
    Title         string
    ScriptContent *string          // 完整剧本文本
    Duration      int              // = Σ(Storyboard.Duration)
    Status        string           // draft → processing → completed
    VideoURL      *string          // 最终合成视频

    Storyboards   []Storyboard
    Characters    []Character      // M2M
    Scenes        []Scene
}
```

#### Storyboard (分镜/镜头 — 核心实体)

```go
type Storyboard struct {
    ID               uint
    EpisodeID        uint
    SceneID          *uint          // 引用场景背景
    StoryboardNumber int            // 序号

    // 叙事要素
    Title       *string             // 3-5 字摘要 (如 "噩梦惊醒")
    Location    *string             // 地点描述 (≥20 字)
    Time        *string             // 时间 + 光线 (≥15 字)
    ShotType    *string             // 景别: 远景|全景|中景|近景|特写
    Angle       *string             // 角度: 平视|仰视|俯视|侧面|背面
    Movement    *string             // 运镜: 固定|推|拉|摇|跟|移
    Action      *string             // 动作描述 (≥25 字)
    Result      *string             // 动作结果 (≥25 字)
    Atmosphere  *string             // 氛围 (≥20 字)
    Dialogue    *string             // 对白/独白
    Description *string             // 综合描述

    // AI 生成用提示词
    ImagePrompt *string             // 首帧静态构图
    VideoPrompt *string             // 运动视频描述
    BgmPrompt   *string             // 配乐提示
    SoundEffect *string             // 音效描述

    Duration      int               // 时长 (4-12 秒)
    ComposedImage *string           // 合成图 URL
    VideoURL      *string           // 生成视频 URL
    Status        string            // pending → generating → completed | failed

    // 关系
    Characters []Character          // M2M
    Props      []Prop               // M2M
    Background *Scene               // FK
}
```

#### Character (角色)

```go
type Character struct {
    ID              uint
    DramaID         uint
    Name            string
    Role            *string          // 角色身份
    Description     *string
    Appearance      *string          // 外貌描述
    Personality     *string          // 性格
    VoiceStyle      *string          // 语音风格
    ImageURL        *string          // 角色图
    ReferenceImages datatypes.JSON   // 参考图列表
    SeedValue       *string          // 视觉一致性种子
    SortOrder       int
}
```

**关键设计**: `SeedValue` 确保同一角色在多次生成中保持视觉一致性。

#### Scene (场景)

```go
type Scene struct {
    ID              uint
    DramaID         uint
    EpisodeID       *uint            // 可选：集级别或剧本级别
    Location        string
    Time            string
    Prompt          string           // AI 生成提示词
    StoryboardCount int              // 被多少分镜引用
    ImageURL        *string
    Status          string           // pending → generated | failed
}
```

#### Timeline (时间线/非线性编辑)

```go
type Timeline struct {
    ID         uint
    DramaID    uint
    EpisodeID  *uint
    Name       string
    Duration   int                   // 秒
    FPS        int                   // 默认 30
    Resolution *string              // 如 "1920x1080"
    Status     TimelineStatus       // draft → editing → completed → exporting
    Tracks     []TimelineTrack
}

type TimelineTrack struct {
    Type   TrackType               // video | audio | text
    Order  int
    Clips  []TimelineClip
}

type TimelineClip struct {
    AssetID      *uint
    StoryboardID *uint
    StartTime    int                // 毫秒
    EndTime      int
    Speed        *float64           // 变速
    FadeIn       *int               // 淡入 (ms)
    FadeOut      *int               // 淡出 (ms)
    Effects      []ClipEffect       // filter|color|blur|brightness|contrast|saturation
    Transitions  []ClipTransition   // fade|crossfade|slide|wipe|zoom|dissolve
}
```

### 2.3 多对多关系

| 关系表 | 左表 | 右表 | 说明 |
|--------|------|------|------|
| `storyboard_characters` | Storyboard | Character | 分镜出场角色 |
| `storyboard_props` | Storyboard | Prop | 分镜出场道具 |
| `episode_characters` | Episode | Character | 本集角色 |

### 2.4 状态机

```
Drama:     draft → planning → production → completed → archived
Episode:   draft → processing → completed
Storyboard: pending → generating → completed | failed
ImageGen:  pending → processing → completed | failed
VideoGen:  pending → processing → completed | failed
Timeline:  draft → editing → completed → exporting
AsyncTask: pending → processing → completed | failed  (Progress: 0-100%)
```

---

## 3. 完整 Pipeline 数据流

### 3.1 六阶段 Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                     HUOBAO DRAMA PIPELINE                          │
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │ Stage 1  │    │ Stage 2  │    │ Stage 3  │    │ Stage 4  │      │
│  │ 剧本输入  │───→│ 角色提取  │───→│ 分镜拆解  │───→│ 图像生成  │      │
│  │ Script   │    │Character │    │Storyboard│    │ Image    │      │
│  │ Input    │    │Extraction│    │Breakdown │    │Generation│      │
│  └──────────┘    └──────────┘    └──────────┘    └────┬─────┘      │
│                                                       │             │
│                                       ┌───────────────┘             │
│                                       ▼                             │
│                               ┌──────────┐    ┌──────────┐         │
│                               │ Stage 5  │    │ Stage 6  │         │
│                               │ 视频生成  │───→│ 合成剪辑  │         │
│                               │ Video    │    │ Compose  │         │
│                               │Generation│    │ & Merge  │         │
│                               └──────────┘    └──────────┘         │
└─────────────────────────────────────────────────────────────────────┘
```

### Stage 1: 剧本输入

- 用户创建 Drama，填写标题、描述、类型、画风
- 输入或 AI 生成 Episode 的剧本文本 (`ScriptContent`)
- **服务**: `DramaService.CreateDrama()`

### Stage 2: 角色提取

- AI 从剧本中识别并提取角色信息
- 生成角色描述、外貌、性格等结构化数据
- 可选：基于角色描述生成角色立绘
- **服务**: `ScriptGenerationService.GenerateCharacters()`
- **AI 调用**: LLM (OpenAI/Gemini) + 图像生成 (DALL-E/VolcEngine)
- **输出**: Character 记录集合

### Stage 3: 分镜拆解 (核心)

- 将剧本文本拆解为完整的分镜序列
- **输入**: Episode.ScriptContent + 已有 Characters + Scenes
- **处理**:
  1. `StoryboardService.GenerateStoryboard(episodeID, model)`
  2. 构建 System Prompt (Robert McKee 叙事理论 + 技术约束)
  3. 构建 User Prompt (剧本 + 角色列表 + 场景列表)
  4. AI 返回 JSON 数组 → 解析 → 持久化
  5. 为每个分镜生成 ImagePrompt 和 VideoPrompt
  6. 关联 Characters、Props、Scene
  7. 计算 Episode.Duration = Σ(Storyboard.Duration)
- **输出**: Storyboard[] (带完整元数据和提示词)

**AI 返回的分镜 JSON 格式**:
```json
{
  "storyboards": [
    {
      "shot_number": 1,
      "title": "噩梦惊醒",
      "location": "废弃码头仓库·锈蚀货架林立·地面散落碎玻璃",
      "time": "深夜22:30·月光从破窗斜射·冷白色光柱切割黑暗",
      "shot_type": "全景",
      "angle": "俯视45度角",
      "movement": "固定镜头",
      "action": "陈峥弯腰双手握住撬棍用力撬动保险箱门...",
      "dialogue": "（独白）这么多年了，终于找到了...",
      "result": "保险箱门突然弹开，烟尘飞扬...",
      "atmosphere": "昏暗冷色调·青灰色为主·远处有微弱灯光",
      "emotion": "好奇感↑↑转失望↓",
      "duration": 9,
      "bgm_prompt": "低沉紧张的弦乐...",
      "sound_effect": "金属碰撞声、灰尘飘散声",
      "characters": [159, 160],
      "scene_id": 1,
      "is_primary": true
    }
  ]
}
```

### Stage 4: 图像生成

- 基于分镜的 ImagePrompt 生成首帧图像
- **服务**: `ImageGenerationService.GenerateImage()`
- **参考图机制**: 支持角色/场景参考图保持一致性
- **帧类型**: first (首帧) | key (关键帧) | last (尾帧) | panel (分格) | action (动作序列)
- **异步处理**: 返回 task_id → 后台轮询 → 60 次 × 5 秒 = 5 分钟超时
- **输出**: ImageGeneration 记录 (image_url + local_path)

### Stage 5: 视频生成

- 基于生成的图像 + VideoPrompt 生成动态视频
- **服务**: `VideoGenerationService.GenerateVideo()`
- **参考模式**:
  - `single`: 单张图片动画化
  - `first_last`: 首尾帧插值
  - `multiple`: 多参考图序列
  - `none`: 纯文本生成视频
  - `action_sequence`: 3×3 九宫格分镜动画
- **异步处理**: 300 次 × 10 秒 = 50 分钟超时
- **后处理**: FFmpeg 探测实际视频时长
- **输出**: VideoGeneration 记录 (video_url)

### Stage 6: 合成剪辑

- 将所有分镜视频按序合并为完整集视频
- **服务**: `VideoMergeService` + `StoryboardCompositionService`
- **Timeline 模型**: 多轨道 (视频/音频/文字) + 转场 + 特效
- **输出**: 最终合成视频 (Episode.VideoURL)

### 3.2 异步任务模型

所有 AI 生成操作采用统一的异步任务模型:

```go
type AsyncTask struct {
    ID          string      // UUID
    Type        string      // storyboard_generation | image_generation | video_generation
    Status      string      // pending → processing → completed | failed
    Progress    int         // 0-100
    Message     string      // 当前状态消息
    Error       string      // 错误详情
    Result      string      // JSON 结果数据
    ResourceID  string      // 关联资源 ID
    CompletedAt *time.Time
}
```

**流程**: API 请求 → 创建 AsyncTask → 返回 task_id → goroutine 后台处理 → 客户端轮询 `/api/v1/tasks/:task_id`

---

## 4. AI 集成架构

### 4.1 三层抽象

```
┌────────────────────────────────────────────────┐
│ Application Services                            │
│ (AIService / ImageGenerationService / ...)      │
│ 负责: 配置管理、提示词组装、结果处理              │
├────────────────────────────────────────────────┤
│ Client Interfaces                               │
│ AIClient / ImageClient / VideoClient            │
│ 负责: 统一抽象接口                               │
├────────────────────────────────────────────────┤
│ Provider Implementations                        │
│ OpenAI / Gemini / VolcEngine / MiniMax / ...    │
│ 负责: HTTP 调用、请求/响应适配                    │
└────────────────────────────────────────────────┘
```

### 4.2 AI 服务配置 (数据库驱动)

```go
type AIServiceConfig struct {
    ID            uint
    ServiceType   string   // text | image | video
    Provider      string   // openai | gemini | volcengine | doubao | chatfire
    Name          string
    BaseURL       string
    APIKey        string
    Model         ModelField  // 支持多模型 ([]string)
    Endpoint      string      // 自动推断或自定义
    QueryEndpoint string      // 查询端点 (异步任务状态)
    Priority      int         // 优先级越高越优先
    IsDefault     bool
    IsActive      bool
    Settings      string      // JSON 扩展配置
}
```

**路由策略**: 按 `Priority DESC, CreatedAt DESC` 选择默认配置；支持按模型名精确路由。

### 4.3 LLM 文本生成

| 提供商 | 客户端文件 | 特性 |
|--------|-----------|------|
| OpenAI | `pkg/ai/openai_client.go` (369 行) | 兼容所有 OpenAI 兼容 API；自动 max_tokens → max_completion_tokens 降级重试 |
| Gemini | `pkg/ai/gemini_client.go` (200 行) | System Instruction 支持；{model} 占位符替换 |

**请求结构**:
```go
type ChatCompletionRequest struct {
    Model       string
    Messages    []ChatMessage   // system + user messages
    Temperature float64
    MaxTokens   int
    TopP        float64
}
```

**重试策略**: OpenAI 客户端检测 `max_tokens` 参数错误时自动切换到 `max_completion_tokens`。

### 4.4 图像生成

| 提供商 | 客户端文件 | 模式 |
|--------|-----------|------|
| OpenAI/DALL-E | `pkg/image/openai_image_client.go` | 文生图 + 图生图 (参考图) |
| VolcEngine | `pkg/image/volcengine_image_client.go` | 异步任务制；多参考图 |
| Gemini | `pkg/image/gemini_image_client.go` | Gemini 图像生成 |

**接口**:
```go
type ImageClient interface {
    GenerateImage(prompt string, options ...ImageOption) (*ImageResult, error)
    GetTaskStatus(taskID string) (*ImageResult, error)
}
```

**参考图一致性**: 合成 prompt 中加入 `"**必须严格**遵守参考图内的内容元素"` 约束；支持 URL 和 base64 两种参考图传入方式。

### 4.5 视频生成

| 提供商 | 客户端文件 | 特性 |
|--------|-----------|------|
| VolcesArk (字节) | `pkg/video/volces_ark_client.go` | 首帧/尾帧/参考图模式 |
| OpenAI Sora | `pkg/video/openai_sora_client.go` | 现代视频生成 |
| MiniMax | `pkg/video/minimax_client.go` | |
| ChatFire | `pkg/video/chatfire_client.go` | OpenAI 兼容封装 |

**接口**:
```go
type VideoClient interface {
    GenerateVideo(prompt string, options ...VideoOption) (*VideoResult, error)
    GetTaskStatus(taskID string) (*VideoResult, error)
}
```

**参考图模式**:
- `single`: 单帧动画化 → 适合简单动作
- `first_last`: 首尾帧插值 → 适合有明确起止的动作
- `multiple`: 多帧参考 → 复杂运动
- `action_sequence`: 3×3 九宫格 → 用于动作分解

### 4.6 Base64 转换 Pipeline

```
输入 → 判断类型
├── 本地路径 (/static/ 或相对路径) → 读文件 → base64
├── HTTP/HTTPS URL → 下载 → base64
└── 已是 base64 → 直接透传
```

### 4.7 故障恢复

- `VideoGenerationService.RecoverPendingTasks()`: 服务重启时恢复中断的视频生成任务
- 轮询过程中检测手动取消 (数据库状态变更)
- 超时后写入详细错误信息到数据库

---

## 5. 分镜脚本数据结构

### 5.1 完整 Storyboard 字段规格

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| `storyboard_number` | int | 1-based 顺序 | 镜头序号 |
| `title` | string | 3-5 字 | 镜头摘要 (如 "初入废墟") |
| `location` | string | ≥20 字 | 详细地点 (含环境物件) |
| `time` | string | ≥15 字 | 时间 + 光线描述 |
| `shot_type` | enum | 远景\|全景\|中景\|近景\|特写 | 景别 |
| `angle` | enum | 平视\|仰视\|俯视\|侧面\|背面 | 镜头角度 |
| `movement` | enum | 固定\|推\|拉\|摇\|跟\|移 | 运镜方式 |
| `action` | string | ≥25 字 | 动作描述 (含肢体语言) |
| `dialogue` | string | - | 对白/独白 (原文保留) |
| `result` | string | ≥25 字 | 动作产生的视觉后果 |
| `atmosphere` | string | ≥20 字 | 光线、色调、声音环境 |
| `emotion` | string | - | 情绪标记 (↑↑↑ / ↑↑ / ↑ / → / ↓) |
| `duration` | int | 4-12 秒 | 镜头时长 |
| `image_prompt` | string | - | 首帧静态构图提示词 |
| `video_prompt` | string | - | 运动视频提示词 |
| `bgm_prompt` | string | - | 配乐描述 |
| `sound_effect` | string | - | 音效描述 |
| `characters` | int[] | - | 出场角色 ID 列表 |
| `scene_id` | int? | - | 引用场景 ID (可 null) |
| `is_primary` | bool | - | 是否为该场景主镜头 |

### 5.2 提示词生成规则

**ImagePrompt (首帧静态构图)**:
- 描述动作的起始瞬间 (非过程)
- 包含: 地点 + 光线 + 角色初始姿态 + 情绪
- 不描述运动过程

**VideoPrompt (运动视频)**:
- 描述完整动作过程
- 包含: 动作 + 对白 + 镜头运动 + 景别
- 面向视频生成模型优化

### 5.3 FramePrompt (帧级提示词)

```go
type FramePrompt struct {
    ID           uint
    StoryboardID uint
    FrameType    string   // first | key | last | panel | action
    Prompt       string   // 帧级提示词
    Description  *string
    Layout       *string  // horizontal_3 | grid_2x2 | grid_3x3
}
```

**帧类型语义**:
- `first`: 动作开始前的静态状态
- `key`: 最高张力/情感峰值的瞬间
- `last`: 动作完成后的最终状态
- `panel`: 漫画式 3 分格布局
- `action`: 3×3 九宫格动作分解 (9 帧逐步展开)

---

## 6. Prompt 工程体系

### 6.1 PromptI18n 服务

**文件**: `application/services/prompt_i18n.go` (938 行)

支持中英双语 Prompt 模板，基于 `config.App.Language` 动态切换。

### 6.2 分镜 System Prompt

基于 Robert McKee 叙事理论的分镜拆解指导:
- **动作单元划分原则**: 每个分镜 = 一个聚焦动作
- **景别标准**: 远景 (ELS) / 全景 (LS) / 中景 (MS) / 近景 (CU) / 特写 (ECU)
- **情绪强度标记**: ↑↑↑ (极强) / ↑↑ (强) / ↑ (中) / → (平) / ↓ (弱)
- **输出要求**: 纯 JSON 数组，无 markdown

### 6.3 画风系统

支持 9 种预设画风，每种有详细美学指令:

| 画风 | 关键词 | 美学特征 |
|------|--------|---------|
| `ghibli` | 吉卜力 | 水彩质感、高调色彩、田园风格 |
| `guoman` | 国漫 | 东方幻想、粒子特效、局部发光 |
| `wasteland` | 废土 | 硬线条、有限色板、高对比侧光 |
| `nostalgia` | 怀旧 | 90 年代日系动漫、胶片颗粒、暗淡柔色 |
| `pixel` | 像素 | 8/16-bit、有限色板、抖动逻辑 |
| `voxel` | 体素 | 3D 方块、电影级全局光照 |
| `urban` | 都市 | 现代条漫、霓虹色、边缘光 |
| `guoman3d` | 国漫3D | 次世代品质、PBR 渲染、东方美学 |
| `chibi3d` | Q版3D | 玩具质感、Q 版比例、写实材质 |

### 6.4 视频约束 Prompt

**通用约束**:
- 物理守恒 (质量守恒、运动惯性)
- 环境外推 (防止镜头移动时出现黑边)
- 运动连续性

**动作序列约束** (action_sequence 模式):
- 九宫格帧间插值规则
- 帧一致性约束 (角色外观、环境不变)

---

## 7. 前端架构

### 7.1 页面结构

```
web/src/views/
├── dashboard/          # 项目仪表盘
├── drama/              # 剧本管理与编辑
├── generation/         # 角色/资产生成
├── script/             # 脚本编辑器
├── storyboard/         # 分镜编辑器 (核心页面)
├── editor/             # 通用编辑器
├── workflow/           # 工作流管理
└── settings/           # 应用设置
```

### 7.2 API 模块

```
web/src/api/
├── drama.ts            # 剧本 CRUD
├── generation.ts       # 角色/脚本生成
├── image.ts            # 图像生成
├── video.ts            # 视频生成
├── character-library.ts # 角色库
├── asset.ts            # 资产管理
├── task.ts             # 异步任务轮询
├── frame.ts            # 帧提示词
├── ai.ts               # AI 配置
├── audio.ts            # 音频处理
├── videoMerge.ts       # 视频合并
├── prop.ts             # 道具
└── settings.ts         # 设置
```

### 7.3 关键组件

- `StoryboardEditor.vue` — 分镜可视化编辑器
- `GridImageEditor.vue` — 九宫格图像编辑
- `VideoTimelineEditor.vue` — 视频时间线编辑器
- `AIConfigDialog.vue` — AI 服务配置对话框
- `ImageCropDialog.vue` — 图片裁剪
- `CreateDramaDialog.vue` — 创建项目

---

## 8. 架构评价与改进建议

### 8.1 优点

1. **清晰的分层架构**: api → application → domain → infrastructure，职责分明
2. **灵活的 AI 提供商抽象**: 接口化设计，数据库驱动配置，易于扩展新提供商
3. **完整的异步处理体系**: 统一 AsyncTask 模型 + goroutine + 轮询，覆盖所有长时任务
4. **精细的 Prompt 工程**: 分镜拆解基于电影理论，多种帧类型和画风支持
5. **多语言支持**: 前后端均支持中/英/日三语
6. **零 CGO 依赖**: SQLite 使用纯 Go 实现 (modernc.org/sqlite)，简化部署
7. **参考图一致性机制**: SeedValue + 参考图约束确保角色视觉一致

### 8.2 可改进方向

1. **Repository 层缺失**: 当前 Service 直接操作 GORM，建议抽取 Repository 接口以提升可测试性
2. **Service 文件过大**: `image_generation_service.go` (1353 行)、`prompt_i18n.go` (938 行) 建议拆分
3. **缺少 Domain Event**: 状态流转依赖命令式调用，引入事件驱动可解耦 Pipeline 各阶段
4. **轮询改为 WebSocket/SSE**: 当前客户端轮询 AsyncTask，推送模式体验更好
5. **Pipeline 编排引擎**: 各阶段硬编码在 Service 方法中，可考虑引入 Workflow/State Machine 引擎
6. **缺少单元测试**: 仅 `json_parser_test.go` 一个测试文件，Service 层和 Domain 层测试覆盖不足
7. **错误域模型**: 当前错误以 string 存储在 ErrorMsg 字段，可定义领域错误类型

### 8.3 架构亮点总结

| 维度 | 评价 |
|------|------|
| 领域建模 | ★★★★☆ — Drama 聚合根设计合理，关系清晰 |
| AI 集成 | ★★★★★ — 多提供商、多模态、灵活配置 |
| Pipeline 设计 | ★★★★☆ — 完整覆盖全链路，异步处理成熟 |
| Prompt 工程 | ★★★★★ — 基于电影理论，9 种画风，帧级精控 |
| 代码组织 | ★★★☆☆ — 部分 Service 文件过大需拆分 |
| 可测试性 | ★★☆☆☆ — Repository 缺失，测试覆盖不足 |
| 部署 | ★★★★☆ — Docker 多阶段构建，配置完善 |

---

> **总结**: Huobao Drama 是一个架构设计成熟的 AI 短剧生产平台。其核心价值在于将影视制作的专业流程 (编剧→角色设计→分镜→拍摄→后期) 通过 DDD 建模和 AI 集成实现了全自动化。分镜拆解基于 Robert McKee 叙事理论，Prompt 体系精细到帧级别，9 种画风覆盖主流动漫/影视风格。多 AI 提供商的抽象设计使其能灵活对接 OpenAI、Gemini、字节跳动等国内外主流 AI 服务。
