# project.md — 项目适配声明（模板）

> 用法：拷贝本模板到项目 `docs/agents/project.md` 并填写（推荐用 `agents-init` skill 访谈式生成）。
> 本文件是项目对全局母版的**唯一适配点**：只写声明和与母版默认值的差异，不复述母版内容。
> 优先级：本文件的声明与覆盖规则 > 母版通用规则（母版 AGENTS.md §1）。

```yaml
project: <项目名>
based-on-master: v0.6.0
onboarded: <YYYY-MM-DD>
```

## 声明开关

- **任务真值源**：`task/todo.md`（单文件，默认）｜`todos/`（分布式，仅多 agent 并行认领时）
- **Context7 MCP**：未接入（默认）｜已接入
- **浏览器验证工具**：无（默认）｜Chrome DevTools MCP｜Playwright｜其他：\<写明\>

## 文档路径映射（与母版 §3 默认表不同时才写）

| 内容类型 | 目标文档 |
|---------|---------|
| （示例）问题分析与技术方案 | `docs/web-design.md` |

## 项目上下文（可选）

母版无法从代码推断、但 agent 每次开工都需要的关键事实：一句话定位、技术栈、测试命令、运行方式、部署与数据边界等。

## 项目覆盖规则（可选）

需要偏离母版通用规则时逐条明写：**覆盖哪一条（引用母版章节）→ 改成什么 → 为什么**。涉及安全/边界条款（不主动提交、真实数据、secret、不可逆操作等）的覆盖必须显式写明授权范围。

---

## 附录：根部薄入口模板（接入时一并生成）

### 项目根部 `AGENTS.md`

```markdown
# AGENTS.md（薄入口）

本项目已接入全局 agent 规范母版（版本见 docs/agents/project.md）。完整规范由全局配置加载
（Claude Code / Codex / Cursor）；项目适配声明见 `docs/agents/project.md`，开工前先读取并遵循。

若当前客户端没有加载全局母版，先运行 `agentsclaude locate`，读取返回目录中的 `AGENTS.md`
及其指向的 `docs/agents/` 细则；命令不可用时再降级到下方最低纪律。

若当前环境未加载全局母版（云端 / CI / 新机器），至少遵循以下最低纪律：

1. 不主动 `git commit` / `git push`；仅在用户明确说 commit 时提交一次。
2. 先分析确认需求再实现；多方案决策先解释选项含义与推荐依据，再请用户拍板。
3. 定位根因，不做临时补丁；完成声明必须有运行验证证据支撑，不夸大完成范围。
4. 用户确认的需求 / 设计 / 计划写入项目文档，不只留在对话里。
```

### 项目根部 `CLAUDE.md`

```markdown
# CLAUDE.md

@AGENTS.md
@docs/agents/project.md

本文件仅作引用入口；规范修改一律进全局母版或 docs/agents/project.md，不在此新增规则。
```
