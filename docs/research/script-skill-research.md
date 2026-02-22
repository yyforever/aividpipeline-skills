# aivp-script Skill 调研笔记

**日期：** 2026-02-22
**来源：** 多篇文章 + API 文档

---

## 1. AI 视频 Prompt 结构要求

### Kling 3.0 Prompt 格式（fal.ai 官方指南，Feb 2026）
- **Think in Shots, Not Clips** — 支持单次生成最多 6 个镜头，每个镜头需独立描述 framing/subject/motion
- **Anchor Subjects Early** — 角色描述在 prompt 开头锁定，全镜头保持一致
- **Describe Motion Explicitly** — 摄影机运动必须明确：tracking/following/freezing/panning，不能模糊
- **Native Audio Format** — 对话用 `[Character A: Name, tone]: "dialogue"` 格式标注
- **Cinematic Language** — 理解 profile shot、macro close-up、tracking shot、POV、shot-reverse-shot
- **Multi-shot 格式：**
  ```
  Master Prompt: [整体场景描述]
  Multi shot Prompt 1: [镜头1描述] (Duration: 5s)
  Multi shot Prompt 2: [镜头2描述] (Duration: 5s)
  ```

### Seedance 2.0 Prompt 格式（WaveSpeed 指南）
- **基础结构：** Subject + Motion + Scene + Lens + Style
- **All-Round Reference 模式：** 最多 12 个参考文件（图片/视频/音频），用 @Image1 @Video1 标签引用
- **动作描述：** Subject 1 + Movement 1 + Movement 2（时间序列多动作）
- **镜头语言：** surround/aerial/zoom/pan/follow/handheld + "lens switch" 实现多镜头
- **程度副词关键：** fast/violent/large/high frequency/strong/crazy — 必须明确动作强度
- **图生视频：** 只描述运动变化部分，不描述静态已有内容

### 通用 AI 视频 Prompt 最佳实践
- 前 20-30 个词权重最高（Simplified，2026）
- 公式：[Shot Type] + [Subject Action] + [Emotional State] + [Lighting/Atmosphere] + [Technical Specs]
- Hook > Setup > Payoff 结构（ShortGenius，2026）
- Sora 2: 分镜式 prompt，描述角色如何移动+转场

---

## 2. 微短剧 Script 结构特点

### Vertical Drama Script 解剖（Real Reel，观看 100+ 系列总结）
- **0-15s "The Hook Window"（爆点）**：中国制作人叫"爆点"，观众 15 秒内决定是否划走，必须从危机中开始
- **15-60s 每 40 秒一个情绪波峰**：90 秒一集至少 2 个情绪 spike（reveal/reversal/joy/dread）
- **One Line, One Arena**：单剧情线，不超过 5 个固定场景
- **Characters Built for Speed**：4 个词能概括的二元冲突（rich bully vs underdog），强视觉标识（戒指/伤疤/抽搐）

### Microdrama Screenwriting 框架（Jenova.ai，2026）
- **3-7-21 规则**：前 3 秒抓注意，前 7 秒建冲突，前 21 秒完成第一个情绪循环
- **Paywall-aware 结构**：第 3-5 集设付费墙，cliffhanger 强度在此达峰
- **60-100 集/季**，80 个连续 cliffhanger
- **对话压缩**：每行必须推动剧情 OR 揭示角色，最好同时
- **公式：** 市场 $11B（2025），ReelShort $1.2B（+119% YoY）

### Final Draft 分析
- 每集 1-3 分钟，每集要有自己的开头/中间/结尾 + cliffhanger
- 不能把 100 分钟电影切成 100 个 1 分钟——每集必须独立运作
- 制作周期约 1 周拍完一季（60-80 集）
- 预算 $50K-$250K/季（传统）；AI 可降低 90%

---

## 3. Script → Video Pipeline 工具

### Genra AI（全流程平台）
- Script → Cast Virtual Stars（Reference Seeds 保一致性）→ Scene Generation → Lip-Sync & Audio → Edit → Publish
- Prompt 公式：[Shot Type] + [Subject Action] + [Emotional State] + [Lighting] + [Technical Specs]
- 传统 80 集制作 $300K，AI 降 90%

### LTX Studio（Script to Video）
- 脚本自动分镜 → Elements 一致性 → MP4 storyboard 导出
- 侧重 storyboard/预览，非最终视频

### 其他
- Frameo.ai: AI Micro Drama 专用——分镜+角色声音+摄影机选择自动化
- Drawstory.ai: Script → Storyboard AI
- VideoGen: Social-first，Script → TTS + B-roll + Captions + Music

