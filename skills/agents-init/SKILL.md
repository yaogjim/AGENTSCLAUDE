---
name: agents-init
description: 为项目接入全局 AGENTS 规范母版：访谈式收集项目信息，生成 docs/agents/project.md 与根部薄入口（AGENTS.md/CLAUDE.md），并登记到本机私有清单。当用户要求"接入母版 / 初始化 agent 规范 / 创建 project.md / 引入 AGENTS 模板"时使用；也用于存量项目的母版版本漂移检查与升级。
---

# agents-init — 项目接入全局 AGENTS 母版

## 母版定位

1. 先运行 `agentsclaude locate`，把返回的本地完整仓库目录作为 `$MASTER`。
2. 验证 `$MASTER/AGENTS.md`、`$MASTER/project.template.md` 与 `$MASTER/docs/agents/` 均存在；缺一项都不得继续。
3. 若 `agentsclaude` 不在 PATH，停止接入并提示用户先按仓库 README 完成私有 GitHub 克隆与 `agentsclaude install`。不得把 GitHub URL 当作本地目录，也不得猜测机器绝对路径。

定位成功后，读取 `$MASTER/AGENTS.md` 头部确认当前母版版本号，并读取 `$MASTER/project.template.md` 获取模板与薄入口样式。

## 接入流程（新项目）

1. **确认目标项目根目录**；检查 `docs/agents/project.md` 是否已存在——已存在则转下方「漂移检查与升级」。
2. **访谈收集**（按母版澄清规则：常规事项分组批量提出，一次问完以下各项）：
   - 项目一句话定位、技术栈、测试命令、运行方式；
   - 文档现状：已有哪些 PRD / Design / Roadmap / process 文档及实际路径（没有则采用母版 §3 默认路径，映射表留空）；
   - 权威事实源与必读入口：业务规则、代码/配置、schema/API、测试、运行/部署/可观测、外部依赖和参考方案分别从哪里读取；只登记稳定入口，不复制易漂移事实，未知写“未登记”；
   - 任务真值源：单 owner 串行（`task/todo.md`，默认）还是多 agent 并行认领（`todos/`）；
   - Context7 MCP 是否接入；可用的浏览器验证工具；
   - 是否有需要偏离母版通用规则的项目特殊要求（逐条记录：覆盖哪条、改成什么、为什么）。
3. **生成三个文件**：
   - `docs/agents/project.md`：按模板填写；yaml 块记录 `project`、`based-on-master`（当前母版版本）、`onboarded`（今天日期）；「项目上下文与权威事实源入口」按访谈结果登记稳定入口，其他声明/覆盖**只写与母版默认值的差异**，无差异的小节留说明性一行即可。
   - 根部 `AGENTS.md` 与 `CLAUDE.md`：按模板附录生成。**项目已有同名文件时，先展示现有内容并与用户确认合并方式，不得直接覆盖**；已有规则内容应迁入 project.md 的「项目覆盖规则」或相应文档。
4. **本地登记**：运行 `agentsclaude register <目标项目根目录>`；登记只写入本机私有状态目录，不修改母版仓库。
5. **验证与收口**：确认三个文件被 git 跟踪（不进 .gitignore）；向用户复述生效方式——全局加载 + project.md 声明优先 + 无全局环境时薄入口最低纪律兜底。

## 漂移检查与升级（存量项目）

1. 读项目 `docs/agents/project.md` yaml 块的 `based-on-master`，与 `$MASTER/AGENTS.md` 当前版本比对；一致则报告无漂移。
2. 版本落后时：读 `$MASTER/AGENTS.md` §8 版本记录中两版之间的变更条目，逐条评估是否影响该项目的声明开关、路径映射或覆盖区；需要调整的先向用户说明再更新，最后刷新 `based-on-master`。
3. 检查项目的权威事实源入口是否仍可定位，并评估新版 Design Gate 是否要求补充上下文声明；只更新入口，不把当前运行事实固化进 project.md。
4. 对比根部薄入口与 `$MASTER/project.template.md` 附录模板，不一致时提示更新（最低纪律条款与 Design 最低门禁可能随母版演进）。
5. 旧拷贝模式项目（根部是完整母版拷贝而非薄入口）：先用 diff 找出该项目对母版的刻意适配与自增规则，迁入 project.md，再把根部文件替换为薄入口，删除项目内 `docs/agents/` 下的母版细则拷贝（保留 project.md）。整个迁移向用户逐项确认后执行。
