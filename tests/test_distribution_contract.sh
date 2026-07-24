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

assert_contains "$repo_root/skills/agents-init/SKILL.md" 'agentsclaude locate'
assert_contains "$repo_root/skills/agents-init/SKILL.md" 'agentsclaude register'
assert_not_contains "$repo_root/skills/agents-init/SKILL.md" '/Volumes/'
# shellcheck disable=SC2016 # The rejected Markdown text must keep $MASTER literal.
assert_not_contains "$repo_root/skills/agents-init/SKILL.md" '母版真源目录（下称 `$MASTER`）：`https://'

assert_contains "$repo_root/project.template.md" 'agentsclaude locate'
assert_contains "$repo_root/project.template.md" 'Claude Code / Codex / Cursor'
assert_not_contains "$repo_root/CLAUDE.md" '/Volumes/'
assert_contains "$repo_root/CLAUDE.md" 'agentsclaude install'

assert_contains "$repo_root/AGENTS.md" '母版版本：v0.6.0'
assert_contains "$repo_root/AGENTS.md" '**v0.6.0**'
assert_contains "$repo_root/README.md" 'gh repo clone yaogjim/AGENTSCLAUDE'
assert_contains "$repo_root/README.md" 'agentsclaude install --dry-run'
assert_contains "$repo_root/README.md" 'agentsclaude update'

assert_contains "$repo_root/.github/workflows/test.yml" 'macos-latest'
assert_contains "$repo_root/.github/workflows/test.yml" 'ubuntu-latest'
assert_contains "$repo_root/.github/workflows/test.yml" 'sh tests/test_agentsclaude.sh'
assert_contains "$repo_root/.github/workflows/test.yml" 'sh tests/test_distribution_contract.sh'

printf 'PASS distribution contract is portable and documented\n'
