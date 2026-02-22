# AIVidPipeline Skills 开发日志

## 2026-02-21 竞品调研

### 目标
调研 Vercel skills.sh 和 OpenClaw ClaWHub 上的竞品 skill，逐个对比，形成优化方向。

### 调研报告
- **Skills.sh 平台**：[research-skills-sh.md](research-skills-sh.md)
- **ClaWHub 平台**：[research-clawhub.md](research-clawhub.md)

---

### 竞品全景总结

#### 三大竞品势力

| 势力 | 平台 | 特点 | 规模 |
|------|------|------|------|
| **inference-sh** | skills.sh | 150+ AI 应用统一 CLI，~15 个视频相关 skill | 依赖 infsh 付费平台 |
| **hexiaochun（速推AI）** | ClaWHub | 32 个 skill，模型覆盖最全，文档极详细 | 依赖速推AI MCP 后端 |
| **Remotion 官方** | skills.sh | 102K 安装量 #4，28 个子规则，React 视频制作 | 代码驱动，非 AI 生成 |

#### 关键发现

1. **没有真正的端到端 pipeline**——aivp-pipeline 是两个平台上唯一完整的 10 步编排方案
2. **竞品全部依赖特定后端**——inference-sh 绑 infsh，hexiaochun 绑速推AI，我们有独立可执行脚本
3. **文档深度差距明显**——hexiaochun 每个模型有参数表+定价表+示例，我们只有用法说明
4. **口型同步/声音克隆是盲区**——hexiaochun 有 OmniHuman/DreamActor/声音克隆，我们完全缺失
5. **skills.sh 已原生支持 OpenClaw**——应双平台发布获取曝光

#### aivp 核心优势（必须坚持）

- ✅ 端到端 pipeline 唯一性
- ✅ 开源可执行，不依赖特定平台
- ✅ 模块化标准数据流
- ✅ agent-native 编排（agent 决定步骤，非固定流程）

#### 需要补强的方向（按优先级）

| 优先级 | 方向 | 参考 | 涉及 skill |
|--------|------|------|-----------|
| 🔴 | 模型文档深度（参数表+定价+最佳实践） | hexiaochun | aivp-video, aivp-image, aivp-audio |
| 🔴 | 口型同步/动作迁移 | omnihuman, dreamactor | 新增 aivp-lipsync |
| 🔴 | 声音克隆/多人对话 TTS | minimax-audio, sutui-minimax-tts | aivp-audio |
| 🟡 | 角色一致性系统 | character-creator | aivp-image |
| 🟡 | 分镜深度（三帧法+提示词三段式） | storyboard-generator | aivp-storyboard |
| 🟡 | 预设模板库 | nano-hub, brand-story-video | aivp-pipeline |
| 🟡 | Remotion 集成 | remotion-excalidraw-tts | aivp-edit |
| 🟢 | 素材管理 skill | cdn-url-transfer | 新增 aivp-assets |
| 🟢 | 社交平台发布 | xiaohongshu-publisher, twitter-automation | aivp-publish |

### 反思

**我们做对了什么**：pipeline 编排 + 模块化 + 标准数据流，这个架构方向是对的，竞品都没做到。

**我们忽略了什么**：
1. 文档不是"能用就行"——hexiaochun 的文档质量说明，面向 agent 的 SKILL.md 本身就是产品，参数表和定价表直接影响 agent 决策质量
2. 视频制作不只是"生成"——口型同步、动作迁移、声音克隆是内容创作者的刚需，我们完全没覆盖
3. 模板比工具更重要——用户想要的是"帮我做一个产品介绍视频"，不是"给我一个 text-to-video 的接口"

**下一步**：先把文档深度补上来（成本最低、收益最高），然后加口型同步能力，再做模板库。

---
