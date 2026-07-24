# CLAUDE.md（母版目录说明）

本目录是多项目共用 agent 规范的**唯一真源**（v0.6.0 起采用「私有 GitHub 完整克隆 + 本地接线 + 声明式适配」分发，不再拷贝到各项目）：

- `AGENTS.md` + `docs/agents/`（四个细则）：通用规范，经全局配置加载，生效于所有已接入项目。
- `project.template.md`：项目适配声明模板（含根部薄入口模板）。
- `bin/agentsclaude`：安装、升级、诊断、卸载、定位和本地项目登记入口。
- `skills/agents-init/`：接入与漂移检查 skill，由安装器接线到各客户端的用户级 skill 目录。

生效与优先级由 AGENTS.md §0/§1 定义：项目存在 `docs/agents/project.md` 才全量生效，否则仅通用纪律生效；project.md 声明优先于母版通用规则。

> 注意：本文件**刻意不使用** `@AGENTS.md` 引用——全局配置已导入母版，此处再引用会在本目录会话中重复注入。

## 支持范围

- 操作系统：macOS、Linux。
- 客户端：Codex、Claude Code、Cursor。
- 仓库：私有 GitHub；认证由 `gh` 或 Git/SSH 管理，仓库和脚本不保存 token。
- Windows、云端 Agent 自动接线和厂商 Plugin 不在 v0.6.0 范围内。

## 全局接线（每台机器一次）

1. 用 `gh repo clone` 或 SSH `git clone` 把完整仓库克隆到稳定的用户目录。
2. 先运行 `agentsclaude install --dry-run` 检查将要创建的软链和规则块。
3. 运行 `agentsclaude install` 完成接线；已有非本工具管理的路径会停止而不是覆盖。
4. 运行 `agentsclaude doctor` 验证 CLI、skill 与 Codex/Claude 全局规则。
5. Cursor 复用 `~/.agents/skills/agents-init`，项目根部薄入口通过 `agentsclaude locate` 加载完整母版。
6. 云端 / CI / 未接线机器无全局配置时，由各项目根部薄入口的「最低纪律」条款兜底。

## 新项目接入

在目标项目会话中调用 `agents-init` skill：访谈 → 生成 `docs/agents/project.md` + 根部 `AGENTS.md` / `CLAUDE.md` 薄入口 → 登记到本机私有清单。无 skill 环境按 `project.template.md` 手工填写。三个文件必须被 git 跟踪。

## 母版升版

1. 修改 AGENTS.md / 细则后，更新 `VERSION`、头部版本号并在 §8 追加版本记录。
2. 发布对应 Git tag；安装机用 `agentsclaude update` 对当前干净分支做 fast-forward 更新。
3. 用 `agents-init` 的漂移检查逐项目评估 project.md 声明/覆盖区是否受影响，并刷新其 `based-on-master`。
4. 已接入项目清单位于本机状态目录，可用 `agentsclaude list-projects` 查看，不写入 GitHub 仓库。
