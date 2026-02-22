# AIVP 前期制作阶段（Pre-production）竞品 Skill 深度调研

> 调研日期：2026-02-21
> 调研范围：aivp-ideation / aivp-script / aivp-storyboard 三个 skill 与市场上对标竞品的逐一对比

---

## 目录

1. [调研概览](#1-调研概览)
2. [竞品 Skill 清单与概述](#2-竞品-skill-清单与概述)
3. [aivp-ideation 对标分析](#3-aivp-ideation-对标分析)
4. [aivp-script 对标分析](#4-aivp-script-对标分析)
5. [aivp-storyboard 对标分析](#5-aivp-storyboard-对标分析)
6. [跨 Skill 系统性差距](#6-跨-skill-系统性差距)
7. [优先改进路线图](#7-优先改进路线图)

---

## 1. 调研概览

### 1.1 调研方法

- 逐行阅读本地 openclaw-skills 仓库中所有相关 SKILL.md
- skills.sh 站点搜索（hexiaochun、hhhh124hhhh、coreyhaines31 等作者）
- 用 `find` + `grep` 搜索本地所有包含 ideation/script/storyboard/剧本/分镜/角色/故事 关键词的 skill
- Web 搜索 AI video production workflow 相关 skill

### 1.2 核心发现

| 维度 | AIVP 现状 | 竞品最佳实践 | 差距评估 |
|------|-----------|-------------|---------|
| 落地可执行性 | 纯 LLM 驱动，无脚本/工具集成 | hexiaochun 全套：MCP 工具 + Python 脚本 + API 集成 | 🔴 严重差距 |
| 输出与下游衔接 | JSON 格式定义但无资产引用体系 | 三段式提示词 + @角色ID/SceneKey 引用 + 资产库 | 🔴 严重差距 |
| 内容垂直度 | 通用视频（YouTube/社媒） | 漫剧/短剧 + 电商 + 品牌故事，垂直细分 | 🟡 中等差距 |
| 质量保障 | 无 QC 流程 | QC 检查清单 + 优先级标签 (P0/P1/P2) | 🔴 严重差距 |
| 视觉一致性 | 仅 style_guide 概述 | 风格库(9种预定义) + STYLE_BASE/STYLE_VAR + 角色卡/道具卡 | 🔴 严重差距 |
| 端到端闭环 | 有 feedback loop 概念但无实现 | tcm-video-factory: 一条命令生成完整 plan | 🟡 中等差距 |

---

## 2. 竞品 Skill 清单与概述

### 2.1 直接竞品（高相关度）

| Skill | 作者 | 对标 AIVP 模块 | 核心能力 |
|-------|------|--------------|---------|
| novel-to-script | hexiaochun | aivp-script | 小说→漫剧剧本，四段式结构，镜头标注 |
| storyboard-generator | hexiaochun | aivp-storyboard | 剧本→分镜表，三段式提示词，@角色ID 引用 |
| character-creator | hexiaochun | (aivp 无对标) | 角色描述→肖像→10角度参考图，即梦4.5 |
| style-extractor | hexiaochun | (aivp 无对标) | 9种预定义风格库，STYLE_BASE/VAR 体系 |
| prop-extractor | hexiaochun | (aivp 无对标) | 道具提取→道具卡→道具提示词 |
| seedance-storyboard | hexiaochun | aivp-storyboard | 分镜创作→参考图生成→视频提交，全流程 |

### 2.2 间接竞品（部分重叠）

| Skill | 作者 | 对标 AIVP 模块 | 核心能力 |
|-------|------|--------------|---------|
| content-strategy | coreyhaines31 | aivp-ideation | 内容策略、关键词研究、买家旅程映射 |
| social-content | coreyhaines31 | aivp-ideation | 社媒内容规划、Hook 公式、内容日历 |
| brand-story-video | hhhh124hhhh | aivp-script | 品牌故事视频叙事弧模板 |
| cinematic-product-film | hhhh124hhhh | aivp-storyboard | 电影级产品视频运镜模板 |
| ai-video-gen-tools | hhhh124hhhh | 全流程 | 端到端 AI 视频生成（图→视频→配音→剪辑） |
| tcm-video-factory | xaotiensinh-abm | 全流程 | 一键生成视频生产计划（选题→剧本→角色→提示词） |

---

## 3. aivp-ideation 对标分析

### 3.1 功能覆盖对比表

| 功能 | aivp-ideation | content-strategy (coreyhaines31) | social-content (coreyhaines31) | tcm-video-factory |
|------|:---:|:---:|:---:|:---:|
| 趋势发现 | ✅ 多源（YouTube/Google/Reddit/X） | ✅ SEO 关键词 + 搜索意图 | ✅ 平台热点 + 竞品分析 | ✅ Perplexity API 自动研究 |
| 受众分析 | ✅ target_audience 字段 | ✅ ICP + 买家旅程四阶段 | ✅ 平台+受众匹配矩阵 | ⚠️ 基础 |
| 创意评分 | ✅ 4维评分(趋势/竞争/受众/难度) | ❌ | ❌ | ❌ |
| 内容日历 | ⚠️ 提及但无模板 | ✅ 内容支柱框架 | ✅ 完整周历模板 | ❌ |
| 竞品内容分析 | ✅ reference_videos 字段 | ✅ 竞品关键词分析 | ✅ 逆向工程病毒内容框架 | ❌ |
| 发布后分析 | ✅ metrics + learnings + next_actions | ❌ | ✅ 周度复盘模板 | ❌ |
| 数据源自动化 | ❌ 仅描述"Web search" | ❌ 纯 LLM | ❌ 纯 LLM | ✅ Perplexity API 调用 |
| Hook 模板 | ❌ | ❌ | ✅ 4类 Hook 公式(好奇/故事/价值/反常) | ❌ |
| 关键词研究 | ⚠️ keywords 字段但无方法论 | ✅ 完整 SEO 关键词方法论 | ❌ | ❌ |
| 可执行脚本 | ❌ | ❌ | ❌ | ✅ Node.js 脚本 |

### 3.2 竞品做得好的地方

#### content-strategy (coreyhaines31) — 内容策略方法论深度

**买家旅程四阶段关键词映射**（具体引用）：
```
### Awareness Stage
Modifiers: "what is," "how to," "guide to," "introduction to"

### Consideration Stage
Modifiers: "best," "top," "vs," "alternatives," "comparison"

### Decision Stage
Modifiers: "pricing," "reviews," "demo," "trial," "buy"

### Implementation Stage
Modifiers: "templates," "examples," "tutorial," "how to use," "setup"
```
→ AIVP 的 `keywords` 字段仅是一个列表，缺少按购买阶段分类和搜索意图分析的方法论。

**内容支柱框架**（具体引用）：
```
Content pillars are the 3-5 core topics your brand will own.
Good pillars should:
- Align with your product/service
- Match what your audience cares about
- Have search volume and/or social interest
- Be broad enough for many subtopics
```
→ AIVP 完全没有内容支柱（content pillar）的概念，无法帮用户建立长期内容体系。

#### social-content (coreyhaines31) — Hook 公式与内容复用

**Hook 公式库**（具体引用）：
```
### Curiosity Hooks
- "I was wrong about [common belief]."
- "The real reason [outcome] happens isn't what you think."

### Story Hooks
- "Last week, [unexpected thing] happened."
- "3 years ago, I [past state]. Today, [current state]."

### Contrarian Hooks
- "Unpopular opinion: [bold statement]"
- "I stopped [common practice] and [positive result]."
```
→ AIVP 仅要求在 `hook` 字段写一句话，但没有提供任何 Hook 写作方法论或模板。

**内容复用体系**（具体引用）：
```
Blog Post → Social Content:
- LinkedIn: Key insight + link in comments
- Twitter/X: Thread of key takeaways
- Instagram: Carousel with visuals / Reel summarizing
```
→ AIVP 每次创意都是独立的，没有"一鱼多吃"的内容复用策略。

#### tcm-video-factory — 自动化闭环

**一条命令生成完整计划**（具体引用）：
```bash
node skills/tcm-video-factory/index.mjs "Trà gừng mật ong"
```
输出包含：选定主题 → 角色设计提示词 → 4段脚本(32秒) → 首尾帧图像提示词 → VEO3 视频提示词。

→ AIVP ideation 是纯 LLM skill，无任何可执行脚本，不能自动调用趋势 API，不能自动化执行。

### 3.3 我们的差距

| 差距 | 严重度 | 说明 |
|------|:------:|------|
| 无数据源自动化 | 🔴 | 仅描述 "Web search for trending topics"，不如 tcm-video-factory 的 Perplexity API 集成 |
| 无 Hook 方法论 | 🟡 | hook 字段只是一行文字，无写作框架和公式模板 |
| 无内容支柱体系 | 🟡 | 每次创意是孤立的，无法构建长期内容策略 |
| 无关键词研究方法论 | 🟡 | keywords 字段无搜索意图分类，无买家旅程映射 |
| 无内容复用策略 | 🟡 | 一个创意只产出一个视频，无多平台复用规划 |
| 反馈循环仅概念 | 🟡 | 有 feedback loop 图示但无自动化采集和分析流程 |
| 评分权重不可定制 | 🟢 | 固定 30/25/25/20 权重，不同领域可能需要不同权重 |

### 3.4 具体改进建议

#### 建议 1：引入 Hook 公式库

在 ideation 输出模板中增加 hook 类型和模板：

```json
{
  "hook": {
    "type": "curiosity",
    "template": "I was wrong about [X]",
    "text": "I was wrong about morning routines — here's what actually works",
    "alternatives": [
      "The real reason 90% of morning routines fail",
      "Stop waking up at 5 AM. Do this instead."
    ]
  }
}
```

新增 `references/hook-formulas.md` 文件，包含至少 20 个经过验证的 Hook 模板。

#### 建议 2：增加内容支柱规划

新增 content pillar planning 功能：

```json
{
  "content_pillars": [
    {
      "pillar": "AI productivity",
      "sub_topics": ["prompt engineering", "workflow automation", "AI tools review"],
      "search_volume": "high",
      "competition": "medium",
      "content_ratio": "30%"
    }
  ],
  "ideas": [
    {
      "title": "...",
      "pillar": "AI productivity",
      "buyer_stage": "awareness",
      "search_intent": "informational"
    }
  ]
}
```

#### 建议 3：增加趋势数据自动化脚本

参考 tcm-video-factory，添加自动趋势研究脚本：

```bash
# scripts/trend_research.py
python scripts/trend_research.py --niche "AI tools" --platforms youtube,reddit,twitter
```

通过 web_search 工具自动获取趋势数据，填充 `trending_score`，而非依赖 LLM 猜测。

#### 建议 4：增加内容复用规划

在 idea 输出中增加多平台适配建议：

```json
{
  "repurpose_plan": {
    "primary": {"platform": "youtube", "format": "long_form", "duration": "8:00"},
    "derived": [
      {"platform": "tiktok", "format": "short", "angle": "hook + key insight", "duration": "0:60"},
      {"platform": "twitter", "format": "thread", "angle": "5 key takeaways"},
      {"platform": "instagram", "format": "carousel", "angle": "visual summary"}
    ]
  }
}
```

---

## 4. aivp-script 对标分析

### 4.1 功能覆盖对比表

| 功能 | aivp-script | novel-to-script (hexiaochun) | brand-story-video (hhhh124hhhh) | tcm-video-factory |
|------|:---:|:---:|:---:|:---:|
| 场景拆分 | ✅ scenes 数组 | ✅ 场标题行(场号+地点+时间) | ⚠️ 叙事弧分段 | ✅ 4段式 |
| 旁白/台词 | ✅ narration 字段 | ✅ 台词格式(对白/VO/OS) + 音效/BGM | ❌ 仅概述 | ✅ 含配音标注 |
| 画面指导 | ✅ visual_direction 字段 | ✅ ▲镜头描述(景别/运动/动作/表情) | ⚠️ "Visual style" 概述 | ✅ 首尾帧提示词 |
| 情绪/节奏 | ✅ mood 字段 | ✅ 四段式节奏(钩子/升级/反转/续看) | ✅ 叙事弧5段 | ⚠️ 隐含 |
| 转场 | ✅ transition 字段 | ✅ 【切镜】标记 | ❌ | ❌ |
| 角色管理 | ❌ | ✅ 人物表 + 角色简要描述 | ❌ | ✅ 角色设计提示词 |
| 镜头语言 | ⚠️ visual_direction 自由文本 | ✅ ▲ 标注(景别/运动/表情) | ✅ 电影运镜(dolly/crane/tracking) | ❌ |
| 特殊标记 | ❌ | ✅ 闪回/切镜/音效/BGM/特效/字幕/系统 | ❌ | ❌ |
| 心理描写转化 | ❌ | ✅ 小说OS→剧本OS 转换规则 | ❌ | ❌ |
| 冲突设计 | ❌ | ✅ 每场必须有Turn/Result | ❌ | ❌ |
| 结构公式 | ⚠️ 6种style但无结构公式 | ✅ "主角为了【目标】在【规则/限制】下被【对手/压力】逼到【困境】" | ✅ 叙事弧公式 | ✅ 4段 |
| 转换检查清单 | ❌ | ✅ 6项必查清单 | ❌ | ❌ |
| 文件保存规范 | ⚠️ 目录约定但无自动保存 | ✅ 自动保存为txt(编码/路径/命名规范) | ❌ | ✅ 自动保存 PLAN.md |
| 输入源多样性 | ⚠️ 仅"用户话题" | ✅ 小说/网文内容转化 | ⚠️ 品牌信息 | ✅ 关键词自动研究 |
| 多语言台词 | ❌ | ✅ 中文优化 | ✅ 英文 | ❌ |
| 配音适配 | ⚠️ ~150 wpm 提示 | ✅ "台词短句化，便于配音切条" | ❌ | ✅ Lip-sync 标注 |

### 4.2 竞品做得好的地方

#### novel-to-script (hexiaochun) — 剧作法深度

**四段式节奏公式**（具体引用）：
```
1. 钩子段：前10秒必须抓住观众
2. 升级段：每30-60秒需有增量点
3. 反转/爽点段：兑现情绪承诺
4. 续看段：抛出新悬念
```
→ AIVP 仅提供 6 种 style 标签（documentary/listicle/tutorial/story/commercial/interview），但每种 style 没有对应的结构公式。

**"一句话"结构公式**（具体引用）：
```
本集一句话：主角为了【目标】在【规则/限制】下，
被【对手/压力】逼到【困境】，
最后【变化】并引出【续看问题】
```
→ 这是一个强制性的剧本结构检验工具。AIVP 的 script 缺少这种"一句话检验"的质量门槛。

**镜头动作标注系统**（具体引用）：
```
▲近景，楚风猛然睁开眼，眼中闪过一丝精光
▲全景，众人围成一圈，气氛紧张
```
→ AIVP 的 `visual_direction` 是自由文本，缺乏规范化的景别/运动/表情标注语法。

**特殊标记系统**（具体引用）：
```
【闪回】...【闪出】：回忆片段
【切镜】：转场
音效：声音效果
BGM：背景音乐
特效：视觉效果
字幕：时间/地点字幕
系统：系统提示音
```
→ AIVP 仅有 `transition` 字段，缺少音效、BGM、特效、闪回等丰富的标记类型。

**素材转化规则**（具体引用）：
```
小说心理描写 → 剧本OS
小说环境描写 → 画面+镜头
小说对话 → 标准台词
小说动作 → 镜头动作
```
→ AIVP 完全没有处理不同输入源（小说/文章/大纲）转化为剧本的方法论。

#### brand-story-video (hhhh124hhhh) — 叙事弧设计

**5段叙事弧**（具体引用）：
```
Narrative arc:
- 0-10s: Introduction (brand values, mission)
- 10-25s: The problem (customer pain point)
- 25-40s: The solution (how product helps)
- 40-50s: The transformation (real-world impact)
- 50-60s: The vision (future outlook)
```
→ 虽然简单，但它为每种时长提供了精确的时间分配模板。AIVP 仅有 `duration` 字段但无时间分配建议。

#### tcm-video-factory — 角色与剧本一体化

**角色设计与剧本同步生成**（具体引用）：
```
Output includes:
2. Character Design Prompt (Pixar 3D)
3. 4-Part Script (32s total)
4. Image Prompts (Start/End for each part)
```
→ 角色设计在脚本生成阶段就完成，确保角色外观与剧本一致。AIVP 的 script 完全不涉及角色视觉设计。

### 4.3 我们的差距

| 差距 | 严重度 | 说明 |
|------|:------:|------|
| 无剧作结构公式 | 🔴 | 6 种 style 标签仅是分类，缺少每种类型的结构公式和节奏模板 |
| 无角色管理 | 🔴 | 剧本中没有人物表、角色描述、角色 ID 体系 |
| 镜头标注不规范 | 🟡 | visual_direction 是自由文本，缺少 ▲ 标注系统或等效的规范化语法 |
| 无特殊标记系统 | 🟡 | 缺少闪回/音效/BGM/特效等丰富标记 |
| 无输入转化方法论 | 🟡 | 不能处理小说、文章、大纲等多种输入源的转化 |
| 无质量检查清单 | 🔴 | novel-to-script 有 6 项必查清单，AIVP 无 |
| 无情绪承诺设计 | 🟡 | 缺少"情绪承诺"概念（打脸爽/逆袭爽/虐爽/治愈爽） |
| 无配音适配规范 | 🟢 | 仅提到 150wpm，缺少"短句化便于切条"等具体规范 |

### 4.4 具体改进建议

#### 建议 1：为每种 style 增加结构公式

```json
{
  "style": "story",
  "structure_formula": {
    "one_liner": "主角为了【{goal}】在【{constraint}】下，被【{pressure}】逼到【{dilemma}】，最后【{change}】并引出【{cliffhanger}】",
    "rhythm": [
      {"segment": "hook", "duration_pct": "0-10%", "purpose": "抓住注意力"},
      {"segment": "escalation", "duration_pct": "10-50%", "purpose": "每30秒一个增量点"},
      {"segment": "climax", "duration_pct": "50-80%", "purpose": "兑现情绪承诺"},
      {"segment": "cliffhanger", "duration_pct": "80-100%", "purpose": "续看悬念"}
    ]
  },
  "style": "listicle",
  "structure_formula": {
    "one_liner": "【{number}】个【{topic}】让你【{benefit}】",
    "rhythm": [
      {"segment": "hook", "duration_pct": "0-8%", "purpose": "最震撼的那个数据/案例"},
      {"segment": "items", "duration_pct": "8-90%", "purpose": "逐项展开，每项等时"},
      {"segment": "cta", "duration_pct": "90-100%", "purpose": "总结 + 行动号召"}
    ]
  }
}
```

#### 建议 2：增加角色表（Character Table）

在 script 输出中增加 characters 段：

```json
{
  "characters": [
    {
      "char_id": "@host",
      "name": "主持人",
      "role": "narrator",
      "appearance": "30岁男性，蓝色衬衫，专业形象",
      "voice_style": "温暖、权威",
      "scenes": ["01", "02", "05"]
    }
  ],
  "scenes": [
    {
      "scene_id": "01",
      "characters_present": ["@host"],
      "narration": "...",
      "visual_direction": "..."
    }
  ]
}
```

#### 建议 3：规范化镜头标注语法

借鉴 novel-to-script 的 `▲` 系统，在 `visual_direction` 中引入结构化字段：

```json
{
  "visual_direction": {
    "shot_description": "楚风猛然睁开眼，眼中闪过精光",
    "shot_size": "close_up",
    "camera_movement": "slow_push",
    "subject_action": "睁眼 → 表情凝重",
    "sfx": "心跳声",
    "bgm": "紧张弦乐渐入",
    "vfx": null
  }
}
```

#### 建议 4：增加质量检查清单

在 SKILL.md 末尾增加强制自检项：

```markdown
## 脚本质量检查清单

每个场景必须满足：
- [ ] 场景有明确的推进点（冲突/反转/信息点）
- [ ] 旁白短句化（≤20字/句），便于 TTS 切条
- [ ] visual_direction 包含景别和主体动作
- [ ] 有 mood 标注，且与前后场景形成对比节奏
- [ ] 时长在 10-30s 范围内
- [ ] Hook 在前 5 秒内出现
- [ ] 结尾有 CTA 或续看悬念
```

---

## 5. aivp-storyboard 对标分析

### 5.1 功能覆盖对比表

| 功能 | aivp-storyboard | storyboard-generator (hexiaochun) | seedance-storyboard (hexiaochun) | cinematic-product-film (hhhh124hhhh) |
|------|:---:|:---:|:---:|:---:|
| 景别体系 | ✅ 7种(extreme_wide→extreme_close_up) | ✅ 5种(远景→特写) + 选择指南 | ⚠️ 隐含在提示词中 | ✅ wide/dynamic/hero |
| 机位体系 | ✅ 5种(eye_level→dutch_angle) | ✅ 5种 + 情绪效果映射 | ⚠️ 隐含 | ⚠️ 隐含 |
| 运镜体系 | ✅ 7种(static→orbit) | ✅ 5种(静止→跟拍) | ✅ 推/拉/摇/移/跟/环绕/升降 | ✅ dolly/crane/tracking |
| 提示词生成 | ✅ prompt 字段 | ✅ 三段式(风格+主体+画面) | ✅ 三段式 + @引用语法 | ⚠️ 概述性 |
| 负向提示词 | ❌ | ✅ 通用负向提示词列表 | ❌ | ❌ |
| 资产引用体系 | ❌ | ✅ @角色ID + SceneKey + PropKey | ✅ @image_file_N/@video_file_N | ❌ |
| 风格一致性 | ⚠️ style_guide 概述 | ✅ STYLE_BASE 引用(来自 style-extractor) | ✅ 分镜前确定风格 | ⚠️ "Consistent brand identity" |
| 角色一致性 | ❌ | ✅ @角色ID 形象描述引用 | ✅ 角色图生成 + 参考 | ❌ |
| 导演三帧法 | ❌ | ✅ 起帧(KF_A)/爆帧(KF_B)/钩帧(KF_C) | ❌ | ❌ |
| 优先级标签 | ❌ | ✅ P0/P1/P2 优先级 | ❌ | ❌ |
| QC 检查清单 | ❌ | ✅ P0/P1/P2 三级检查 | ❌ | ❌ |
| 镜头密度规划 | ❌ | ✅ 18镜头/集默认分布 | ❌ | ❌ |
| 唯一信息点 | ❌ | ✅ 每镜头只传达1个信息点 | ❌ | ❌ |
| 定格瞬间 | ❌ | ✅ "一眼看懂"的可截图瞬间 | ❌ | ❌ |
| 动作链 | ❌ | ✅ 2-4步可视化动作链 | ❌ | ❌ |
| 多模型适配 | ❌ | ✅ banana版 + 即梦版 双版本提示词 | ✅ Seedream + Seedance 适配 | ⚠️ Sora2 专用 |
| HTML 画廊输出 | ❌ | ✅ 自动生成 HTML 展示页 | ❌ | ❌ |
| 视频生成集成 | ❌ | ❌ (仅分镜表) | ✅ 完整视频提交+轮询 | ❌ |
| 图像生成集成 | ❌ | ❌ (仅提示词) | ✅ Seedream 4.5 生图 | ❌ |
| 轴线规则 | ❌ | ✅ QC 检查"是否有轴线跳跃？" | ❌ | ❌ |

### 5.2 竞品做得好的地方

#### storyboard-generator (hexiaochun) — 专业分镜方法论

**导演三帧法**（具体引用）：
```
为每场生成 3 张关键帧：
- 起帧(KF_A)：建立环境与关系
- 爆帧(KF_B)：冲突/动作爆点
- 钩帧(KF_C)：悬念/转场/情绪余波
```
→ 这是一个极其高效的分镜框架。AIVP 仅说"2-4 shots per scene"但无方法论指导如何选择关键帧。

**三段式提示词拼装规则（强制）**（具体引用）：
```
最终提示词 = 风格段 + 主体段 + 画面段

风格段 → STYLE_BASE 风格一句话
主体段 → @角色ID 形象描述 + 表情动作增量
画面段 → SceneKey 场景描述 + 景别机位 + 定格瞬间
```
→ AIVP 的 `prompt` 字段是自由文本，每次生成可能风格飘移。三段式强制引用资产库是确保一致性的关键。

**唯一信息点原则**（具体引用）：
```
叙事层对齐：每镜头只交代 1 个"唯一信息点"
```
→ AIVP 没有这个约束，可能导致镜头信息过载或不清晰。

**P0/P1/P2 优先级体系**（具体引用）：
```
P0（必须修复 - 影响剪辑）：缺建立/反应/转场镜头？定格瞬间"一眼看懂"？
P1（第二优先 - 影响一致性）：角色脸/服装是否漂移？道具是否一致？
P2（最后修复 - 美观问题）：画面干净？光影统一？电影化？
```
→ AIVP 完全没有质量分级体系，无法指导生产优先级。

**18 镜头默认分布**（具体引用）：
```
每集建议 18 镜头分布：
1-1 场（约 6 镜头）
├── 建立镜头 ×1（环境/关系）
├── 信息镜头 ×1（关键道具/人物）
├── 动作镜头 ×2（主要动作）
├── 反应镜头 ×1（情绪反应）
└── 转场镜头 ×1（切出/悬念）
```
→ 具体的镜头类型分布指南，比 AIVP "2-4 shots per scene" 有用得多。

**双模型适配**（具体引用）：
```
提示词（banana版 - 构图优先）：风格段 + 主体段 + 景别机位构图
提示词（即梦版 - 画风优先）：风格段 + 主体段 + 光线材质氛围
```
→ 针对不同 AI 生图模型优化提示词，AIVP 的 prompt 是通用的，没有模型适配。

#### seedance-storyboard (hexiaochun) — 端到端执行

**分镜创作到视频生成的完整工作流**（具体引用）：
```
Step 1: 理解用户想法
Step 2: 深入挖掘（5个维度：内容/视觉/镜头/动作/声音）
Step 3: 构建分镜结构
Step 4: 生成参考图（Seedream 4.5）
Step 5: 生成专业提示词
Step 6: 提交视频任务（Seedance 2.0）
Step 7: 轮询等待视频结果
```
→ 从创意到成片的全流程，包含 MCP 工具调用 + 脚本模式 fallback。AIVP storyboard 仅生成 JSON，无任何下游执行能力。

**@引用语法**（具体引用）：
```
@image_file_1 作为角色形象参考，参考 @video_file_1 的运镜方式，配合 @audio_file_1 的配乐
```
→ 提示词中直接引用素材文件，确保生成结果与参考素材对齐。

#### 配套 skill 生态 — style-extractor / character-creator / prop-extractor

hexiaochun 构建了完整的**资产管理生态**：

1. **style-extractor**：9 种预定义风格 + STYLE_BASE/STYLE_VAR 变体体系
2. **character-creator**：角色描述 → 肖像 → 10 角度参考图 → HTML 画廊
3. **prop-extractor**：道具提取 → 道具卡(PropKey) → 道具提示词 → HTML 展示

这三个 skill 为 storyboard-generator 提供了稳定的资产引用基础。AIVP 没有任何等效的资产管理 skill。

### 5.3 我们的差距

| 差距 | 严重度 | 说明 |
|------|:------:|------|
| 无资产引用体系 | 🔴 | 缺少 @角色ID/SceneKey/PropKey，每镜头风格可能飘移 |
| 无导演三帧法 | 🔴 | 缺少 KF_A/KF_B/KF_C 关键帧方法论 |
| 无三段式提示词 | 🔴 | prompt 是自由文本，不能保证跨镜头一致性 |
| 无 QC 检查体系 | 🔴 | 缺少 P0/P1/P2 优先级和检查清单 |
| 无唯一信息点原则 | 🟡 | 可能导致镜头信息过载 |
| 无负向提示词 | 🟡 | 生成图像可能出现不期望的元素 |
| 无镜头密度规划 | 🟡 | "2-4 shots" 太模糊，缺少类型分布指南 |
| 无多模型适配 | 🟡 | 不同 AI 模型需要不同风格的提示词 |
| 无 HTML 展示输出 | 🟢 | 缺少可视化分镜画廊 |
| 无下游执行集成 | 🔴 | 仅输出 JSON，不能调用生图/生视频 API |
| 无配套资产管理 skill | 🔴 | 缺少 style-extractor / character-creator / prop-extractor 等效能力 |

### 5.4 具体改进建议

#### 建议 1：引入三段式提示词体系

替换当前自由文本 `prompt` 为结构化三段式：

```json
{
  "prompt_structured": {
    "style_segment": "{STYLE_BASE}",
    "subject_segment": "{@char_id} 形象描述，{本镜头表情动作}",
    "scene_segment": "{scene_key} 场景描述，{景别}，{机位}，{定格瞬间}"
  },
  "prompt_compiled": "二次元国风仙侠风格，@hero 黑发少年白衣剑客，眼神凌厉握剑前指，妖兽谷悬崖边，近景，仰视，剑尖指向画面外，高清细节",
  "negative_prompt": "文字、水印、logo、现代建筑、血腥特写、肢体畸形"
}
```

#### 建议 2：增加导演三帧法

在场景分镜中强制生成三个关键帧：

```json
{
  "scene_id": "01",
  "director_frames": {
    "KF_A": {
      "purpose": "establish",
      "info_point": "展示悬崖边的荒凉环境",
      "freeze_moment": "远景中一个小小的人影站在悬崖边",
      "shot_type": "extreme_wide",
      "camera_angle": "bird_eye"
    },
    "KF_B": {
      "purpose": "action",
      "info_point": "少年拔剑迎战",
      "freeze_moment": "剑出鞘的瞬间，剑身反射光芒",
      "shot_type": "close_up",
      "camera_angle": "low_angle"
    },
    "KF_C": {
      "purpose": "hook",
      "info_point": "更大的敌人出现",
      "freeze_moment": "少年回头看，瞳孔倒映出巨大阴影",
      "shot_type": "extreme_close_up",
      "camera_angle": "eye_level"
    }
  },
  "shots": [...]
}
```

#### 建议 3：增加 P0/P1/P2 优先级和 QC 体系

在每个 shot 上增加优先级和状态字段：

```json
{
  "shot_id": "01",
  "priority": "P0",
  "status": "todo",
  "qc_checklist": {
    "single_info_point": true,
    "freeze_moment_clear": true,
    "no_axis_jump": true,
    "asset_refs_valid": true
  }
}
```

在 SKILL.md 中增加 QC 检查清单：

```markdown
## QC 检查清单

### P0（必须修复 - 影响剪辑）
- [ ] 是否缺建立/反应/转场镜头？
- [ ] 每镜头是否只有 1 个唯一信息点？
- [ ] 定格瞬间是否"一眼看懂"？
- [ ] 是否有轴线跳跃？

### P1（影响一致性）
- [ ] 角色外观是否保持一致？
- [ ] 场景锚点是否保持？
- [ ] 提示词是否引用 STYLE_BASE？

### P2（美观问题）
- [ ] 景别是否有节奏变化？
- [ ] 光影是否统一？
- [ ] 画面是否足够电影化？
```

#### 建议 4：增加镜头密度规划模板

```json
{
  "shot_density_plan": {
    "target_per_scene": 4,
    "distribution": {
      "establishing": 1,
      "information": 1,
      "action": 1,
      "reaction_or_transition": 1
    }
  }
}
```

#### 建议 5：创建配套资产管理 skill

规划创建以下配套 skill（优先级从高到低）：

1. **aivp-character**：角色卡管理，包含 char_id、外观描述、提示词模板
2. **aivp-style**：风格库管理，STYLE_BASE/STYLE_VAR 体系
3. **aivp-assets**：道具/场景/BGM 资产管理

---

## 6. 跨 Skill 系统性差距

### 6.1 资产管理体系缺失

hexiaochun 的 skill 生态形成了完整的资产流水线：

```
style-extractor → STYLE_BASE/VAR
character-creator → @角色ID + 多角度参考图
prop-extractor → PropKey + 道具提示词
         ↓              ↓            ↓
         └──────── storyboard-generator ────────→ 三段式提示词
```

AIVP 的 skill 之间仅通过 JSON 字段松散连接，缺少统一的资产引用体系。

**改进方向**：定义统一的资产 ID 命名规范，在 ideation→script→storyboard 全链路中保持引用一致。

### 6.2 可执行性差距

| 维度 | AIVP | 竞品最佳实践 |
|------|------|-------------|
| 脚本支持 | ❌ 无 | ✅ tcm-video-factory (Node.js)、seedance-storyboard (Python) |
| MCP 工具集成 | ❌ 无 | ✅ hexiaochun 的 MCP submit_task/get_task |
| API 集成 | ❌ 无 | ✅ Perplexity (趋势)、Seedream/Seedance (生图/生视频) |
| 自动轮询 | ❌ 无 | ✅ seedance-storyboard 的 poll 命令 |
| HTML 输出 | ❌ 无 | ✅ storyboard-generator、character-creator 自动生成画廊 |

**改进方向**：为每个 skill 至少提供一个可执行脚本，实现关键流程自动化。

### 6.3 质量保障体系缺失

| 维度 | AIVP | hexiaochun 竞品 |
|------|------|----------------|
| 检查清单 | ❌ | ✅ 每个 skill 都有自检清单 |
| 优先级分级 | ❌ | ✅ P0/P1/P2 |
| 结构公式 | ❌ | ✅ 四段式节奏、一句话公式 |
| 信息密度控制 | ❌ | ✅ 唯一信息点原则 |
| 轴线规则 | ❌ | ✅ QC 检查项 |

**改进方向**：在每个 skill 的 SKILL.md 末尾增加强制自检清单。

---

## 7. 优先改进路线图

### P0 — 立即改进（影响核心可用性）

| 编号 | 改进项 | 目标 Skill | 预计工作量 | 参考竞品 |
|:----:|--------|-----------|:----------:|---------|
| 1 | 引入三段式提示词体系 | storyboard | 1天 | storyboard-generator |
| 2 | 增加 QC 检查清单 | script + storyboard | 0.5天 | storyboard-generator, novel-to-script |
| 3 | 为每种 script style 增加结构公式 | script | 1天 | novel-to-script |
| 4 | 增加角色表（characters）到 script 输出 | script | 0.5天 | novel-to-script |
| 5 | 增加导演三帧法 | storyboard | 0.5天 | storyboard-generator |

### P1 — 短期改进（提升专业度）

| 编号 | 改进项 | 目标 Skill | 预计工作量 | 参考竞品 |
|:----:|--------|-----------|:----------:|---------|
| 6 | 创建 aivp-character skill | 新 skill | 2天 | character-creator |
| 7 | 创建 aivp-style skill | 新 skill | 1天 | style-extractor |
| 8 | 增加 Hook 公式库 | ideation | 0.5天 | social-content |
| 9 | 增加负向提示词模板 | storyboard | 0.5天 | storyboard-generator |
| 10 | 增加 P0/P1/P2 优先级体系 | storyboard | 0.5天 | storyboard-generator |
| 11 | 增加镜头密度规划 | storyboard | 0.5天 | storyboard-generator |
| 12 | 规范化 visual_direction 为结构化字段 | script | 1天 | novel-to-script |

### P2 — 中期改进（增强差异化）

| 编号 | 改进项 | 目标 Skill | 预计工作量 | 参考竞品 |
|:----:|--------|-----------|:----------:|---------|
| 13 | 增加内容支柱规划 | ideation | 1天 | content-strategy |
| 14 | 增加内容复用策略 | ideation | 0.5天 | social-content |
| 15 | 增加多模型提示词适配 | storyboard | 1天 | storyboard-generator |
| 16 | 增加 HTML 画廊输出 | storyboard | 1天 | storyboard-generator |
| 17 | 增加趋势数据自动化脚本 | ideation | 2天 | tcm-video-factory |
| 18 | 增加特殊标记系统(闪回/音效/BGM) | script | 0.5天 | novel-to-script |
| 19 | 创建 aivp-assets skill (道具/场景管理) | 新 skill | 2天 | prop-extractor |

---

## 附录：竞品 Skill 源文件索引

| Skill | 路径/来源 |
|-------|----------|
| novel-to-script | `openclaw-skills/skills/hexiaochun/novel-to-script/SKILL.md` |
| storyboard-generator | `openclaw-skills/skills/hexiaochun/storyboard-generator/SKILL.md` |
| character-creator | `openclaw-skills/skills/hexiaochun/character-creator/SKILL.md` |
| style-extractor | `openclaw-skills/skills/hexiaochun/style-extractor/SKILL.md` |
| prop-extractor | `openclaw-skills/skills/hexiaochun/prop-extractor/SKILL.md` |
| seedance-storyboard | `skills.sh/hexiaochun/seedance2-api/seedance-storyboard` |
| brand-story-video | `openclaw-skills/skills/hhhh124hhhh/brand-story-video/SKILL.md` |
| cinematic-product-film | `openclaw-skills/skills/hhhh124hhhh/cinematic-product-film/SKILL.md` |
| ai-video-gen-tools | `openclaw-skills/skills/hhhh124hhhh/ai-video-gen-tools/SKILL.md` |
| content-strategy | `skills.sh/coreyhaines31/marketingskills/content-strategy` |
| social-content | `skills.sh/coreyhaines31/marketingskills/social-content` |
| tcm-video-factory | `openclaw-skills/skills/xaotiensinh-abm/tcm-video-factory/SKILL.md` |
