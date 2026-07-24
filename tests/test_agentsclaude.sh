#!/bin/sh

set -eu

test_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "$test_dir/.." && pwd)

actual_root=$("$repo_root/bin/agentsclaude" locate)

if [ "$actual_root" != "$repo_root" ]; then
  printf 'FAIL locate: expected %s, got %s\n' "$repo_root" "$actual_root" >&2
  exit 1
fi

printf 'PASS locate resolves the repository root\n'

sandbox_root=$(mktemp -d "${TMPDIR:-/tmp}/agentsclaude-test.XXXXXX")
case "$sandbox_root" in
  "${TMPDIR:-/tmp}"/agentsclaude-test.*) ;;
  *)
    printf 'FAIL unsafe temporary path: %s\n' "$sandbox_root" >&2
    exit 1
    ;;
esac
cleanup() {
  rm -r -- "$sandbox_root"
}
trap cleanup EXIT HUP INT TERM

user_root=$sandbox_root/user
mkdir -p "$user_root/.codex" "$user_root/.claude"
printf '# existing codex content\n' > "$user_root/.codex/AGENTS.md"
printf '# existing claude content\n' > "$user_root/.claude/CLAUDE.md"

AGENTSCLAUDE_TIMESTAMP=20260724-120000 AGENTSCLAUDE_USER_ROOT=$user_root \
  "$repo_root/bin/agentsclaude" install

for link_path in \
  "$user_root/.local/bin/agentsclaude" \
  "$user_root/.agents/skills/agents-init" \
  "$user_root/.claude/skills/agents-init"
do
  if [ ! -L "$link_path" ]; then
    printf 'FAIL install: expected symlink %s\n' "$link_path" >&2
    exit 1
  fi
done

if ! grep -Fq '# existing codex content' "$user_root/.codex/AGENTS.md"; then
  printf 'FAIL install replaced existing Codex instructions\n' >&2
  exit 1
fi
if ! grep -Fq '<!-- BEGIN AGENTSCLAUDE MANAGED BLOCK -->' "$user_root/.codex/AGENTS.md"; then
  printf 'FAIL install did not add the Codex managed block\n' >&2
  exit 1
fi
if ! grep -Fq '# existing claude content' "$user_root/.claude/CLAUDE.md"; then
  printf 'FAIL install replaced existing Claude instructions\n' >&2
  exit 1
fi
if ! grep -Fq "@$repo_root/AGENTS.md" "$user_root/.claude/CLAUDE.md"; then
  printf 'FAIL install did not add the Claude import\n' >&2
  exit 1
fi

printf 'PASS install wires clients without replacing existing instructions\n'

cp "$user_root/.codex/AGENTS.md" "$sandbox_root/codex-after-first-install"
cp "$user_root/.claude/CLAUDE.md" "$sandbox_root/claude-after-first-install"
AGENTSCLAUDE_TIMESTAMP=20260724-120000 AGENTSCLAUDE_USER_ROOT=$user_root \
  "$repo_root/bin/agentsclaude" install >/dev/null
if ! cmp -s "$sandbox_root/codex-after-first-install" "$user_root/.codex/AGENTS.md" || \
   ! cmp -s "$sandbox_root/claude-after-first-install" "$user_root/.claude/CLAUDE.md"; then
  printf 'FAIL repeated install changed already-correct managed files\n' >&2
  exit 1
fi

printf 'PASS repeated install is idempotent\n'

original_backup=$user_root/.local/state/agentsclaude/backups/20260724-120000/codex-AGENTS.md
if [ ! -f "$original_backup" ] || \
   grep -Fq '<!-- BEGIN AGENTSCLAUDE MANAGED BLOCK -->' "$original_backup"; then
  printf 'FAIL repeated install overwrote the original configuration backup\n' >&2
  exit 1
fi

printf 'PASS repeated install preserves the original backup\n'

