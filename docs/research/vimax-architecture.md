# ViMax 架构深度分析报告

## 目录

1. [项目概览](#1-项目概览)
2. [Multi-Agent 编排模式](#2-multi-agent-编排模式)
3. [Script → Storyboard → Video 数据流](#3-script--storyboard--video-数据流)
4. [角色一致性保证机制](#4-角色一致性保证机制)
5. [Prompt 生成策略](#5-prompt-生成策略)
6. [并发编排与事件同步机制](#6-并发编排与事件同步机制)
7. [工具层抽象与可插拔设计](#7-工具层抽象与可插拔设计)
8. [Novel2Movie 扩展管线](#8-novel2movie-扩展管线)
9. [设计亮点与不足](#9-设计亮点与不足)

---

## 1. 项目概览

ViMax 是一个基于多 Agent 协作的端到端 AI 视频生成框架，核心理念是将影视制作的专业分工（编剧、分镜师、摄影师）映射为 LLM Agent，通过结构化的数据流水线将「创意」转化为「视频」。

### 技术栈

| 层级 | 技术选型 |
|------|---------|
| LLM 编排 | LangChain (ChatPromptTemplate, PydanticOutputParser) |
| 数据模型 | Pydantic v2 (BaseModel, Field, model_validate) |
| 图像生成 | Google Gemini 2.5 Flash Image / Doubao Seedream |
| 视频生成 | Google Veo 3.1 / Doubao Seedance |
| 视频处理 | MoviePy, OpenCV, PySceneDetect |
| 异步运行时 | asyncio (Event, Semaphore, gather) |
| 配置管理 | YAML + 动态类加载 (importlib) |

### 三条管线入口

```
main_idea2video.py  → Idea2VideoPipeline    (创意→故事→剧本→视频)
main_script2video.py → Script2VideoPipeline  (剧本→视频)
novel2movie_pipeline → Novel2MoviePipeline   (小说→电影, 未完成)
```

---

## 2. Multi-Agent 编排模式

### 2.1 Agent 角色定义

ViMax **没有**采用 Director/Screenwriter/Producer 的三角色模型。实际的 Agent 分工更接近影视工业中的**职能分工**：

| Agent | 角色类比 | 职责 | 输入 → 输出 |
|-------|---------|------|------------|
| `Screenwriter` | 编剧 | 故事发展 + 剧本编写 | Idea → Story → List[SceneScript] |
| `CharacterExtractor` | 选角导演 | 从剧本中提取角色信息 | Script → List[CharacterInScene] |
| `CharacterPortraitsGenerator` | 角色造型师 | 生成角色多角度肖像 | Character + Style → 前/侧/背三视图 |
| `StoryboardArtist` | 分镜师 | 设计分镜 + 分解视觉描述 | Script + Characters → Storyboard → ShotDescription |
| `CameraImageGenerator` | 摄影师/剪辑 | 构建摄影机树 + 生成转场 | Cameras + Shots → CameraTree + TransitionVideo |
| `ReferenceImageSelector` | 视觉指导 | 智能选择参考图 + 生成 prompt | AvailableImages + FrameDesc → SelectedRefs + TextPrompt |

### 2.2 编排模式：Pipeline-Orchestrated Agents（管线编排）

ViMax 的多 Agent 协作 **不是** 自主协商式（如 AutoGen），而是 **Pipeline 驱动的顺序+并行混合编排**：

```
Pipeline (编排者)
  │
  ├── 阶段1: Screenwriter.develop_story()          [顺序]
  ├── 阶段2: CharacterExtractor.extract_characters() [顺序]
  ├── 阶段3: CharacterPortraitsGenerator (并行生成多角色) [并行]
  ├── 阶段4: Screenwriter.write_script()             [顺序]
  ├── 阶段5: StoryboardArtist.design_storyboard()    [顺序]
  ├── 阶段6: StoryboardArtist.decompose_visual_description() [并行, 每个 shot]
  ├── 阶段7: CameraImageGenerator.construct_camera_tree() [顺序]
  ├── 阶段8: Frame Generation (并行, 按 Camera 分组, 事件同步) [并行+依赖]
  └── 阶段9: Video Generation (并行, 等待帧就绪事件)        [并行+依赖]
```

关键设计选择：
- **Agent 之间无直接通信**：所有 Agent 通过 Pipeline 的函数调用串联，不存在 Agent 间的消息传递
- **Pipeline 即编排者**：`Script2VideoPipeline.__call__()` 是核心编排函数，控制所有 Agent 的调用顺序和数据传递
- **无 LLM 决策的路由**：不使用 LLM 来决定下一步调用哪个 Agent，流程是硬编码的

### 2.3 Idea2Video 与 Script2Video 的嵌套关系

```
Idea2VideoPipeline
  ├── Screenwriter (故事+剧本)
  ├── CharacterExtractor
  ├── CharacterPortraitsGenerator
  └── for each scene_script:
        └── Script2VideoPipeline(scene_script)  ← 复用
              ├── StoryboardArtist
              ├── CameraImageGenerator
              ├── ReferenceImageSelector
              └── Image/Video Generators
```

`Idea2VideoPipeline` 负责「从创意到剧本」和「角色管理」，然后**按场景循环调用** `Script2VideoPipeline` 处理每个场景。角色肖像注册表 (`character_portraits_registry`) 作为全局共享状态，在场景间传递以保证角色一致性。

---

## 3. Script → Storyboard → Video 数据流

### 3.1 完整数据转换链路

```
[Input: Script(str)]
        │
        ▼
┌─────────────────────────────────────────┐
│ Stage 1: Character Extraction           │
│ CharacterExtractor.extract_characters() │
│                                         │
│ Script → List[CharacterInScene]         │
│   ├── idx: int                          │
│   ├── identifier_in_scene: str          │
│   ├── is_visible: bool                  │
│   ├── static_features: str (外貌/体型)  │
│   └── dynamic_features: str (服装/配饰) │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Stage 2: Character Portrait Generation  │
│ CharacterPortraitsGenerator             │
│                                         │
│ Character → 3张肖像图                    │
│   ├── front.png (正面全身像)             │
│   ├── side.png  (侧面全身像)             │
│   └── back.png  (背面全身像)             │
│                                         │
│ → character_portraits_registry (Dict)   │
│   { "Alice": {                          │
│       "front": {path, description},     │
│       "side":  {path, description},     │
│       "back":  {path, description}      │
│   }}                                    │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Stage 3: Storyboard Design              │
│ StoryboardArtist.design_storyboard()    │
│                                         │
│ Script + Characters → List[ShotBrief]   │
│                                         │
│ ShotBriefDescription:                   │
│   ├── idx: int          (镜头序号)       │
│   ├── is_last: bool     (是否最后一镜)   │
│   ├── cam_idx: int      (摄影机编号)     │
│   ├── visual_desc: str  (视觉描述)       │
│   └── audio_desc: str   (音频描述)       │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ Stage 4: Visual Description Decomposition       │
│ StoryboardArtist.decompose_visual_description() │
│ (并行处理每个 shot)                               │
│                                                 │
│ ShotBriefDescription → ShotDescription          │
│                                                 │
│ ShotDescription (核心中间格式):                    │
│   ├── idx, is_last, cam_idx                     │
│   ├── visual_desc: str       (原始视觉描述)       │
│   ├── variation_type: "large"|"medium"|"small"  │
│   ├── variation_reason: str  (变化原因)           │
│   ├── ff_desc: str           (首帧静态描述)        │
│   ├── ff_vis_char_idxs: []   (首帧可见角色)        │
│   ├── lf_desc: str           (末帧静态描述)        │
│   ├── lf_vis_char_idxs: []   (末帧可见角色)        │
│   ├── motion_desc: str       (运动描述)            │
│   └── audio_desc: str        (音频描述)            │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Stage 5: Camera Tree Construction       │
│ CameraImageGenerator.construct_camera_  │
│ tree()                                  │
│                                         │
│ ShotDescriptions → List[Camera]         │
│                                         │
│ Camera:                                 │
│   ├── idx: int                          │
│   ├── active_shot_idxs: List[int]       │
│   ├── parent_cam_idx: Optional[int]     │
│   ├── parent_shot_idx: Optional[int]    │
│   ├── is_parent_fully_covers_child: bool│
│   └── missing_info: Optional[str]       │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Stage 6: Frame Generation               │
│ (按 Camera 并行, 事件驱动同步)            │
│                                         │
│ 每个 Camera:                             │
│   1. 生成首个 shot 的 first_frame        │
│      (可能需要 transition video)         │
│   2. 按 priority 生成后续 shot 的帧      │
│                                         │
│ 输出: shots/{idx}/first_frame.png       │
│       shots/{idx}/last_frame.png        │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Stage 7: Video Generation               │
│ (等待帧事件 → 并行生成)                   │
│                                         │
│ 每个 Shot:                               │
│   ├── wait first_frame event            │
│   ├── wait last_frame event (if needed) │
│   ├── prompt = motion_desc + audio_desc │
│   └── video_generator.generate(         │
│         prompt, [ff, lf?])              │
│                                         │
│ 输出: shots/{idx}/video.mp4             │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Stage 8: Video Concatenation            │
│ MoviePy concatenate_videoclips()        │
│                                         │
│ 输出: final_video.mp4                   │
└─────────────────────────────────────────┘
```

### 3.2 核心中间格式：ShotDescription

`ShotDescription` 是整个管线最关键的中间数据格式，它是从「文本描述」到「视觉生成」的桥梁：

```python
class ShotDescription(BaseModel):
    # 定位信息
    idx: int                    # 镜头在时间线中的位置
    cam_idx: int                # 属于哪台摄影机
    is_last: bool               # 是否为最后一镜

    # 视觉描述 (文本 → 文本拆解)
    visual_desc: str            # 原始完整描述
    ff_desc: str                # 首帧快照描述 (纯静态)
    lf_desc: str                # 末帧快照描述 (纯静态)
    motion_desc: str            # 运动描述 (摄影机运动 + 画内运动)

    # 变化量化
    variation_type: "large"|"medium"|"small"
    variation_reason: str

    # 角色追踪
    ff_vis_char_idxs: List[int] # 首帧可见角色索引
    lf_vis_char_idxs: List[int] # 末帧可见角色索引

    # 音频
    audio_desc: str
```

**设计精妙之处**：将一段连续的镜头描述拆解为「首帧快照 + 末帧快照 + 运动指令」三元组。这完美匹配了底层视频生成模型（如 Veo）的 API 接口——Veo 支持 `first_frame image + last_frame image + prompt` 的输入格式。

### 3.3 variation_type 的分级策略

| 级别 | 含义 | 生成策略 |
|------|------|---------|
| `small` | 表情变化/姿态微调/轻微镜头运动 | **只生成 first_frame**，让视频模型自行补间 |
| `medium` | 新角色出现/角色转身 | 生成 first_frame + last_frame，视频模型基于两帧生成 |
| `large` | 大幅构图变化/景别跨越/无人机镜头 | 生成 first_frame + last_frame，视频模型基于两帧生成 |

这个设计直接影响了帧生成的工作量和最终视频质量。`small` 类型的 shot 跳过 last_frame 生成，节约了图像生成 API 的调用次数。

---

## 4. 角色一致性保证机制

角色一致性是 AI 视频生成中的核心挑战。ViMax 采用了**四层机制**来保证角色在不同镜头间的视觉一致性：

### 4.1 第一层：角色特征的结构化提取

```python
class CharacterInScene(BaseModel):
    static_features: str   # 不变特征：面部、体型、发型
    dynamic_features: str  # 可变特征：服装、配饰
```

通过 `CharacterExtractor` Agent，LLM 将剧本中的角色描述拆解为 static/dynamic 两类特征。Prompt 中明确要求：
- "不同角色外貌应尽可能有辨识度"
- "描述应具体、可视化——使用具体的服装颜色和实体外貌特征"
- "不包含性格、角色关系等非视觉信息"

### 4.2 第二层：多角度角色肖像注册表

每个角色生成**三张标准肖像**（正面/侧面/背面），存入全局 `character_portraits_registry`：

```python
character_portraits_registry = {
    "Alice": {
        "front": {"path": "front.png", "description": "A front view portrait of Alice."},
        "side":  {"path": "side.png",  "description": "A side view portrait of Alice."},
        "back":  {"path": "back.png",  "description": "A back view portrait of Alice."},
    }
}
```

**生成顺序有讲究**：
1. 先用文字描述生成 `front.png`（唯一的纯文字→图像生成）
2. 用 `front.png` 作为参考图生成 `side.png`（图像→图像）
3. 用 `front.png` 作为参考图生成 `back.png`（图像→图像）

这保证了侧面和背面图与正面图在外貌/服装上的一致性。

### 4.3 第三层：ReferenceImageSelector 的智能选图

这是最精巧的一致性机制。在生成每一帧时，`ReferenceImageSelector` 执行**两轮筛选**：

```
Round 1: Text-Only Filtering (当候选图 >= 8 张时触发)
  ├── 输入: 候选图的文字描述 + 目标帧描述
  ├── 模型: 纯文本 LLM
  └── 输出: 粗筛后的参考图索引 (缩减到 < 8 张)

Round 2: Multimodal Selection (始终执行)
  ├── 输入: 候选图的实际图像 + 文字描述 + 目标帧描述
  ├── 模型: 多模态 LLM (Vision)
  └── 输出: {ref_image_indices, text_prompt}
```

选图的核心准则（来自 system prompt）：
- **角色一致性**：新角色出场时优先选其肖像图
- **视角匹配**：正面/侧面/背面肖像只选最匹配当前镜头角度的一张
- **环境一致性**：优先选同摄影机位的既有画面
- **时间优先级**：越新的帧权重越高（更接近当前时间线）
- **去重**：如果 Image 3 已包含 Bob 正面特征，则跳过 Image 1 的正面肖像

### 4.4 第四层：Camera Tree 的继承机制

```
Camera 0 (全景/主镜头) ─── Root
  ├── Camera 1 (中景) ─── 从 Camera 0 的 Shot 0 继承
  └── Camera 2 (特写) ─── 从 Camera 1 的 Shot 3 继承
```

Camera Tree 通过 LLM 分析镜头间的包含关系（父摄影机的画面包含子摄影机的内容），建立层级结构：

1. **Transition Video**：从父镜头的首帧画面生成一段「虚拟运镜」视频，模拟从父镜头视角过渡到子镜头视角
2. **Scene Detection**：用 PySceneDetect 检测过渡视频中的场景切换点，提取第二个场景的首帧作为新视角的参考图
3. **Missing Info 补充**：如果父镜头不能完全覆盖子镜头内容（如正面→侧面需要新的面部信息），`missing_info` 字段指引系统选择额外的参考图（角色肖像）来补充

```python
# camera_image_generator.py:276-285
available_image_path_and_text_pairs.append(
    (
        new_camera_image_path,
        f"The composition and background are correct but some elements may be wrong. "
        f"The wrong elements should be replaced.\n"
        f"Wrong elements: {camera.missing_info}.\n"
        f"You must select this image as the main reference and replace the characters "
        f"in the image with the provided character portraits. Don't change the background."
    )
)
```

### 4.5 一致性保证的总结视图

```
                    ┌──────────────────────────┐
                    │  Character Portraits      │
                    │  Registry (全局共享)       │
                    │  front/side/back × N chars│
                    └──────────┬───────────────┘
                               │
                               ▼
┌────────────┐    ┌──────────────────────────────┐    ┌────────────┐
│ Camera Tree │───→│  ReferenceImageSelector       │───→│ Image Gen  │
│ (空间一致性) │    │  (智能选图 + prompt 生成)      │    │ (最终图像)  │
└────────────┘    │  1. 角色肖像 (外貌一致)         │    └────────────┘
                  │  2. 同机位先前帧 (环境一致)      │
                  │  3. 父镜头过渡帧 (空间一致)      │
                  │  4. prompt 指引元素映射          │
                  └──────────────────────────────┘
```

---

## 5. Prompt 生成策略

### 5.1 Prompt 架构总览

ViMax 中每个 Agent 的 Prompt 都遵循统一的 `[Role]-[Task]-[Input]-[Output]-[Guidelines]` 五段式结构。

### 5.2 各 Agent 的 Prompt 策略

#### 5.2.1 Screenwriter — 故事生成

```
[Role] 创意故事生成专家 (6项核心技能)
[Task] 基于 Idea + Requirements 生成完整故事
[Input] <IDEA>...</IDEA> + <USER_REQUIREMENT>...</USER_REQUIREMENT>
[Output] 标题 + 受众/类型 + 摘要 + 角色介绍 + 完整叙事
[Guidelines] 以创意为核心 / 逻辑一致 / Show Don't Tell / 输出语言与输入一致
```

#### 5.2.2 Screenwriter — 剧本改编

```
使用 PydanticOutputParser 约束输出为:
class WriteScriptBasedOnStoryResponse(BaseModel):
    script: List[str]  # 每个元素是一个场景的完整剧本

关键约束:
- 时间/地点变化时切换场景
- 所有描述必须"可拍摄" (filmable)
- 用具体动作替代抽象情绪
```

#### 5.2.3 StoryboardArtist — 分镜设计

这是最复杂的 Prompt，包含精细的电影语言指导：

```
核心指导准则:
1. 每个镜头必须有明确叙事目的
2. 特写用于情绪，全景用于上下文
3. 优先复用现有摄影机位，只在景别/角度显著不同时引入新机位
4. 角色名用尖括号包裹: <Alice>
5. 必须标注元素在画面中的位置 (如"画面左侧")
6. 不可见元素不得描述
7. 每角色每镜头最多一句台词
8. 每个 shot 描述独立，不得相互引用
9. 聚焦角色时必须说明聚焦的具体身体部位
10. 必须指明角色面朝方向
```

#### 5.2.4 StoryboardArtist — 视觉描述分解

将一段镜头描述分解为三元组的 Prompt 策略：

```
ff_desc: 纯静态快照 (不允许进行时描述如 "He is about to stand up")
lf_desc: 反映运动结束后的最终静态状态
motion_desc:
  - 区分摄影机运动 (dolly, pan, zoom...) 和画内运动
  - 不能用角色名，必须用外貌特征指代 (Alice → "short hair, wearing a green dress")

variation_type 判定规则:
  large: 构图大幅变化 (如天空→地面的无人机穿越镜头)
  medium: 新角色出现 / 角色转身面向镜头
  small: 表情变化 / 姿态微调 / 轻微运镜
```

#### 5.2.5 CameraImageGenerator — 摄影机树构建

```
输入格式:
<CAMERA_SEQ>
  <CAMERA_0>
    Shot 0: Medium shot of ...
    Shot 2: Medium shot of ...
  </CAMERA_0>
  <CAMERA_1>
    Shot 1: Close-up of ...
  </CAMERA_1>
</CAMERA_SEQ>

输出: 每台摄影机的 parent_cam_idx + parent_shot_idx + missing_info

关键约束:
- 父子景别平滑过渡 (禁止全景→特写直接跳)
- 时间临近原则 (父 shot 索引尽可能接近子摄影机的首 shot)
- 无环 (DAG 结构)
- 第一台摄影机必须是根节点
- 比较父子镜头差异时要细致 (如中景双人侧面→特写正面，缺失正面信息)
```

#### 5.2.6 ReferenceImageSelector — 参考图选择 + Prompt 生成

这是唯一一个有**两版 Prompt** 的 Agent：

1. **Text-Only 版**：仅基于文字描述做粗筛（候选图 >= 8 张时）
2. **Multimodal 版**：传入实际图像做精选（始终执行）

输出的 `text_prompt` 是最终送入图像生成 API 的提示词，格式如：

```
Image 0: A front-view portrait of Alice.
Image 1: [Camera 0] Medium shot of the supermarket aisle...

Create an image based on the following guidance:
Make modifications based on Image 1: Bob's body turns to face the camera,
while all other elements remain unchanged. Bob's appearance should refer to Image 0.
```

### 5.3 Prompt → 结构化输出的机制

所有 Agent 都使用 LangChain 的 `PydanticOutputParser`：

```python
parser = PydanticOutputParser(pydantic_object=SomeResponseModel)
format_instructions = parser.get_format_instructions()
# format_instructions 自动生成 JSON Schema 描述，注入到 system prompt 的 {format_instructions}

chain = chat_model | parser
response: SomeResponseModel = await chain.ainvoke(messages)
```

这保证了 LLM 输出可以被直接解析为强类型的 Pydantic 模型，避免了手动解析 JSON 的脆弱性。

---

## 6. 并发编排与事件同步机制

### 6.1 asyncio.Event 驱动的帧-视频同步

`Script2VideoPipeline` 使用三类事件字典来协调并发任务：

```python
class Script2VideoPipeline:
    character_portrait_events = {}   # {char_idx: Event}
    shot_desc_events = {}            # {shot_idx: Event}
    frame_events = {}                # {shot_idx: {"first_frame": Event, "last_frame": Event}}
```

工作流程：

```
Frame Generation Tasks (per camera)        Video Generation Tasks (per shot)
─────────────────────────────              ──────────────────────────────
generate_frames_for_camera_0()  ───────→  generate_video_for_shot_0()
  └── frame_events[0]["ff"].set()    │      └── await frame_events[0]["ff"].wait()
                                     │      └── await frame_events[0]["lf"].wait() (if medium/large)
generate_frames_for_camera_1()  ───────→  generate_video_for_shot_1()
  └── await frame_events[parent].wait()│     └── ...
  └── frame_events[1]["ff"].set()    │
                                     │
         ← asyncio.gather(*all) →
```

**关键设计**：帧生成和视频生成任务通过 `asyncio.gather` 同时启动，但视频生成任务会 `await frame_events[shot_idx]["first_frame"].wait()` 阻塞等待，直到对应帧生成完毕。这实现了**无锁的生产者-消费者模式**。

### 6.2 Priority Task 调度

```python
# script2video_pipeline.py:188
priority_shot_idxs = [camera.parent_cam_idx for camera in camera_tree
                      if camera.parent_cam_idx is not None]

# 在 generate_frames_for_single_camera 中:
priority_tasks = []    # 被其他 camera 依赖的 shot
normal_tasks = []      # 无依赖的 shot

await asyncio.gather(*priority_tasks)   # 先完成优先任务
await asyncio.gather(*normal_tasks)     # 再完成普通任务
```

这确保了 Camera Tree 中被子摄影机依赖的父 shot 帧优先生成，避免子摄影机的转场视频生成被长时间阻塞。

### 6.3 断点续跑（Checkpoint/Resume）

几乎每个阶段都有文件检查逻辑：

```python
if os.path.exists(save_path):
    # 从文件加载已有结果，跳过计算
    data = json.load(f)
    print("Loaded from existing file.")
else:
    # 执行计算并保存
    data = await agent.do_work()
    json.dump(data, f)
```

这使得管线可以在任意阶段中断后恢复运行，无需重新计算已完成的步骤。对于视频生成这种耗时数小时的管线，这是必要的工程实践。

---

## 7. 工具层抽象与可插拔设计

### 7.1 图像/视频生成器的动态加载

```yaml
# configs/idea2video.yaml
image_generator:
  class_path: tools.ImageGeneratorNanobananaGoogleAPI
  init_args:
    api_key: ...
```

```python
# Pipeline 初始化时动态导入
cls_module, cls_name = config["image_generator"]["class_path"].rsplit(".", 1)
cls = getattr(importlib.import_module(cls_module), cls_name)
generator = cls(**config["image_generator"]["init_args"])
```

**可插拔实现**：
- `ImageGeneratorNanobananaGoogleAPI` — Google Gemini 图像生成
- `ImageGeneratorDoubaoSeedreamYunwuAPI` — 字节跳动豆包
- `ImageGeneratorNanobananaYunwuAPI` — 云雾 API
- `VideoGeneratorVeoGoogleAPI` — Google Veo 视频生成
- `VideoGeneratorVeoYunwuAPI` — 云雾 Veo
- `VideoGeneratorDoubaoSeedanceYunwuAPI` — 字节跳动豆包

### 7.2 Video Generator 的三种模式

`VideoGeneratorVeoGoogleAPI` 根据参考图数量自动选择模型：

```python
if len(reference_image_paths) == 0:
    model = self.t2v_model      # Text-to-Video
elif len(reference_image_paths) == 1:
    model = self.ff2v_model     # First-Frame-to-Video
    image = reference_image_paths[0]
elif len(reference_image_paths) == 2:
    model = self.flf2v_model    # First+Last-Frame-to-Video
    image = reference_image_paths[0]
    config["last_frame"] = reference_image_paths[1]
```

这与 `variation_type` 的分级策略完美配合：
- `small` → 1 张参考图 (ff2v) → 视频模型自行生成运动
- `medium`/`large` → 2 张参考图 (flf2v) → 视频模型在首末帧间插值

### 7.3 Rate Limiter

```python
class RateLimiter:
    max_requests_per_minute: Optional[int]
    max_requests_per_day: Optional[int]
```

- 基于 `asyncio.Lock` 的协程安全速率限制
- 支持 per-minute 和 per-day 两级限制
- 自动计算最小请求间隔 (`60.0 / max_rpm`)
- 三种服务独立限速：chat_model / image_generator / video_generator

---

## 8. Novel2Movie 扩展管线

`Novel2MoviePipeline` 是一个更复杂但未完成的管线，设计了 7 个步骤：

```
Step 1: Novel Compression (长文本压缩)
  └── NovelCompressor: split → compress_chunks → aggregate

Step 2: Event Extraction (事件提取)
  └── EventExtractor: 逐步提取事件序列

Step 3: RAG Retrieval (原文检索)
  └── FAISS + BGE Reranker: 为每个事件检索相关原文片段

Step 4: Scene Extraction (场景提取)
  └── SceneExtractor: 每个事件拆解为多个场景

Step 5: Character Merging (角色合并)
  └── 三级合并: Scene → Event → Novel
  └── CharacterInScene → CharacterInEvent → CharacterInNovel

Step 6: Portrait Generation (肖像生成)
  └── 两阶段: base portrait (静态特征) → scene-specific portrait (动态特征)

Step 7: Per-Scene Video Generation
  └── 复用 Script2VideoPipeline
```

**Novel2Movie 的角色一致性**比 Script2Video 更复杂：
- 角色在不同场景可能有不同名字 (别名系统)
- 角色在不同场景有不同服装 (动态特征按场景变化)
- 需要 `base portrait` + 场景特定 `dynamic portrait` 两层肖像

---

## 9. 设计亮点与不足

### 9.1 亮点

1. **Camera Tree 是核心创新**：通过 LLM 分析镜头间的空间包含关系构建层级树，再利用 transition video + scene detection 从父镜头画面推导子镜头画面，这是保证多机位一致性的优雅方案。

2. **variation_type 三级分类**：精准匹配了底层视频模型的能力边界——small 变化不需要 last_frame，节省 API 调用；large 变化必须有 last_frame 才能保证视频质量。

3. **首帧/末帧分解**：将连续运动描述拆解为「静态快照对 + 运动指令」，这不仅适配了 Veo 的 API 接口，也使得帧生成和视频生成可以解耦并行。

4. **ReferenceImageSelector 的两轮筛选**：先文本粗筛减少多模态模型的输入量，再图像精选确保最终参考图的质量。平衡了成本和效果。

5. **Checkpoint/Resume**：每个中间产物都持久化到磁盘，管线可以从任意断点恢复。对于可能运行数小时的视频生成任务，这是必备的工程设计。

6. **工具层完全可插拔**：通过 YAML 配置 + importlib 动态加载，可以灵活切换 Google / Doubao / 自建服务的图像和视频生成后端。

### 9.2 不足与改进方向

1. **Agent 无自主性**：所有 Agent 都是被动调用的函数，没有自主决策、反思或纠错能力。如果 StoryboardArtist 的分镜设计不佳，没有机制让其他 Agent 给出反馈要求重新设计。

2. **无质量评估闭环**：生成的帧和视频没有质量检查机制。项目中有 `best_image_selector.py` 但未被任何管线使用，暗示这是一个计划中但未完成的功能。

3. **类级别共享状态**：`Script2VideoPipeline` 的事件字典 (`character_portrait_events`, `shot_desc_events`, `frame_events`) 是类变量而非实例变量，多实例运行时会产生状态污染。

4. **Novel2Movie 未完成**：标注了 `# TODO: NOT IMPLEMENTED YET`，角色数据结构查找用了线性遍历（代码中有 TODO 注释承认了这个问题）。

5. **音频管线缺失**：`audio_desc` 字段在分镜设计中被生成，但在视频生成阶段仅作为 prompt 的一部分传入，没有独立的 TTS/SFX 生成管线。

6. **错误处理较弱**：虽然有 `tenacity` 的重试机制，但大多数只是简单的 3 次重试。没有降级策略（如切换到备用模型）、没有人工干预接口。

7. **Prompt 中的角色名处理不一致**：`StoryboardArtist` 要求用 `<Alice>` 包裹角色名，但 `motion_desc` 的 Prompt 又要求不用角色名而用外貌特征描述。这种切换增加了 LLM 出错的概率。

---

## 附录：核心文件索引

| 文件路径 | 行数 | 核心类/函数 |
|---------|------|-----------|
| `pipelines/idea2video_pipeline.py` | 312 | `Idea2VideoPipeline.__call__()` |
| `pipelines/script2video_pipeline.py` | 675 | `Script2VideoPipeline.__call__()` |
| `agents/screenwriter.py` | 166 | `Screenwriter.develop_story()`, `.write_script_based_on_story()` |
| `agents/storyboard_artist.py` | 258 | `StoryboardArtist.design_storyboard()`, `.decompose_visual_description()` |
| `agents/camera_image_generator.py` | 219 | `CameraImageGenerator.construct_camera_tree()`, `.generate_transition_video()` |
| `agents/reference_image_selector.py` | 226 | `ReferenceImageSelector.select_reference_images_and_generate_prompt()` |
| `agents/character_extractor.py` | 90 | `CharacterExtractor.extract_characters()` |
| `agents/character_portraits_generator.py` | 92 | `CharacterPortraitsGenerator.generate_front/side/back_portrait()` |
| `interfaces/shot_description.py` | 190 | `ShotBriefDescription`, `ShotDescription` |
| `interfaces/camera.py` | 44 | `Camera` |
| `interfaces/character.py` | 101 | `CharacterInScene`, `CharacterInEvent`, `CharacterInNovel` |
| `tools/video_generator_veo_google_api.py` | 116 | `VideoGeneratorVeoGoogleAPI.generate_single_video()` |
| `utils/rate_limiter.py` | 106 | `RateLimiter.acquire()` |
