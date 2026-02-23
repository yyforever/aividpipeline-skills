# Lessons: aivp-script

## 实测教训（2026-02-22）

### 教训 1: 双格式 prompts 需明确各自用途
- Shot Decomposition（帧分解）→ 给 aivp-image 和 aivp-storyboard 用
- Multi-Shot Prompts → 给 aivp-video 直接粘贴到 Kling 3.0 用
- 两者覆盖相同场景但格式不同，必须保持同步
- **原始 v0.2 没说清这个关系，测试时产生了混淆**

### 教训 2: 对话格式要统一且可验证
- Kling 3.0 对话格式：`[Character Name, tone]: "text"`
- 角色名必须和 character sheet 完全一致（不是 Role，是 Name）
- 这是可自动检查的——quality checks 应包含

### 教训 3: 首帧/末帧必须是静态描述
- 来自 ViMax 架构的核心洞察：视频模型做的是"两帧之间的插值"
- first-frame 和 last-frame 都不能有动词（"walking" → "standing mid-stride"）
- Motion 字段专门描述变化过程
- 测试中 Shot 2.1 的 last-frame 写了 "walking"——违反了这条规则

### 教训 4: variation type 指导下游整个流程
- small: 只需 1 张参考图 → image skill 只生成 first-frame
- medium/large: 需要 2 张 → image skill 生成 first + last frame
- 这个标注在 script 阶段就确定，影响 image/video 两个下游 skill 的工作量
- 18 个 shot 中：7 small (39%), 8 medium (44%), 3 large (17%) — 合理分布

### 教训 5: plan-template 语言可以和 script 不同
- plan.md 是内部工具，中文没问题（给自己看的）
- script/prompts 跟随 brief 的语言设定
- 不需要统一

### 教训 6: 参考项目架构分析价值极高
- ViMax 的 shot decomposition + variation type 是最有价值的借鉴
- Huobao 的 emotion intensity markers（↑↑↑/↑↑/↑/→/↓）让 pacing map 更精确
- **先分析再设计** >> 闭门造车

### 教训 7: 测试输出的结构验证
- 三层输出（plan/notes/deliverable）需要实际跑一遍才能验证路径是否合理
- 8 个文件，总 31KB — 合理范围
- characters/ 目录作为独立 deliverable 很清晰，下游 skill 可以直接读取

### 教训 8: Skill 间接口必须显式定义
- **上游模板必须包含下游需要的所有字段** — ideation 的 brief-template 原来缺了 platform/duration/language/model/constraints，script 根本拿不到这些信息
- **brief-vN（候选排名）和 brief-final（确认方向）是两种不同格式** — 必须分别定义模板
- **共享资源要显式标注** — ai-capabilities.md 是 ideation 和 script 共享的，但之前只有 ideation 知道它存在
- **项目目录约定必须写在文档里** — `project/ideation/` + `project/script/` 等，每个 skill 只写自己的目录
- **plan-template 的字段要跨 skill 一致** — 日期列这种小细节也会造成不一致
- **检查接口的方法：列出上游输出的每个字段，逐一检查下游是否能消费到**