---

---

## 5. 对标项目（开源 + 商业）

### 开源 Pipeline

| 项目 | GitHub Stars | 定位 | Pipeline 覆盖 | 可参考点 |
|------|:-----------:|------|-------------|---------|
| **ViMax** (HKUDS) | 趋势上升 | Agentic Video Generation — Director+Screenwriter+Producer+Generator All-in-One | Idea→Script→Storyboard→Character→Video | Multi-agent 架构：独立 Director/Screenwriter/Producer agent 协作；支持 Idea2Video、Novel2Video、Script2Video、AutoCameo 四种模式 |
| **Huobao Drama（火宝短剧）** | — | 一句话生成完整短剧 | Script→Character→Storyboard→Video→Edit | Go+Vue3 全栈；DDD 架构；角色管理+分镜生成+视频合成+转场；支持 doubao 作为 video provider |
| **Pallaidium** | — | Blender 集成 AI 电影工作室 | Text→Image/Video/Audio/Music/Speech | 集成到 Blender VSE，支持 ControlNet/IP Adapter/LoRA；偏工具箱不是 pipeline |
| **video-creator** (prakashdk) | — | 全离线 pipeline | Script→TTS→Image→Subtitle→Video | 离线运行，适合 Shorts/storytelling |

### 商业平台

| 平台 | 定位 | Pipeline 覆盖 | 可参考点 |
|------|------|-------------|---------|
| **Genra AI** | AI 短剧生成专用 | Script→Cast(Reference Seeds)→Scene→Lip-Sync→Edit→Publish | 角色 Reference Seeds 保一致性；内置语音+口型同步+剪辑；Prompt 公式 |
| **LTX Studio** | 企业级 AI 视频制作 | Script→Storyboard→Elements→Video→Audio-to-Video | Script 自动分镜；Elements 系统（角色/物件一致性）；Audio-to-Video 口型同步 |
| **MicroDrama AI** | 微短剧一站式平台 | Idea→Script→Character→Video | "30 分钟从想法到视频"；专门针对微短剧优化 |
| **Frameo AI** | AI Micro Drama | Script→Shots→Character Voice→Camera→Video | 自动拆分镜头+角色声音+摄影机选择 |
| **Drama-Story** | 短剧制作平台 | Idea→Story→Storyboard→Video | AI story generation + 分镜 + 视频 |

### 关键模式总结

1. **Multi-agent 编排**（ViMax）— 每个生产阶段由独立 agent 负责，互相协作。最接近我们 aivp-pipeline 的目标架构
2. **角色 Reference Seeds**（Genra）— script 阶段定义角色外观 → 全流程复用。和我们的 character sheet 设计一致
3. **Script 自动分镜**（LTX/Huobao）— 从叙事脚本自动生成逐镜头 prompt。这就是我们的"双层输出"
4. **Elements 系统**（LTX）— 统一的角色/物件/场景定义，跨镜头保持一致。值得在 pipeline 层面参考
5. **全栈 DDD 架构**（Huobao）— Go+Vue 全栈产品化。如果我们要做产品而非 skill，这是参考

## 4. 对 aivp-script Skill 的启示

### 当前问题
1. **输出格式和 AI 视频模型不对齐** — JSON 里的 visual_direction 太泛，无法直接用作 Kling/Seedance prompt
2. **没有微短剧特定知识** — 缺 Hook Window/每 40 秒波峰/cliffhanger 链/场景压缩
3. **和 ideation 的衔接断了** — 没有读 brief-final.md 的入口
4. **一次生成无迭代** — 剧本需要多轮修改
5. **缺少角色系统** — 微短剧需要角色一致性，script 阶段就要定义角色参考

### 设计方向
1. **双层输出：叙事剧本 + 技术分镜**
   - Layer A: 人类可读的叙事剧本（scene/dialogue/emotion）
   - Layer B: AI 视频模型可直接使用的技术 prompt（per-shot，按 Kling/Seedance 格式）
2. **微短剧结构内置**
   - 自动检查 Hook Window（前 15s）
   - 每 40s 情绪波峰标记
   - Cliffhanger 评估
3. **角色系统**
   - 在 script 阶段定义角色外观/声音/标识
   - 输出 character sheet 供 image/video skill 使用
4. **brief-final.md → script 的标准化入口**
5. **迭代式：** script-v1 → 讨论 → script-v2 → ... → script-final
6. **三层输出结构：** plan.md + notes/ + deliverables/
