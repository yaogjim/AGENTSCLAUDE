# AGENTSCLAUDE

面向 Codex、Claude Code 与 Cursor 的工具无关 AGENTS 规范母版。仓库公开分发；每台 macOS/Linux 机器只安装一次，各项目再使用 `agents-init` 接入。

## 新机器一键安装

前置条件只有：

- macOS 或 Linux；
- Git；
- `curl`（只用于下载 bootstrap）。

不需要 GitHub CLI、GitHub 登录、token 或 SSH Key。

```bash
curl -fsSL https://raw.githubusercontent.com/yaogjim/AGENTSCLAUDE/main/install.sh | sh
```

bootstrap 会自动完成：

1. 检查 Git 和安装目录；
2. 通过公开 HTTPS 克隆完整仓库到 `~/.local/share/agentsclaude`；
3. 执行 `agentsclaude install --dry-run`；
4. 安装 CLI、skill 与 Codex/Claude 全局规则接线；
5. 运行 `agentsclaude doctor` 验证安装。

重复运行同一条命令会安全复用已有的有效 checkout，并再次检查接线；若目录不是有效 checkout、存在外来软链或受管规则块损坏，脚本会停止并给出具体路径，不覆盖用户内容。

如需先审阅脚本：

```bash
curl -fsSLo /tmp/agentsclaude-install.sh \
  https://raw.githubusercontent.com/yaogjim/AGENTSCLAUDE/main/install.sh
less /tmp/agentsclaude-install.sh
sh /tmp/agentsclaude-install.sh
```

自定义安装目录：

```bash
curl -fsSL https://raw.githubusercontent.com/yaogjim/AGENTSCLAUDE/main/install.sh |
  AGENTSCLAUDE_ROOT=/absolute/path/to/agentsclaude sh
```

安装器不会使用 `sudo`，也不会写入任何 GitHub 凭据。

## 安装结果

安装会创建以下用户级接线：

- `~/.local/bin/agentsclaude`；
- `~/.agents/skills/agents-init`，供 Codex、Cursor 和兼容 Agent Skills 的客户端使用；
- `~/.claude/skills/agents-init`；
- `~/.codex/AGENTS.md` 中的受管规则块；
- `~/.claude/CLAUDE.md` 中的受管导入块。

已有普通内容会保留。修改前的全局文件备份保存在 `~/.local/state/agentsclaude/backups/`。

如果安装器提示 `~/.local/bin` 不在 `PATH`，按它输出的命令加入 shell 配置，然后新开 Codex、Claude Code 或 Cursor 会话。

## 接入项目

进入目标项目后调用 `agents-init`：

- Codex：提示中使用 `$agents-init`；
- Claude Code / Cursor：使用 `/agents-init`，或直接要求“用 agents-init 接入 AGENTS 母版”。

skill 会访谈项目定位、技术栈、测试/运行命令、权威事实源、任务真值源和项目覆盖规则，然后生成：

- `docs/agents/project.md`；
- 项目根部 `AGENTS.md`；
- 项目根部 `CLAUDE.md`。

它还会用 `agentsclaude register` 把项目路径登记到本机私有清单；不会自动 commit 或 push。

## 手工安装与故障排查

一键入口不可用时，可使用匿名 HTTPS 手工安装：

```bash
agentsclaude_root=${AGENTSCLAUDE_ROOT:-$HOME/.local/share/agentsclaude}
git clone https://github.com/yaogjim/AGENTSCLAUDE.git "$agentsclaude_root"
"$agentsclaude_root/bin/agentsclaude" install --dry-run
"$agentsclaude_root/bin/agentsclaude" install
"$agentsclaude_root/bin/agentsclaude" doctor
```

诊断命令：

```bash
agentsclaude locate
agentsclaude doctor
agentsclaude version
```

不要直接删除安装器报告的冲突路径；先确认它是否属于其他工具或既有配置。安装预检会在修改客户端配置前检查冲突。

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

母版升级后，对已登记项目再次使用 `agents-init` 做漂移检查，评估 project.md 的权威事实源入口、声明覆盖和薄入口最低纪律是否需要同步。

卸载客户端接线：

```bash
agentsclaude uninstall
```

卸载只删除由本工具创建且仍指向当前母版的软链和受管规则块。仓库 checkout、配置备份与本机项目清单会保留，避免不可逆数据丢失。

## 发布

1. 以 `VERSION` 为版本唯一真源，同步 `AGENTS.md` 头部与 §8、`project.template.md`、薄入口最低纪律和契约测试；
2. 运行 `sh tests/test_bootstrap_install.sh`、`sh tests/test_agentsclaude.sh` 与 `sh tests/test_distribution_contract.sh`；
3. 在 macOS/Linux CI 通过后创建与 `VERSION` 内容完全一致的同名 Git tag；
4. 获得明确授权后再 commit、push 和发布 tag。

## 非目标

- Windows；
- Codex Plugin 或 Claude Plugin 分发；
- 把母版复制进每个项目；
- 自动保存 GitHub 凭据；
- 自动 commit/push。
