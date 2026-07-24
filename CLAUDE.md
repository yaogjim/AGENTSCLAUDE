# CLAUDE.md（母版目录说明）

本目录是多项目共用 agent 规范的**唯一真源**（v0.5 起采用「全局加载 + 声明式适配」分发，不再拷贝到各项目）：

- `AGENTS.md` + `docs/agents/`（四个细则）：通用规范，经全局配置加载，生效于所有已接入项目。
- `project.template.md`：项目适配声明模板（含根部薄入口模板）。
- `skills/agents-init/`：接入与漂移检查 skill，软链到 `~/.claude/skills/` 使用。

生效与优先级由 AGENTS.md §0/§1 定义：项目存在 `docs/agents/project.md` 才全量生效，否则仅通用纪律生效；project.md 声明优先于母版通用规则。

> 注意：本文件**刻意不使用** `@AGENTS.md` 引用——全局配置已导入母版，此处再引用会在本目录会话中重复注入。

## 全局接线（每台机器一次）

1. `~/.claude/CLAUDE.md` 追加：`@/Volumes/workspace/devspace/pywork/jandarwkspace/AGENTSCLAUDE/AGENTS.md`
2. Codex：`~/.codex/AGENTS.md` 中写入指向本目录母版的加载指令（若该文件含插件自动管理块须保留；纯净环境可直接软链）
3. Skill：`ln -s <本目录>/skills/agents-init ~/.claude/skills/agents-init`
4. Cursor（如使用）：在用户规则中粘贴指向本母版路径的加载说明。
5. 云端 / CI / 未接线机器无全局配置时，由各项目根部薄入口的「最低纪律」条款兜底。

## 新项目接入

在目标项目会话中调用 `agents-init` skill：访谈 → 生成 `docs/agents/project.md` + 根部 `AGENTS.md` / `CLAUDE.md` 薄入口 → 登记到下方清单。无 skill 环境按 `project.template.md` 手工填写。三个文件必须被 git 跟踪。

## 母版升版

1. 修改 AGENTS.md / 细则后，更新头部版本号并在 §8 追加版本记录。
2. 全局加载即时生效于所有接入项目，无需拷贝同步；用 `agents-init` 的漂移检查逐项目评估 project.md 声明/覆盖区是否受影响，并刷新其 `based-on-master`。

## 已接入项目

<!-- 格式：路径 — 接入版本 — 状态 -->

- `jandarwkspace/smartcashflowanalysis` — v0.2 拷贝模式 — 待迁移薄入口
- `yaogjim/inspect-suite` — v0.2 拷贝模式 — 待迁移薄入口
- `yaogjim/GPTSummarizer` — v0.2 拷贝模式 — 待迁移薄入口
- `jandarwkspace/SmartDossier` — 前母版手动版 — 未接入，待迁移（其实战积累已于 v0.4 吸收）