doctor_output=$(AGENTSCLAUDE_USER_ROOT=$user_root "$repo_root/bin/agentsclaude" doctor)
if ! printf '%s\n' "$doctor_output" | grep -Fq 'doctor: PASS'; then
  printf 'FAIL doctor did not report a healthy installation\n' >&2
  exit 1
fi

printf 'PASS doctor verifies the installed wiring\n'

project_root=$sandbox_root/project
mkdir -p "$project_root"
project_root=$(CDPATH='' cd -- "$project_root" && pwd)
AGENTSCLAUDE_USER_ROOT=$user_root "$repo_root/bin/agentsclaude" register "$project_root"
AGENTSCLAUDE_USER_ROOT=$user_root "$repo_root/bin/agentsclaude" register "$project_root"
registered_projects=$(AGENTSCLAUDE_USER_ROOT=$user_root "$repo_root/bin/agentsclaude" list-projects)
registered_count=$(printf '%s\n' "$registered_projects" | grep -Fxc "$project_root")
if [ "$registered_count" -ne 1 ]; then
  printf 'FAIL register: expected one local registry entry, got %s\n' "$registered_count" >&2
  exit 1
fi

printf 'PASS register keeps a private idempotent project registry\n'

AGENTSCLAUDE_USER_ROOT=$user_root "$repo_root/bin/agentsclaude" uninstall

for removed_path in \
  "$user_root/.local/bin/agentsclaude" \
  "$user_root/.agents/skills/agents-init" \
  "$user_root/.claude/skills/agents-init"
do
  if [ -e "$removed_path" ] || [ -L "$removed_path" ]; then
    printf 'FAIL uninstall left managed path %s\n' "$removed_path" >&2
    exit 1
  fi
done

if ! grep -Fq '# existing codex content' "$user_root/.codex/AGENTS.md" || \
   grep -Fq '<!-- BEGIN AGENTSCLAUDE MANAGED BLOCK -->' "$user_root/.codex/AGENTS.md"; then
  printf 'FAIL uninstall did not preserve only the original Codex content\n' >&2
  exit 1
fi
if ! grep -Fq '# existing claude content' "$user_root/.claude/CLAUDE.md" || \
   grep -Fq '<!-- BEGIN AGENTSCLAUDE MANAGED BLOCK -->' "$user_root/.claude/CLAUDE.md"; then
  printf 'FAIL uninstall did not preserve only the original Claude content\n' >&2
  exit 1
fi
if [ ! -f "$user_root/.local/state/agentsclaude/projects.txt" ]; then
  printf 'FAIL uninstall removed the private project registry\n' >&2
  exit 1
fi

printf 'PASS uninstall removes only managed wiring\n'

reported_version=$("$repo_root/bin/agentsclaude" version)
if [ "$reported_version" != 'v0.6.0' ]; then
  printf 'FAIL version: expected v0.6.0, got %s\n' "$reported_version" >&2
  exit 1
fi

printf 'PASS version reports the distribution release\n'

seed_repo=$sandbox_root/update-seed
remote_repo=$sandbox_root/update-remote.git
installed_repo=$sandbox_root/update-installed
mkdir -p "$seed_repo/bin"
cp -p "$repo_root/bin/agentsclaude" "$seed_repo/bin/agentsclaude"
cp -p "$repo_root/VERSION" "$seed_repo/VERSION"
git -C "$seed_repo" init -q
git -C "$seed_repo" config user.name 'AGENTSCLAUDE Test'
git -C "$seed_repo" config user.email 'agentsclaude-test@example.invalid'
git -C "$seed_repo" add bin/agentsclaude VERSION
git -C "$seed_repo" commit -qm 'initial distribution'
git -C "$seed_repo" branch -M main
git init -q --bare "$remote_repo"
git -C "$remote_repo" symbolic-ref HEAD refs/heads/main
git -C "$seed_repo" remote add origin "$remote_repo"
git -C "$seed_repo" push -q -u origin main
git clone -q "$remote_repo" "$installed_repo"

