#!/bin/sh

set -eu

test_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "$test_dir/.." && pwd)

fail() {
  printf 'FAIL contract: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  file_path=$1
  expected=$2
  grep -Fq "$expected" "$file_path" || fail "$file_path is missing: $expected"
}

assert_not_contains() {
  file_path=$1
  rejected=$2
  if grep -Fq "$rejected" "$file_path"; then
    fail "$file_path still contains: $rejected"
  fi
}

expected_version=$(sed -n '1p' "$repo_root/VERSION")
if ! printf '%s\n' "$expected_version" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  fail "VERSION is not a semantic version: $expected_version"
fi

assert_contains "$repo_root/skills/agents-init/SKILL.md" 'agentsclaude locate'
assert_contains "$repo_root/skills/agents-init/SKILL.md" 'agentsclaude register'
assert_contains "$repo_root/skills/agents-init/SKILL.md" '权威事实源与必读入口'
assert_contains "$repo_root/skills/agents-init/SKILL.md" '新版 Design Gate'
assert_not_contains "$repo_root/skills/agents-init/SKILL.md" '/Volumes/'
# shellcheck disable=SC2016 # The rejected Markdown text must keep $MASTER literal.
assert_not_contains "$repo_root/skills/agents-init/SKILL.md" '母版真源目录（下称 `$MASTER`）：`https://'

assert_contains "$repo_root/project.template.md" 'agentsclaude locate'
assert_contains "$repo_root/project.template.md" 'Claude Code / Codex / Cursor'
assert_contains "$repo_root/project.template.md" "based-on-master: $expected_version"
assert_contains "$repo_root/project.template.md" '项目上下文与权威事实源入口'
assert_contains "$repo_root/project.template.md" '关键自由裁量未闭合时'
assert_contains "$repo_root/project.template.md" '缺少已批准 Design 锚点的复杂实施计划'
assert_contains "$repo_root/project.template.md" '先给出独立判断，不默认同意用户意见'
assert_not_contains "$repo_root/CLAUDE.md" '/Volumes/'
assert_contains "$repo_root/CLAUDE.md" 'agentsclaude install'
assert_contains "$repo_root/CLAUDE.md" '公开 GitHub'
assert_contains "$repo_root/CLAUDE.md" '缺少已批准 Design 锚点的复杂实施计划'
assert_contains "$repo_root/CLAUDE.md" '不强制创建持久文档或任务体系'

assert_contains "$repo_root/AGENTS.md" "母版版本：$expected_version"
assert_contains "$repo_root/AGENTS.md" "**$expected_version**"
assert_contains "$repo_root/AGENTS.md" '### 设计现实校准与关键决策闭合'
assert_contains "$repo_root/AGENTS.md" '**关键自由裁量测试**'
assert_contains "$repo_root/AGENTS.md" 'Design 最低质量门禁'
assert_contains "$repo_root/AGENTS.md" '缺少 `Design Readiness=approved` 锚点的复杂实施计划'
assert_contains "$repo_root/AGENTS.md" '### 独立判断与建设主线'
assert_contains "$repo_root/AGENTS.md" '能力是否打通、覆盖率、是否完成验收'
assert_contains "$repo_root/AGENTS.md" '新事实、目标或优先级变化、此前分析错误'
# Execution principles must survive master loading and thin-entry fallback.
for required_text in \
  '### 执行原则' \
  '简单任务采用简单方案，优先选择最小、直接、可回退的实现。' \
  '只解决当前明确需求，不为假设性的未来需求预先增加复杂度。' \
  '严格遵守任务范围。未经明确要求，不得：' \
  '新增依赖、抽象层、兼容逻辑或迁移脚本；' \
  '增加与当前风险无关的流程、门禁或防御机制；' \
  '重构无关代码；' \
  '修复范围外的问题；' \
  '扩大功能或改动范围。' \
  '验证强度应与变更风险相匹配，只执行满足验收标准所必需的检查；不得进行无明确收益的重复测试、全面验证或额外分析。' \
  '发现范围外的问题时，只报告，不处理。' \
  '满足验收标准后立即停止，不进行额外优化、扩展或清理。' \
  '### 越界处理' \
  '如果完成任务确实必须超出既定范围，先暂停并说明：' \
  '为什么无法在当前范围内完成；' \
  '必须增加哪些改动；' \
  '最小可行方案及其影响。' \
  '获得确认后再继续。' \
  '§1 执行原则、越界处理与提交纪律' \
  '母版及细则中的规划、重构、验证和收口要求均受本节约束'
