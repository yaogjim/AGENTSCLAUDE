# AGENTSCLAUDE

面向 Codex、Claude Code 与 Cursor 的工具无关 AGENTS 规范母版。仓库保持私有，通过完整 Git 克隆在 macOS/Linux 间分发；每台机器只安装一次，各项目使用 `agents-init` 接入。

## 前置条件

- macOS 或 Linux；
- Git；
- 已有本私有仓库访问权限；
- 推荐安装并登录 GitHub CLI：`gh auth login`。也可以使用已配置的 SSH key。

安装器不会接收、记录或写入 GitHub token，也不会使用 `sudo`。

## 新机器安装

GitHub CLI：

```bash
agentsclaude_root=${AGENTSCLAUDE_ROOT:-$HOME/.local/share/agentsclaude}
gh repo clone yaogjim/AGENTSCLAUDE "$agentsclaude_root"
"$agentsclaude_root/bin/agentsclaude" install --dry-run
"$agentsclaude_root/bin/agentsclaude" install
"$agentsclaude_root/bin/agentsclaude" doctor
```

SSH：

```bash
agentsclaude_root=${AGENTSCLAUDE_ROOT:-$HOME/.local/share/agentsclaude}
git clone git@github.com:yaogjim/AGENTSCLAUDE.git "$agentsclaude_root"
"$agentsclaude_root/bin/agentsclaude" install --dry-run
"$agentsclaude_root/bin/agentsclaude" install
```

安装会创建以下用户级接线：

- `~/.local/bin/agentsclaude`；
- `~/.agents/skills/agents-init`，供 Codex、Cursor 和兼容 Agent Skills 的客户端使用；
- `~/.claude/skills/agents-init`；
- `~/.codex/AGENTS.md` 中的受管规则块；
- `~/.claude/CLAUDE.md` 中的受管导入块。

已有普通内容会保留；已有冲突路径、损坏或重复受管块会让安装停止。修改前的全局文件备份保存在 `~/.local/state/agentsclaude/backups/`。

## 接入项目

进入目标项目后调用 `agents-init`：

- Codex：提示中使用 `$agents-init`；
- Claude Code / Cursor：使用 `/agents-init`，或直接要求“用 agents-init 接入 AGENTS 母版”。

skill 会生成 `docs/agents/project.md` 和项目根部薄入口，并用 `agentsclaude register` 把项目路径登记到本机私有清单。该清单不会提交到本仓库。

## 日常维护

```bash
agentsclaude install --dry-run
agentsclaude install
agentsclaude doctor
agentsclaude update
agentsclaude version
agentsclaude list-projects
```

`agentsclaude update` 只更新干净、位于分支上的完整 Git checkout，并使用 `git fetch` + `git merge --ff-only`；工作区有修改、处于 detached HEAD 或远端分叉时会拒绝更新。

母版升级后，对已登记项目使用 `agents-init` 做漂移检查，评估 project.md 的权威事实源入口、声明覆盖和薄入口最低纪律是否需要同步。

卸载客户端接线：

```bash
agentsclaude uninstall
```

卸载只删除由本工具创建且仍指向当前母版的软链和受管规则块。仓库 checkout、配置备份与本机项目清单会保留，避免不可逆数据丢失。

## 发布

1. 以 `VERSION` 为版本唯一真源，同步 `AGENTS.md` 头部与 §8、`project.template.md`、薄入口最低纪律和契约测试；
2. 运行 `sh tests/test_agentsclaude.sh` 与 `sh tests/test_distribution_contract.sh`；
3. 在 macOS/Linux CI 通过后创建与 `VERSION` 内容完全一致的同名 Git tag；
4. 获得明确授权后再 commit、push 和发布 tag。

## 非目标

- Windows；
- Codex Plugin 或 Claude Plugin 分发；
- 把母版复制进每个项目；
- 自动保存 GitHub 凭据；
- 自动 commit/push。
