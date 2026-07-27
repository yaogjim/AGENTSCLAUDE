#!/bin/sh

set -eu

test_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "$test_dir/.." && pwd)

fail() {
  printf 'FAIL bootstrap: %s\n' "$*" >&2
  exit 1
}

[ -f "$repo_root/install.sh" ] || fail 'missing public bootstrap installer'

sandbox_root=$(mktemp -d "${TMPDIR:-/tmp}/agentsclaude-bootstrap-test.XXXXXX")
case "$sandbox_root" in
  "${TMPDIR:-/tmp}"/agentsclaude-bootstrap-test.*) ;;
  *) fail "unsafe temporary path: $sandbox_root" ;;
esac
cleanup() {
  rm -r -- "$sandbox_root"
}
trap cleanup EXIT HUP INT TERM

seed_repo=$sandbox_root/seed
remote_repo=$sandbox_root/remote.git
install_root="$sandbox_root/install root"
user_root="$sandbox_root/user root"

mkdir -p \
  "$seed_repo/bin" \
  "$seed_repo/docs/agents" \
  "$seed_repo/skills/agents-init" \
  "$user_root"

for root_file in AGENTS.md CLAUDE.md project.template.md VERSION install.sh
do
  cp -p "$repo_root/$root_file" "$seed_repo/$root_file"
done
cp -p "$repo_root/bin/agentsclaude" "$seed_repo/bin/agentsclaude"
cp -p "$repo_root/docs/agents/"*.md "$seed_repo/docs/agents/"
cp -p "$repo_root/skills/agents-init/SKILL.md" "$seed_repo/skills/agents-init/SKILL.md"

git -C "$seed_repo" init -q
git -C "$seed_repo" config user.name 'AGENTSCLAUDE Test'
git -C "$seed_repo" config user.email 'agentsclaude-test@example.invalid'
git -C "$seed_repo" add .
git -C "$seed_repo" commit -qm 'bootstrap fixture'
git -C "$seed_repo" branch -M main
git init -q --bare "$remote_repo"
git -C "$remote_repo" symbolic-ref HEAD refs/heads/main
git -C "$seed_repo" remote add origin "$remote_repo"
git -C "$seed_repo" push -q -u origin main

bootstrap_output=$(
  HOME="$user_root" \
  AGENTSCLAUDE_USER_ROOT="$user_root" \
  AGENTSCLAUDE_ROOT="$install_root" \
  AGENTSCLAUDE_REPO_URL="$remote_repo" \
    sh "$repo_root/install.sh"
)

[ -d "$install_root/.git" ] || fail 'bootstrap did not create a Git checkout'
[ -L "$user_root/.local/bin/agentsclaude" ] || fail 'bootstrap did not install the CLI link'
[ -L "$user_root/.agents/skills/agents-init" ] || fail 'bootstrap did not install the shared skill link'
[ -L "$user_root/.claude/skills/agents-init" ] || fail 'bootstrap did not install the Claude skill link'

if ! printf '%s\n' "$bootstrap_output" | grep -Fq 'doctor: PASS installation is healthy'; then
  fail 'bootstrap did not finish with a healthy installation'
fi

printf 'PASS public bootstrap clones, installs, and verifies the distribution\n'

cp -p "$user_root/.codex/AGENTS.md" "$sandbox_root/codex-after-first-bootstrap"
cp -p "$user_root/.claude/CLAUDE.md" "$sandbox_root/claude-after-first-bootstrap"

repeat_output=$(
  HOME="$user_root" \
  AGENTSCLAUDE_USER_ROOT="$user_root" \
  AGENTSCLAUDE_ROOT="$install_root" \
  AGENTSCLAUDE_REPO_URL="$remote_repo" \
    sh "$repo_root/install.sh"
)

if ! printf '%s\n' "$repeat_output" | grep -Fq "Reusing existing checkout: $install_root"; then
  fail 'repeated bootstrap did not report checkout reuse'
fi
if ! cmp -s "$sandbox_root/codex-after-first-bootstrap" "$user_root/.codex/AGENTS.md" || \
   ! cmp -s "$sandbox_root/claude-after-first-bootstrap" "$user_root/.claude/CLAUDE.md"; then
  fail 'repeated bootstrap changed already-correct managed instructions'
fi

printf 'PASS repeated bootstrap safely reuses a healthy checkout\n'

foreign_root="$sandbox_root/foreign path"
mkdir -p "$foreign_root"
printf 'keep me\n' > "$foreign_root/sentinel"
foreign_output=$sandbox_root/foreign-output
if HOME="$user_root" \
   AGENTSCLAUDE_USER_ROOT="$user_root" \
   AGENTSCLAUDE_ROOT="$foreign_root" \
     sh "$repo_root/install.sh" >"$foreign_output" 2>&1; then
  fail 'bootstrap accepted a foreign install directory'
fi
if ! grep -Fq 'install path exists but is not an AGENTSCLAUDE checkout' "$foreign_output"; then
  fail 'bootstrap did not explain the foreign install directory'
fi
if [ "$(sed -n '1p' "$foreign_root/sentinel")" != 'keep me' ]; then
  fail 'bootstrap changed a foreign install directory'
fi

printf 'PASS bootstrap refuses a foreign directory without changing it\n'

missing_git_output=$sandbox_root/missing-git-output
if PATH=/nonexistent \
   HOME="$user_root" \
   AGENTSCLAUDE_USER_ROOT="$user_root" \
   AGENTSCLAUDE_ROOT="$sandbox_root/missing-git-install" \
     /bin/sh "$repo_root/install.sh" >"$missing_git_output" 2>&1; then
  fail 'bootstrap continued without Git'
fi
if ! grep -Fq 'Git is required' "$missing_git_output"; then
  fail 'bootstrap did not explain the missing Git dependency'
fi

printf 'PASS bootstrap reports the missing Git dependency before writing\n'