do
  assert_contains "$repo_root/AGENTS.md" "$required_text"
done
for required_text in \
  '最小、直接、可回退' \
  '假设性的未来需求' \
  '未经明确要求' \
  '依赖、抽象层、兼容逻辑或迁移脚本' \
  '与当前风险无关的流程、门禁或防御机制' \
  '范围外的问题只报告、不处理' \
  '验证强度与变更风险相匹配' \
  '无明确收益的重复测试、全面验证或额外分析' \
  '满足验收标准后立即停止' \
  '为什么无法在当前范围内完成、必须增加哪些改动、最小可行方案及其影响'
do
  assert_contains "$repo_root/project.template.md" "$required_text"
done
assert_contains "$repo_root/docs/agents/execution-loop.md" 'AGENTS.md §1「执行原则」与「越界处理」'
assert_contains "$repo_root/docs/agents/execution-loop.md" '满足验收标准后立即停止'
assert_not_contains "$repo_root/AGENTS.md" '**提交前运行完整套件**'
assert_not_contains "$repo_root/AGENTS.md" '主动修复未通过的 CI 测试'
assert_not_contains "$repo_root/AGENTS.md" '基于当前全部信息重写优雅的解决方案'
assert_not_contains "$repo_root/docs/agents/execution-loop.md" '显著扩大工作范围'

assert_contains "$repo_root/docs/agents/doc-quality.md" '### 实施级设计合同（按适用性）'
assert_contains "$repo_root/docs/agents/doc-quality.md" 'evidence_status=verified'
assert_contains "$repo_root/docs/agents/doc-quality.md" 'gap_type=fact-gap'
assert_contains "$repo_root/docs/agents/doc-quality.md" '### 客观 Design Gate'
assert_contains "$repo_root/docs/agents/doc-quality.md" 'Design Gate 记录'
assert_contains "$repo_root/docs/agents/doc-quality.md" '**问题机制门禁**'
assert_contains "$repo_root/docs/agents/doc-quality.md" '正式实施 Plan 仅在 `Design Readiness=approved` 后'
assert_contains "$repo_root/docs/agents/doc-quality.md" '### 紧凑正反例'
assert_not_contains "$repo_root/docs/agents/doc-quality.md" '承重假设已验证或被明确批准'
assert_not_contains "$repo_root/docs/agents/doc-quality.md" '每个设计决策都应落到 Plan/Test'
assert_contains "$repo_root/docs/agents/task-readiness.md" 'Design Readiness=approved'
assert_contains "$repo_root/docs/agents/task-readiness.md" '只读取证切片例外'
assert_contains "$repo_root/docs/agents/task-readiness.md" '三条独立轴'
assert_contains "$repo_root/docs/agents/task-readiness.md" '不把它们当作 `todo.status` 或 `delivery_status` 枚举值'
assert_contains "$repo_root/docs/agents/execution-loop.md" '不触发代码执行不等于免除质量门禁'
assert_contains "$repo_root/docs/agents/execution-loop.md" '缺少已批准 Design 锚点的复杂实施计划'
assert_contains "$repo_root/README.md" 'curl -fsSL https://raw.githubusercontent.com/yaogjim/AGENTSCLAUDE/main/install.sh | sh'
assert_contains "$repo_root/README.md" 'agentsclaude install --dry-run'
assert_contains "$repo_root/README.md" 'agentsclaude update'
assert_contains "$repo_root/README.md" '与 `VERSION` 内容完全一致'
assert_not_contains "$repo_root/README.md" '仓库保持私有'
assert_not_contains "$repo_root/README.md" 'gh auth login'

assert_contains "$repo_root/install.sh" 'https://github.com/yaogjim/AGENTSCLAUDE.git'
assert_contains "$repo_root/install.sh" '"$installer" install --dry-run'
assert_contains "$repo_root/install.sh" '"$installer" doctor'

assert_contains "$repo_root/.github/workflows/test.yml" 'macos-latest'
assert_contains "$repo_root/.github/workflows/test.yml" 'ubuntu-latest'
assert_contains "$repo_root/.github/workflows/test.yml" 'sh tests/test_agentsclaude.sh'
assert_contains "$repo_root/.github/workflows/test.yml" 'sh tests/test_bootstrap_install.sh'
assert_contains "$repo_root/.github/workflows/test.yml" 'sh tests/test_distribution_contract.sh'

printf 'PASS distribution contract is portable and documented\n'
