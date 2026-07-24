# CLAUDE.md（母版目录说明）

本目录存放多项目共用的 agent 规范**母版**：同目录下的 `AGENTS.md`（核心规则）与 `docs/agents/`（场景细则）是通用模板，仅供拷贝到各项目后适配使用，**不对本目录下的任何子项目直接生效**。各项目一律以其自己根目录的 `AGENTS.md` / `CLAUDE.md` 为准；若本文件与子项目规范同时被加载，忽略本文件。

> 注意：本文件**刻意不使用** `@AGENTS.md` 引用——Claude Code 会向上递归加载父目录的 CLAUDE.md，若在此引用母版，会把通用模板（含未适配的占位路径）注入所有子项目会话，与项目自身规范冲突。

## 新项目接入步骤

1. 拷贝本目录 `AGENTS.md` 到新项目根目录、`docs/agents/` 到新项目 `docs/agents/`（细则文件原样使用，无需适配），然后按 AGENTS.md 顶部「适配清单」逐项完成项目化替换。
2. 在新项目根目录创建 `CLAUDE.md`，内容如下（引用入口，不承载独立规范）：

```markdown
# CLAUDE.md

本项目的 agent 协作与交付规范统一维护在 `AGENTS.md`（唯一权威来源），请完整加载并遵循：

@AGENTS.md

本文件仅作引用入口，不承载独立规范内容；不要在此文件中新增规则，所有修改一律进 `AGENTS.md`。
```

3. 建立“完整功能链路 → 需求 → 设计 → 可执行切片 → 验证证据”的追踪关系，并在项目 AGENTS 中写明 PRD、Design、Plan/Roadmap、Todo 和过程记录的真实路径。
4. 确认 `AGENTS.md`、`CLAUDE.md` 与 `docs/agents/` 均被 git 跟踪（不要放进 `.gitignore`），保留规范演进历史。
5. 母版更新后，用 diff 同步到各项目：细则文件可直接覆盖；`AGENTS.md` 按项目文件头部的「基于母版 vX.Y 适配」标识对比版本，注意区分「项目适配区」的刻意差异与意外漂移。

## 已接入项目

- `jandarwkspace/smartcashflowanalysis`（规范源头，最新演进版）
- `yaogjim/inspect-suite`
- `yaogjim/GPTSummarizer`