printf 'updated\n' > "$seed_repo/update-marker"
git -C "$seed_repo" add update-marker
git -C "$seed_repo" commit -qm 'publish update marker'
git -C "$seed_repo" push -q

AGENTSCLAUDE_USER_ROOT=$user_root "$installed_repo/bin/agentsclaude" update
if [ "$(sed -n '1p' "$installed_repo/update-marker")" != 'updated' ]; then
  printf 'FAIL update did not fast-forward the installed checkout\n' >&2
  exit 1
fi

printf 'PASS update fast-forwards a clean installed checkout\n'

partial_user=$sandbox_root/partial-user
if AGENTSCLAUDE_USER_ROOT=$partial_user "$installed_repo/bin/agentsclaude" install >/dev/null 2>&1; then
  printf 'FAIL install accepted an incomplete distribution checkout\n' >&2
  exit 1
fi
if [ -e "$partial_user/.local/bin/agentsclaude" ]; then
  printf 'FAIL incomplete distribution wrote user wiring before rejection\n' >&2
  exit 1
fi

printf 'PASS install requires the complete distribution checkout\n'

dry_user=$sandbox_root/dry-user
mkdir -p "$dry_user/.codex"
printf '# untouched\n' > "$dry_user/.codex/AGENTS.md"
AGENTSCLAUDE_USER_ROOT=$dry_user "$repo_root/bin/agentsclaude" install --dry-run
if [ -e "$dry_user/.local/bin/agentsclaude" ] || \
   [ -e "$dry_user/.agents/skills/agents-init" ] || \
   grep -Fq '<!-- BEGIN AGENTSCLAUDE MANAGED BLOCK -->' "$dry_user/.codex/AGENTS.md" 2>/dev/null; then
  printf 'FAIL install --dry-run changed the target user directory\n' >&2
  exit 1
fi

printf 'PASS install --dry-run performs no writes\n'

conflict_user=$sandbox_root/conflict-user
mkdir -p "$conflict_user/.agents/skills"
printf 'owned by user\n' > "$conflict_user/.agents/skills/agents-init"
if AGENTSCLAUDE_USER_ROOT=$conflict_user "$repo_root/bin/agentsclaude" install >/dev/null 2>&1; then
  printf 'FAIL install accepted a foreign destination path\n' >&2
  exit 1
fi
if [ -e "$conflict_user/.local/bin/agentsclaude" ] || \
   [ "$(sed -n '1p' "$conflict_user/.agents/skills/agents-init")" != 'owned by user' ]; then
  printf 'FAIL install partially wrote before reporting a conflict\n' >&2
  exit 1
fi

printf 'PASS install refuses conflicts before writing\n'

malformed_user=$sandbox_root/malformed-user
mkdir -p "$malformed_user/.codex"
printf '%s\n' \
  '# must survive' \
  '<!-- END AGENTSCLAUDE MANAGED BLOCK -->' \
  '<!-- BEGIN AGENTSCLAUDE MANAGED BLOCK -->' \
  '# malformed tail' \
  > "$malformed_user/.codex/AGENTS.md"
if AGENTSCLAUDE_USER_ROOT=$malformed_user "$repo_root/bin/agentsclaude" install >/dev/null 2>&1; then
  printf 'FAIL install accepted reversed managed markers\n' >&2
  exit 1
fi
if ! grep -Fq '# malformed tail' "$malformed_user/.codex/AGENTS.md"; then
  printf 'FAIL malformed managed file was modified before rejection\n' >&2
  exit 1
fi

printf 'PASS install rejects malformed managed blocks before writing\n'

printf 'dirty\n' > "$installed_repo/local-change"
if AGENTSCLAUDE_USER_ROOT=$user_root "$installed_repo/bin/agentsclaude" update >/dev/null 2>&1; then
  printf 'FAIL update accepted a dirty installed checkout\n' >&2
  exit 1
fi

printf 'PASS update refuses a dirty checkout\n'
