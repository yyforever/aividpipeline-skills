# AIVP 后期制作阶段竞品深度调研报告

> 调研日期：2026-02-21
> 范围：aivp-edit / aivp-review / aivp-publish / aivp-pipeline 对标竞品分析

---

## 目录

1. [调研方法论与竞品全景](#1-调研方法论与竞品全景)
2. [aivp-edit 竞品对比](#2-aivp-edit-竞品对比)
3. [aivp-review 竞品对比](#3-aivp-review-竞品对比)
4. [aivp-publish 竞品对比](#4-aivp-publish-竞品对比)
5. [aivp-pipeline 竞品对比](#5-aivp-pipeline-竞品对比)
6. [交叉分析与战略建议](#6-交叉分析与战略建议)

---

## 1. 调研方法论与竞品全景

### 1.1 调研范围

本次调研覆盖以下竞品来源：

**本地 openclaw-skills 仓库（已读取完整 SKILL.md + scripts）：**
- `liudu2326526/ffmpeg-master` — FFmpeg 百科全书式 skill
- `liudu2326526/insaiai-intelligent-editing` — 增强版 FFmpeg skill（含视频稳定化、GIF、色彩校正等高级技巧）
- `am-will/remotion-best-practices` — Remotion 官方最佳实践（28+ 子规则文件）
- `jack4world/remotion-excalidraw-tts` — Excalidraw 图解视频 pipeline（完整的 Python 脚本 + Remotion 模板）
- `yuf1011/xiaohongshu-publisher` — 小红书全流程发布 skill（封面生成 + 浏览器自动化）
- `hugosbl/markdown-to-social` — Markdown 转多平台社交帖（Python 脚本，支持 Twitter/LinkedIn/Reddit）
- `hhhh124hhhh/ai-video-gen-tools` — 端到端 AI 视频生成
- `hhhh124hhhh/brand-story-video` — Sora2 品牌故事视频模板
- `donut33-social/tagclaw` — AI 社交网络自主 agent（TagAI 平台）
- `kangjjang/youtube-shorts-automation` — YouTube Shorts 全自动化管线
- `globalcaos/youtube-ultimate` — 最全面的 YouTube 研究 skill
- `pauldelavallaz/ugc-campaign-pipeline` — UGC 营销视频完整 pipeline

**skills.sh 在线平台（已抓取完整内容）：**
- `remotion-dev/skills` — Remotion 官方 4 个 skill（102.6K 安装量），含 remotion-best-practices（28+ 规则）
- `inference-sh/skills/ai-content-pipeline` — 多步内容创作管线（最接近 aivp-pipeline 的竞品）
- `inference-sh/skills/ai-social-media-content` — AI 社交媒体内容生成
- `inference-sh/skills/ai-video-generation` — 40+ AI 视频模型聚合
- `inference-sh/skills/ai-automation-workflows` — 自动化工作流模式

### 1.2 竞品分类矩阵

| 竞品 | 编辑 | 审核 | 发布 | Pipeline | 安装量 |
|------|:----:|:----:|:----:|:--------:|-------:|
| ffmpeg-master | ★★★ | - | - | - | — |
| insaiai-intelligent-editing | ★★★★ | - | - | - | — |
| remotion-best-practices | ★★★★★ | - | - | - | 102.6K |
| remotion-excalidraw-tts | ★★★ | - | - | ★★ | — |
| xiaohongshu-publisher | - | ★ | ★★★★ | ★★ | — |
| markdown-to-social | - | - | ★★★ | - | — |
| ai-video-gen-tools | ★★ | - | - | ★★ | — |
| youtube-shorts-automation | - | - | ★★★ | ★★★ | — |
| youtube-ultimate | - | - | ★★★★ | - | — |
| ugc-campaign-pipeline | ★★★ | ★★ | - | ★★★★ | — |
| inference-sh/ai-content-pipeline | ★★ | - | ★★ | ★★★★★ | 7.2K |
| inference-sh/ai-social-media-content | - | - | ★★★★ | ★★ | 7.2K |
| inference-sh/ai-video-generation | ★★ | - | - | ★★ | 7.2K |
| **aivp-edit** | ★★★ | - | - | - | — |
| **aivp-review** | - | ★★★ | - | - | — |
| **aivp-publish** | - | - | ★★★ | - | — |
| **aivp-pipeline** | - | - | - | ★★★★ | — |

---

## 2. aivp-edit 竞品对比

### 2.1 功能覆盖对比表

| 功能 | aivp-edit | ffmpeg-master | insaiai-editing | remotion-bp | remotion-excalidraw | inference-sh |
|------|:---------:|:------------:|:--------------:|:-----------:|:------------------:|:------------:|
| **视频拼接** | ✅ 脚本 | ✅ 命令示例 | ✅ 命令示例 | ✅ TransitionSeries | ✅ 自动拼场景 | ✅ media-merger |
| **音频混合** | ✅ 脚本 | ✅ 滤镜示例 | ✅ 进阶技巧 | ✅ Audio组件 | ✅ TTS集成 | ✅ media-merger |
| **字幕烧录** | ✅ 脚本 | ❌ | ✅ hardsub示例 | ✅ 字幕系统 | ✅ subtitle组件 | ✅ caption-video |
| **视频裁剪** | ✅ 脚本 | ✅ 命令示例 | ✅ 命令示例 | ✅ trimming规则 | ❌ | ❌ |
| **速度调整** | ✅ 脚本 | ✅ setpts/atempo | ✅ setpts/atempo | ✅ playbackRate | ❌ | ❌ |
| **转场效果** | ⚠️ 仅crossfade | ✅ xfade | ✅ xfade | ✅ 丰富转场库 | ❌ | ✅ crossfade |
| **导出管线** | ✅ export.sh | ❌ | ❌ | ✅ render CLI | ✅ 一键渲染 | ✅ merge |
| **硬件加速** | ❌ | ✅ NVENC/QSV/VT | ✅ NVENC/QSV/VT | ❌ 浏览器渲染 | ❌ | ❌ |
| **视频稳定化** | ❌ | ❌ | ✅ vidstab | ❌ | ❌ | ❌ |
| **色彩校正** | ❌ | ❌ | ✅ eq滤镜 | ❌ CSS滤镜 | ❌ | ❌ |
| **GIF创建** | ❌ | ❌ | ✅ palettegen | ✅ Gif组件 | ❌ | ❌ |
| **水印叠加** | ❌ | ✅ overlay | ✅ overlay | ✅ 组件叠加 | ❌ | ❌ |
| **视频布局** | ❌ | ✅ hstack/vstack | ✅ hstack/vstack | ✅ CSS flex | ❌ | ❌ |
| **场景检测** | ❌ | ❌ | ✅ scene filter | ❌ | ❌ | ❌ |
| **3D内容** | ❌ | ❌ | ❌ | ✅ Three.js | ❌ | ❌ |
| **文字动画** | ❌ | ❌ | ❌ | ✅ 专用规则 | ✅ 字幕动画 | ❌ |
| **图表可视化** | ❌ | ❌ | ❌ | ✅ 图表规则 | ❌ | ❌ |
| **Lottie动画** | ❌ | ❌ | ❌ | ✅ 专用规则 | ❌ | ❌ |
| **直播推流** | ❌ | ❌ | ✅ RTMP | ❌ | ❌ | ❌ |
| **自动去静音** | ❌ | ❌ | ✅ silenceremove | ❌ | ❌ | ❌ |

### 2.2 竞品优势分析

#### ffmpeg-master / insaiai-intelligent-editing（同作者，后者为增强版）

**做得好的地方：**

1. **百科全书式知识覆盖**：insaiai 版本包含 12 个"Pro Tips"（GIF创建、音频混合、视频稳定化、色彩校正、缩略图网格、去静音、hardsub、目标文件大小压缩、场景检测、定时抽帧、批处理、直播推流），每个都是经过验证的 FFmpeg 命令模式。

   > 具体引用：视频稳定化两遍处理
   > ```bash
   > # Pass 1: Analyze
   > ffmpeg -i shaky.mp4 -vf vidstabdetect -f null -
   > # Pass 2: Transform
   > ffmpeg -i shaky.mp4 -vf vidstabtransform,unsharp=5:5:0.8:3:3:0.4 output.mp4
   > ```

2. **硬件加速参考表**：清晰列出 NVENC / QSV / VideoToolbox 的对应命令，这在大量视频处理时是关键性能优化。

3. **"When to Use"决策矩阵**：将所有操作分为 Codecs & Quality / Filters & Manipulation / Inspection & Metadata 三大类，并用表格标注每个选项的使用时机，方便 LLM agent 做决策。

**不足：**
- 纯参考文档，没有可执行脚本
- 没有 pipeline 概念
- 没有项目目录结构约定

#### remotion-best-practices（Remotion 官方，102.6K 安装量）

**做得好的地方：**

1. **模块化子规则架构**：28+ 独立规则文件（3d.md, animations.md, audio.md, transitions.md, compositions.md, text-animations.md 等），每个规则都是自包含的代码教程。这种"需要什么加载什么"的设计极大减少了 context 消耗。

   > 具体引用（SKILL.md 主文件结构）：
   > ```
   > Read individual rule files for detailed explanations and code examples:
   > - [rules/3d.md] - 3D content using Three.js
   > - [rules/transitions.md] - Scene transition patterns
   > - [rules/transcribe-captions.md] - Transcribing audio to generate captions
   > ```

2. **转场系统远超 FFmpeg xfade**：Remotion 的 `TransitionSeries` 组件支持 fade / slide / wipe / flip / clockWipe 等多种转场，配合 `linearTiming` / `springTiming` 物理动画，效果远比 FFmpeg 的 xfade 丰富。

   > 具体引用（transitions.md）：
   > ```tsx
   > <TransitionSeries>
   >   <TransitionSeries.Sequence durationInFrames={60}><SceneA /></TransitionSeries.Sequence>
   >   <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames: 15})} />
   >   <TransitionSeries.Sequence durationInFrames={60}><SceneB /></TransitionSeries.Sequence>
   > </TransitionSeries>
   > ```

3. **完整的音频控制**：支持动态音量曲线（interpolate 函数）、pitch 调整（toneFrequency）、循环模式（loopVolumeCurveBehavior）、mute 逻辑等，远比 FFmpeg 的 volume/atempo 灵活。

4. **字幕/Caption 系统**：集成 whisper.cpp（本地转录）、whisper-web（浏览器转录）、OpenAI Whisper API（云端转录），并有专用的 TikTok 风格字幕渲染规则。

5. **calculateMetadata 动态渲染**：可以在渲染前异步获取数据、动态设置 duration/dimensions/props，这对 AI 管线非常重要。

**不足：**
- 需要 Node.js/React 环境，部署门槛高于纯 FFmpeg
- 没有 AI 生成模型集成
- 是"知识型"skill 而非"工具型"skill

#### remotion-excalidraw-tts（jack4world）

**做得好的地方：**

1. **端到端自动化脚本（make_video.py）**：220 行 Python 代码实现了完整的 `图表 + 旁白 → MP4` 管线。关键步骤：复制 Remotion 模板 → 写入素材 → TTS 生成语音 → 计算帧数 → patch Duration → npm install → remotion render。

   > 具体引用（patch_root_duration 函数）：
   > ```python
   > def patch_root_duration(root_tsx: Path, duration_in_frames: int):
   >     s = root_tsx.read_text(encoding="utf-8")
   >     s2, n = re.subn(
   >         r"durationInFrames=\{[^}]+\}",
   >         f"durationInFrames={{{duration_in_frames}}}",
   >         s, count=1,
   >     )
   > ```

2. **多 TTS 后端支持**：`say`（macOS 本地免费）、`openai`（gpt-4o-mini-tts）、`elevenlabs`（高质量多语言），通过 `--tts-backend` 切换，零 Python 依赖（用 curl 调 API）。

3. **Storyboard JSON Schema**：定义了清晰的 scene 结构（name, durationSec, subtitle, cameraFrom/cameraTo, focus），让 LLM 可以直接生成镜头脚本：
   > ```json
   > {
   >   "scenes": [{
   >     "name": "intro", "durationSec": 10,
   >     "subtitle": "很多智能体隔天就失忆。",
   >     "cameraFrom": {"x": 0, "y": 0, "scale": 1},
   >     "cameraTo": {"x": 0, "y": 0, "scale": 1},
   >     "focus": {"x": 140, "y": 120, "width": 1640, "height": 340, "label": "问题"}
   >   }]
   > }
   > ```

4. **内置 Remotion 组件模板**：包含 FocusOverlay.tsx、Subtitle.tsx、DiagramStage.tsx 等预制组件，开箱即用。

**不足：**
- 仅适用于 Excalidraw 图解视频这一特定场景
- macOS `say` 依赖限制了跨平台使用
- 没有 review/publish 步骤

### 2.3 aivp-edit 脚本质量评估

**优点：**
- 6 个脚本（concat.sh、mix-audio.sh、add-subtitles.sh、trim.sh、adjust-speed.sh、export.sh）覆盖了核心编辑场景
- 每个脚本都有完整的 `--help`、参数验证、`set -e`、`mkdir -p`
- export.sh 实现了完整的 concat → audio → subtitles → encode 流水线
- 使用 `trap` 清理临时文件

**不足：**
1. **转场效果单一**：crossfade 仅支持 2 个输入文件，无法处理 3+ clips 的链式转场
2. **缺少高级功能**：没有视频稳定化、色彩校正、水印叠加、画中画
3. **缺少硬件加速**：所有编码都用 CPU，处理 4K 视频会很慢
4. **adjust-speed.sh 有 bug**：`atempo` 滤镜仅支持 0.5-2.0 倍速，脚本没有处理超出范围的情况（需要链式 atempo）
5. **add-subtitles.sh 硬编码颜色**：`PrimaryColour=&H00FFFFFF` 忽略了 `--font-color` 参数的实际值
6. **export.sh 使用 eval**：`eval bash "$SCRIPT_DIR/concat.sh" $CONCAT_ARGS` 和 `eval $CMD` 存在路径注入风险
7. **缺少 LOUDNORM 音量标准化**：mix-audio.sh 没有做响度标准化（-14 LUFS），但 review 阶段检查了它

### 2.4 具体改进建议

| 优先级 | 改进 | 参考来源 | 说明 |
|:------:|------|----------|------|
| P0 | 修复 adjust-speed.sh atempo 范围限制 | ffmpeg-master | 链式 atempo：`atempo=2.0,atempo=2.0` 实现 4x |
| P0 | 修复 add-subtitles.sh 颜色参数 | — | 将 `--font-color` 转换为 ASS 颜色格式 |
| P0 | export.sh 消除 eval | — | 使用数组传参替代 eval |
| P1 | 添加 loudnorm 脚本 | review checklist | `normalize-audio.sh --input video.mp4 --target-lufs -14` |
| P1 | 支持 3+ clips 的链式转场 | remotion transitions | 循环使用 xfade + offset 计算 |
| P1 | 添加水印叠加脚本 | insaiai-editing overlay | `watermark.sh --video v.mp4 --logo logo.png --position bottom-right` |
| P2 | 添加硬件加速选项 | ffmpeg-master | `--hwaccel nvenc|qsv|videotoolbox` |
| P2 | 添加色彩校正脚本 | insaiai-editing eq | `color-correct.sh --brightness 0.05 --contrast 1.1` |
| P2 | 添加视频稳定化脚本 | insaiai-editing vidstab | `stabilize.sh --input shaky.mp4 --output stable.mp4` |
| P3 | 添加 FFmpeg 知识引用文档 | ffmpeg-master | 在 references/ 下添加 FFmpeg 速查表 |

---

## 3. aivp-review 竞品对比

### 3.1 竞品现状

**关键发现：在所有调研的竞品中，几乎没有独立的"视频审核"skill。** 这是 AIVP 的差异化优势。

最接近的竞品实践：
- `ugc-campaign-pipeline` 在 pipeline 末尾有一个"Quality Checklist"
- `xiaohongshu-publisher` 有用户审核确认步骤（但是内容审核不是技术质量审核）
- `inference-sh` 完全没有审核步骤

### 3.2 功能覆盖对比表

| 功能 | aivp-review | ugc-campaign | xiaohongshu-pub | inference-sh | 行业标准 |
|------|:-----------:|:------------:|:--------------:|:------------:|:--------:|
| **分辨率检查** | ✅ ffprobe | ⚠️ 手动 checklist | ❌ | ❌ | YouTube要求1080p+ |
| **帧率检查** | ✅ ffprobe | ❌ | ❌ | ❌ | ≥24fps |
| **音频响度** | ✅ loudnorm | ❌ | ❌ | ❌ | -14 LUFS |
| **文件大小** | ✅ | ❌ | ❌ | ❌ | <4GB |
| **编码检查** | ✅ codec检测 | ❌ | ❌ | ❌ | H.264/H.265 |
| **黑帧检测** | ✅ blackdetect | ❌ | ❌ | ❌ | 无>1s黑帧 |
| **静音检测** | ✅ silencedetect | ❌ | ❌ | ❌ | 无>2s静音 |
| **场景完整性** | ⚠️ agent审核 | ⚠️ 手动 | ❌ | ❌ | 所有场景存在 |
| **音画同步** | ⚠️ agent审核 | ❌ | ❌ | ❌ | 旁白匹配画面 |
| **字幕可读性** | ⚠️ agent审核 | ❌ | ❌ | ❌ | 每句≥1.5s |
| **NSFW检测** | ⚠️ agent标记 | ❌ | ❌ | ❌ | 阻止发布 |
| **版权音乐检测** | ⚠️ agent标记 | ❌ | ❌ | ❌ | 替换为生成BGM |
| **AI水印检测** | ⚠️ agent标记 | ✅ | ❌ | ❌ | 标记 |
| **品牌安全** | ⚠️ agent标记 | ❌ | ❌ | ❌ | 标记 |
| **JSON报告输出** | ✅ | ❌ | ❌ | ❌ | — |
| **PASS/FAIL决策** | ✅ | ❌ | ❌ | ❌ | — |

### 3.3 ugc-campaign-pipeline 的审核实践

> 具体引用（Quality Checklist）：
> ```
> - [ ] Hero image: product visible, model looks natural
> - [ ] Variations: 4 selected are distinct and lip-sync ready
> - [ ] Script: matches brand tone, pure dialogue format
> - [ ] Videos: lip-sync quality is good, no artifacts
> - [ ] Final: subtitles readable, transitions smooth, logo appears
> - [ ] Audio: voice quality clear, timing natural
> ```

这是手动 checklist 而非自动化检查。aivp-review 的 `check-technical.sh` 已经实现了自动化，这是明确优势。

### 3.4 aivp-review 脚本质量评估

**优点：**
- check-technical.sh 是一个实际可运行的综合检查脚本（约 80 行）
- 覆盖了分辨率、帧率、文件大小、编解码器、黑帧、静音等 6 项技术检查
- 输出标准 JSON 格式，方便 pipeline 消费
- PASS / FAIL / PASS_WITH_WARNINGS 三级判定

**不足：**
1. **缺少 check-audio.sh**：SKILL.md 提到了这个脚本但实际不存在
2. **缺少响度检查**：check-technical.sh 没有实际测量 LUFS 值（SKILL.md 的 checklist 提到了 -14 LUFS 标准）
3. **Python3 依赖**：使用 `python3 -c` 解析 JSON，可用 `jq` 替代以减少依赖
4. **内容审核完全靠 agent**：NSFW、版权、品牌安全等都标记为"agent审核"但没有工具支持
5. **没有自动修复能力**：检测到问题后只能报告，不能自动修复（如自动 loudnorm）

### 3.5 具体改进建议

| 优先级 | 改进 | 说明 |
|:------:|------|------|
| P0 | 创建 check-audio.sh | 实现 `ffmpeg -i input -af loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null -` LUFS 测量 |
| P0 | 用 jq 替换 python3 JSON 解析 | 减少依赖，更 portable |
| P1 | 添加 fix-audio.sh | 自动响度标准化：检测到不合规时自动修复 |
| P1 | 添加字幕时长检查 | 解析 SRT 文件，检查每条字幕的显示时长 ≥ 1.5s |
| P2 | 添加比特率检查 | 计算视频比特率是否匹配目标平台要求 |
| P2 | 添加完整的 review-report.sh | 生成 Markdown 格式的人类可读报告 |
| P3 | 集成视觉 AI 检查 | 使用 LLM vision 检查场景一致性、AI 水印等 |

---

## 4. aivp-publish 竞品对比

### 4.1 功能覆盖对比表

| 功能 | aivp-publish | xiaohongshu-pub | markdown-to-social | youtube-shorts | youtube-ultimate | inference-sh/social | tagclaw |
|------|:-----------:|:--------------:|:-----------------:|:-------------:|:---------------:|:------------------:|:-------:|
| **缩略图生成** | ✅ FFmpeg提取 | ✅ Pillow生成 | ❌ | ❌ | ❌ | ✅ FLUX生成 | ❌ |
| **封面设计** | ❌ | ✅ 渐变+CJK文字 | ❌ | ❌ | ❌ | ✅ AI生成 | ❌ |
| **平台适配格式** | ✅ 6平台 | ❌ 仅小红书 | ❌ | ❌ 仅Shorts | ❌ | ✅ 所有平台表格 | ❌ |
| **元数据生成** | ⚠️ agent生成 | ✅ 内容指南 | ✅ 脚本转换 | ✅ 模板 | ❌ | ✅ Claude生成 | ❌ |
| **SEO优化** | ✅ 指南 | ✅ 标签策略 | ✅ 平台规则 | ❌ | ❌ | ❌ | ❌ |
| **实际上传** | ❌ | ✅ 浏览器自动化 | ❌ | ✅ YouTube API | ✅ YouTube API | ✅ Twitter API | ✅ TagAI API |
| **浏览器自动化** | ❌ | ✅ OpenClaw browser | ❌ | ❌ | ❌ | ❌ | ❌ |
| **人工确认流程** | ❌ | ✅ 审核→确认→发布 | ❌ | ❌ | ❌ | ❌ | ⚠️ 自主发布 |
| **多平台一键发布** | ❌ | ❌ 仅小红书 | ✅ 3平台 | ❌ 仅YouTube | ❌ 仅YouTube | ✅ 多平台 | ❌ 仅TagAI |
| **定时发布** | ❌ | ✅ cron集成 | ❌ | ✅ cron集成 | ❌ | ❌ | ✅ heartbeat |
| **内容风格指南** | ❌ | ✅ 详细指南 | ✅ 平台规则 | ❌ | ❌ | ✅ 模板 | ❌ |
| **Hashtag策略** | ✅ 基本指南 | ✅ 详细策略 | ✅ 自动生成 | ✅ 模板 | ❌ | ✅ Claude生成 | ❌ |

### 4.2 竞品优势分析

#### xiaohongshu-publisher（yuf1011）

**做得好的地方：**

1. **完整的发布管线（Draft → Cover → Review → Publish）**：这是最接近"生产级"的发布 skill，有 4 步流程，每步都有明确输出。

2. **封面图生成脚本（gen_cover.py）**：230 行 Python 代码实现了专业级封面图生成：
   - 5 种渐变色方案（purple/blue/green/orange/dark）
   - CJK 字体自动检测（Linux + macOS 路径搜索）
   - 装饰性圆形叠加、badge、标签 pill
   - 自动文本换行（8字/行）
   - 1080×1440 小红书标准尺寸

   > 具体引用：
   > ```python
   > def draw_gradient(draw, color_top, color_bot):
   >     for y in range(H):
   >         r = y / H
   >         c = tuple(int(color_top[i] + (color_bot[i]-color_top[i])*r) for i in range(3))
   >         draw.line([(0, y), (W, y)], fill=c + (255,))
   > ```

3. **内容风格指南（content-guide.md）**：详细的小红书写作规范，包括标题公式、段落结构、emoji用法、互动结尾、标签策略。

4. **浏览器自动化发布（browser-publish.md）**：利用 OpenClaw 的 browser tool 实现：导航到创作者后台 → 检查登录 → 输入标题 → 输入正文 → 上传封面 → 点击发布 → 验证成功。

5. **安全回退机制**：浏览器自动化失败时，自动切换为"手动发布"模式，将格式化好的内容发送到用户频道。

   > 具体引用：
   > ```
   > **Never auto-publish.** Always wait for explicit user approval.
   > ```

#### markdown-to-social（hugosbl）

**做得好的地方：**

1. **纯 Python 实现（stdlib only）**：350+ 行代码，零外部依赖，无 API 调用。这是一个真正 portable 的工具。

2. **智能文本分割**：Twitter 线程生成使用了句子级分割（不在句子中间切断），每条推文严格 < 280 字符，自动编号。

   > 具体引用：
   > ```python
   > def chunk_text(text: str, max_len: int) -> list[str]:
   >     """Split text into chunks of at most max_len chars without cutting sentences."""
   >     sentences = split_sentences(text)
   >     ...
   > ```

3. **三平台差异化处理**：
   - Twitter：Hook tweet + 线程 + CTA + 编号
   - LinkedIn：Hook paragraph（1300字内"see more"前） + emoji bullets + 专业 hashtags
   - Reddit：Title + TL;DR + 保留原始 Markdown

#### inference-sh/ai-social-media-content

**做得好的地方：**

1. **AI 原生内容生成**：用 Claude 生成 caption、hook、hashtag，用 FLUX 生成配图，用 Veo 生成视频——完全不需要人类创作原始内容。

2. **完整的平台格式参考表**：
   > ```
   > | Platform | Aspect Ratio | Duration | Resolution |
   > | TikTok   | 9:16 vertical | 15-60s  | 1080x1920  |
   > | Instagram Reels | 9:16 vertical | 15-90s | 1080x1920 |
   > ```

3. **批量内容创作模式**：一周 5 天的内容一次生成，适合内容日历自动化。

#### youtube-shorts-automation（kangjjang）

**做得好的地方：**

1. **真正的 YouTube API 集成**：通过 OAuth `client_secret.json` + `token.json` 实现程序化上传。
2. **Cron 集成**：每日定时运行完整管线（图像生成 → 视频 → 上传）。
3. **韩语 + 英语双语支持**：适合国际化场景。

### 4.3 aivp-publish 脚本质量评估

**优点：**
- reformat.sh 支持 6 个平台（youtube/shorts/tiktok/reels/instagram/twitter）
- 平台规格表清晰完整
- SEO 指南实用（标题公式、描述技巧、标签策略）
- thumbnail.sh 实现了智能提取（默认 1/3 位置，或指定时间戳）

**不足：**
1. **没有实际上传能力**：最大的短板。不能自动发布到任何平台
2. **缺少 metadata.sh 脚本**：SKILL.md 提到了但不存在，元数据生成完全靠 agent
3. **缩略图质量低**：仅从视频提取帧，没有设计能力（对比 xiaohongshu 的 Pillow 封面生成和 inference-sh 的 AI 生成）
4. **没有封面图设计**：YouTube 缩略图 = 提取帧 vs 竞品 = AI 设计
5. **没有定时发布支持**
6. **没有人工确认流程**
7. **twitter 平台的 `-t 140` 限制不准确**：Twitter 视频上限是 2:20（140秒），但代码用的是 `-t 140` 按秒计算，应该更明确

### 4.4 具体改进建议

| 优先级 | 改进 | 参考来源 | 说明 |
|:------:|------|----------|------|
| P0 | 创建 metadata.sh 或改为 Python 脚本 | markdown-to-social | 根据视频标题/描述/标签生成多平台元数据 JSON |
| P0 | 添加 YouTube 上传脚本 | youtube-shorts-automation | 基于 YouTube Data API v3 的上传脚本 |
| P1 | 添加 AI 缩略图生成 | inference-sh | 集成 FLUX/DALL-E 生成高质量缩略图 |
| P1 | 添加小红书发布支持 | xiaohongshu-publisher | 浏览器自动化 + 封面图生成 |
| P1 | 添加人工确认流程 | xiaohongshu-publisher | 发布前必须等待用户 ✅ 确认 |
| P2 | 添加 Markdown → 社交帖转换 | markdown-to-social | 将视频描述转换为 Twitter 线程 / LinkedIn 帖等 |
| P2 | 添加 cron 定时发布支持 | youtube-shorts-automation | 每日定时运行发布流程 |
| P3 | 添加发布后分析追踪 | — | 发布 N 天后拉取观看/互动数据 |

---

## 5. aivp-pipeline 竞品对比

### 5.1 功能覆盖对比表

| 功能 | aivp-pipeline | inference-sh/content-pipeline | ugc-campaign | remotion-excalidraw | youtube-shorts-auto | ai-video-gen |
|------|:------------:|:----------------------------:|:-----------:|:------------------:|:------------------:|:------------:|
| **端到端流程** | ✅ 9步 | ✅ 5-6步 | ✅ 6步 | ✅ 4步 | ✅ 4步 | ✅ 4-5步 |
| **项目目录结构** | ✅ 详细 | ❌ | ✅ 基本 | ❌ | ❌ | ❌ |
| **数据流图** | ✅ ASCII art | ❌ | ✅ ASCII art | ❌ | ✅ 编号列表 | ❌ |
| **部分执行** | ✅ 任意起点 | ✅ 任意步骤 | ❌ 必须全流程 | ❌ | ❌ | ❌ |
| **执行日志** | ✅ pipeline.json | ❌ | ❌ | ❌ | ❌ | ❌ |
| **成本追踪** | ✅ total_cost_estimate | ❌ | ❌ | ❌ | ⚠️ 提到积分 | ✅ API成本表 |
| **模型可配置** | ✅ 环境变量 | ✅ CLI参数 | ❌ 硬编码 | ⚠️ TTS可选 | ❌ 硬编码 | ✅ 多模型 |
| **反馈循环** | ✅ publish→ideation | ❌ | ❌ | ❌ | ❌ | ❌ |
| **审核门控** | ✅ review→publish | ❌ | ✅ checklist | ❌ | ❌ | ❌ |
| **多平台输出** | ✅ shorts/tiktok | ✅ 多平台 | ❌ UGC格式 | ❌ 仅MP4 | ✅ Shorts | ❌ |
| **并行处理** | ✅ image/video/audio并行 | ✅ bash & | ❌ 串行 | ❌ 串行 | ❌ 串行 | ❌ 串行 |
| **错误恢复** | ❌ | ✅ retry+fallback | ❌ | ❌ | ❌ | ❌ |
| **定时调度** | ❌ | ✅ cron | ❌ | ❌ | ✅ cron | ❌ |
| **脚本自动化** | ❌ 纯文档 | ✅ bash脚本 | ✅ 分步命令 | ✅ Python脚本 | ✅ Python脚本 | ✅ Python脚本 |

### 5.2 竞品优势分析

#### inference-sh/ai-content-pipeline（最接近的竞品）

**做得好的地方：**

1. **Pipeline 模式分类**：定义了 3 种常见模式，每种都有完整的 bash 脚本示例：
   - Pattern 1: Image → Video → Audio
   - Pattern 2: Script → Speech → Avatar
   - Pattern 3: Research → Content → Distribution

   > 具体引用（YouTube Short Pipeline）：
   > ```bash
   > # 1. Generate script with Claude
   > infsh app run openrouter/claude-sonnet-45 --input '{"prompt": "Write a 30-second script..."}'
   > # 2. Generate voiceover with Kokoro
   > infsh app run infsh/kokoro-tts --input '{"text": "<script-text>", "voice": "af_sarah"}'
   > # 3. Generate background image with FLUX
   > infsh app run falai/flux-dev --input '{"prompt": "Futuristic city..."}'
   > # 4. Animate image to video with Wan
   > infsh app run falai/wan-2-5 --input '{"image_url": "<bg-url>", "prompt": "slow camera pan..."}'
   > # 5. Merge video with audio
   > infsh app run infsh/media-merger --input '{"video_url": "<url>", "audio_url": "<url>"}'
   > ```

2. **Building Blocks 模块化表**：将所有可用工具分为 Content Generation / Visual Assets / Animation / Audio / Post-Production 五大类，每类列出可选 App。

3. **多种 Pipeline 模板**：YouTube Short、Talking Head、Product Demo、Blog to Video 四种场景各有完整工作流。

4. **CLI 统一接口（infsh app run）**：所有 AI 服务通过统一的 CLI 调用，极大简化了 pipeline 编写。

**不足：**
- 完全依赖 inference.sh 平台（vendor lock-in）
- 没有项目目录结构约定
- 没有执行日志
- 没有审核步骤
- 没有 ideation/storyboard 概念

#### inference-sh/ai-automation-workflows

**做得好的地方：**

1. **5 种自动化模式**：Batch Processing、Sequential Pipeline、Parallel Processing、Conditional Workflow、Retry with Fallback。每种都有完整可运行的 bash 脚本。

   > 具体引用（Retry with Fallback）：
   > ```bash
   > generate_with_retry() {
   >     local max_attempts=3
   >     while [ $attempt -le $max_attempts ]; do
   >         result=$(infsh app run falai/flux-dev --input "..." 2>&1)
   >         if [ $? -eq 0 ]; then return 0; fi
   >         ((attempt++))
   >         sleep $((attempt * 2)) # Exponential backoff
   >     done
   >     # Fallback to different model
   >     infsh app run google/imagen-3 --input "..."
   > }
   > ```

2. **监控与日志**：提供了日志封装脚本、错误告警脚本（webhook）、执行时间追踪。

3. **调度集成**：Cron 设置示例、Content Calendar 自动化、Data Processing Pipeline。

#### ugc-campaign-pipeline（pauldelavallaz）

**做得好的地方：**

1. **最完整的 ASCII 流程图**：6 步 pipeline 每步都标注了输入、工具、输出路径，一目了然。

2. **行业模板**：提供了 Snacks/Food、Tech/Gadgets、Beauty/Skincare、Fashion 四个行业的脚本模板，可直接复用。

3. **实际工具集成**：每步使用具体的 skill（morpheus-fashion-design、multishot-ugc、veed-ugc、Remotion），有真实的命令行调用。

4. **执行 Checklist**：Before Starting / Step 1 / Step 2 ... / Quality Checklist，每步都有 [ ] 勾选项。

### 5.3 aivp-pipeline 质量评估

**优点：**
1. **最完整的项目目录结构**：19 个目录/文件的完整约定，比任何竞品都详细
2. **最长的 pipeline（9步）**：覆盖了 ideation → script → storyboard → image → video → audio → edit → review → publish 全链路
3. **数据流图直观**：ASCII art 展示了并行分支（image/video/audio 并行）和反馈循环（publish → ideation）
4. **部分执行能力**：支持从任意步骤开始，竞品中只有 inference-sh 做到了类似
5. **执行日志设计**：pipeline.json 记录了每步的 status、timing、output、details，包含成本估算
6. **模型可配置**：通过环境变量切换默认模型，灵活性高

**不足：**
1. **纯文档设计，没有可执行代码**：竞品（inference-sh、ugc-campaign、remotion-excalidraw）都有真实的脚本，aivp-pipeline 只有"agent 决定执行什么"的文档
2. **没有错误恢复机制**：inference-sh 的 retry + fallback 模式是生产级别必需的
3. **没有调度能力**：不支持 cron 定时触发
4. **没有并行执行实现**：数据流图画了并行，但没有实现（bash `&` 或类似）
5. **成本追踪是占位符**：pipeline.json 里的 `total_cost_estimate` 是硬编码示例，没有实际计算逻辑

### 5.4 aivp-pipeline 的独特价值 vs 竞品编排方式

| 维度 | aivp-pipeline | inference-sh | ugc-campaign | remotion-excalidraw |
|------|:------------:|:------------:|:------------:|:------------------:|
| **编排哲学** | Agent 决策 + 约定 | CLI 脚本链 | 手动分步 | 单脚本一键 |
| **灵活性** | ★★★★★ | ★★★ | ★★ | ★ |
| **自动化程度** | ★★ | ★★★★ | ★★★ | ★★★★★ |
| **可复现性** | ★★★ | ★★★★ | ★★ | ★★★★ |
| **门槛** | 低（纯FFmpeg+API） | 中（需装infsh） | 高（需多个skill） | 中（需Node.js） |

**aivp-pipeline 的核心差异化价值：**

1. **Agent-native 编排**：不是用固定脚本串联步骤，而是让 LLM agent 根据用户意图动态选择执行路径。这意味着 "Make a video about X" 和 "I have clips, just edit and publish" 使用同一个 skill 但走不同的路径。竞品要么全自动（remotion-excalidraw）要么全手动（ugc-campaign），缺乏这种弹性。

2. **9 步全覆盖**：从 ideation 到 publish 的完整覆盖，inference-sh 最多 5-6 步，ugc-campaign 6 步，remotion-excalidraw 仅 4 步。特别是 ideation（选题）和 review（审核）两步是 aivp 独有。

3. **反馈循环设计**：publish → ideation 的分析反馈是所有竞品都没有的。这代表了一个可持续的内容创作循环而非一次性 pipeline。

4. **元数据追踪**：per-shot generation params、execution log、cost estimate 的设计使得整个 pipeline 可审计、可复现。

### 5.5 具体改进建议

| 优先级 | 改进 | 参考来源 | 说明 |
|:------:|------|----------|------|
| P0 | 添加 pipeline.sh 编排脚本 | inference-sh workflows | 至少实现 `--from-step` 部分执行和日志记录 |
| P0 | 添加错误恢复机制 | inference-sh retry+fallback | 每步的 retry 逻辑 + 模型降级策略 |
| P1 | 实现实际的并行执行 | inference-sh parallel | image/video/audio 步骤可以用 bash `&` + `wait` 并行 |
| P1 | 添加成本计算模块 | ai-video-gen-tools cost table | 根据使用的模型和参数计算实际费用 |
| P1 | 添加 pipeline validate 命令 | — | 检查项目目录是否满足下一步执行条件 |
| P2 | 添加 cron 调度支持 | youtube-shorts-automation | 定时创建+发布视频 |
| P2 | 添加进度回调 | — | pipeline 执行中向用户频道报告进度 |
| P3 | 添加 A/B 测试支持 | — | 同主题生成多版本，比较效果 |

---

## 6. 交叉分析与战略建议

### 6.1 AIVP 套件整体 SWOT

**Strengths（优势）：**
- 唯一有独立 review 阶段的 AI 视频 pipeline
- 最完整的项目目录结构约定
- Agent-native 编排设计，灵活度最高
- 9 步全覆盖（ideation → publish），竞品最多 6 步
- 所有脚本都是可执行的 bash，依赖少（仅需 FFmpeg）

**Weaknesses（劣势）：**
- 缺少实际上传/发布能力（aivp-publish 最大短板）
- pipeline 层没有可执行脚本，纯文档
- 编辑能力相比 Remotion 系（转场、动画、文字效果）差距明显
- 缺少高级 FFmpeg 技巧（稳定化、色彩校正、硬件加速）
- 几个 SKILL.md 中提到的脚本实际不存在

**Opportunities（机会）：**
- review 阶段无竞品，可以做深做强成为独立卖点
- inference-sh 虽然 pipeline 强但审核+项目管理弱，互补空间大
- Remotion 需要 Node.js 环境，FFmpeg 方案的部署门槛低很多
- AI 生成视频的 review 需求会随着 AI 视频质量提升而增长

**Threats（威胁）：**
- inference-sh 有 7.2K 安装量和 37 个 skills，生态规模优势明显
- Remotion 官方 skill 有 102.6K 安装量，是 skills.sh 第一梯队
- AI 视频工具迭代快，新模型（Veo 3、Sora 2）可能让编辑需求减少

### 6.2 与 remotion-dev/skills 的结构对比

remotion-dev/skills 在 skills.sh 上有 4 个 skill，102.6K 总安装量：
1. `remotion-best-practices` — 核心技能，28+ 子规则
2. `3d` — Three.js 集成
3. `mediabunny` — 多媒体库
4. `remotion` — 基础 skill

**结构启示**：
- remotion-dev 将一个大 skill 拆成了 28+ 个细粒度规则文件，每个独立加载
- AIVP 采用了 9 个独立 skill 的方式，粒度在 skill 级别而非规则级别
- remotion-dev 的模式更适合"知识型"skill（LLM 按需加载规则）
- AIVP 的模式更适合"工具型"skill（每个 skill 有可执行脚本）

**建议**：在每个 aivp skill 内部也采用 references/ 目录存放细粒度知识文件（部分已有），让 LLM 可以按需加载。

### 6.3 优先级排序的改进路线图

#### Phase 1：补短板（1-2 周）
1. **修复已知 bug**：adjust-speed.sh atempo 限制、add-subtitles.sh 颜色参数、export.sh eval 安全
2. **补齐缺失脚本**：check-audio.sh、metadata 生成
3. **check-technical.sh 去 Python 依赖**：用 jq 替换

#### Phase 2：提升编辑能力（2-3 周）
4. **添加高级编辑脚本**：loudnorm、watermark、stabilize、color-correct
5. **多 clip 链式转场**
6. **FFmpeg 知识参考文档**（从 ffmpeg-master/insaiai 借鉴格式）

#### Phase 3：打通发布（3-4 周）
7. **YouTube API 上传脚本**
8. **AI 缩略图/封面生成**（集成 FLUX 或 DALL-E）
9. **人工确认流程**
10. **Markdown → 社交帖转换**

#### Phase 4：强化编排（4-5 周）
11. **pipeline.sh 编排脚本**（错误恢复、并行执行、日志）
12. **成本计算模块**
13. **进度回调**
14. **cron 调度支持**

### 6.4 竞品可直接借鉴的最佳实践

| 来源 | 实践 | 如何应用到 AIVP |
|------|------|----------------|
| ffmpeg-master | "When to Use" 决策表 | 在 aivp-edit 的 references/ 添加 FFmpeg 决策树 |
| remotion-best-practices | 模块化子规则文件 | 在 aivp-edit 的 references/ 添加 transitions.md、effects.md 等 |
| remotion-excalidraw | 一键 Python 脚本 | 为 aivp-pipeline 创建 make_video.py 一键脚本 |
| xiaohongshu-publisher | Draft→Review→Publish 流程 | 在 aivp-publish 强化人工确认和回退机制 |
| xiaohongshu-publisher | Pillow 封面图生成 | 移植 gen_cover.py 的设计模式到 aivp-publish |
| markdown-to-social | 纯 stdlib Python 工具 | 保持最少外部依赖的原则 |
| inference-sh | Pipeline 模式分类（5种） | 在 aivp-pipeline 文档中添加错误恢复、并行、条件分支等模式 |
| inference-sh | Building Blocks 模块化表 | 在 aivp-pipeline 中为每步列出可选模型/工具表 |
| ugc-campaign | 行业模板 | 添加不同视频类型（教程、产品、vlog、解说）的 pipeline 模板 |
| youtube-ultimate | 免费 transcript + 批量操作 | 在 aivp-ideation 中集成 YouTube 竞品分析 |

---

## 附录：竞品 SKILL.md 规模统计

| 竞品 | SKILL.md 字数 | 脚本数 | 子规则文件 | references |
|------|:------------:|:------:|:----------:|:----------:|
| aivp-edit | ~2,500 | 6 | 0 | 0 |
| aivp-review | ~1,200 | 1 | 0 | 1 (checklist) |
| aivp-publish | ~1,500 | 2 | 0 | 1 (platforms) |
| aivp-pipeline | ~2,800 | 0 | 0 | 0 |
| ffmpeg-master | ~1,800 | 0 | 0 | 0 |
| insaiai-editing | ~3,000 | 0 | 0 | 0 |
| remotion-best-practices | ~800（主文件） | 0 | 28+ | 0 |
| remotion-excalidraw | ~1,200 | 1 (Python) | 0 | 1 (schema) |
| xiaohongshu-publisher | ~1,500 | 1 (Python) | 0 | 2 |
| markdown-to-social | ~500 | 1 (Python) | 0 | 0 |
| ai-video-gen-tools | ~1,200 | ~5 (Python) | 0 | 0 |
| ugc-campaign-pipeline | ~2,000 | 0 | 0 | 0 |
| inference-sh/content-pipeline | ~2,500 | 0 | 0 | 0 |
| inference-sh/social-media | ~2,500 | 0 | 0 | 0 |
| inference-sh/automation | ~3,500 | 0 | 0 | 0 |

---

*调研完成。以上分析基于实际读取的完整 SKILL.md 文件、脚本源码和 skills.sh 页面内容。*
