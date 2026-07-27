#!/bin/sh

set -eu

fail() {
  printf 'agentsclaude bootstrap: %s\n' "$*" >&2
  exit 1
}

user_home=${HOME:?HOME is required}
user_root=${AGENTSCLAUDE_USER_ROOT:-$user_home}
install_root=${AGENTSCLAUDE_ROOT:-$user_home/.local/share/agentsclaude}
repo_url=${AGENTSCLAUDE_REPO_URL:-https://github.com/yaogjim/AGENTSCLAUDE.git}

command -v git >/dev/null 2>&1 || \
  fail 'Git is required. Install Git, then run this command again.'

case "$install_root" in
  /*) ;;
  *) fail "AGENTSCLAUDE_ROOT must be an absolute path: $install_root" ;;
esac

if [ -e "$install_root" ] || [ -L "$install_root" ]; then
  if [ -d "$install_root/.git" ] && [ -x "$install_root/bin/agentsclaude" ]; then
    printf 'Reusing existing checkout: %s\n' "$install_root"
  else
    fail "install path exists but is not an AGENTSCLAUDE checkout: $install_root"
  fi
else
  mkdir -p "$(dirname -- "$install_root")"
  printf 'Cloning AGENTSCLAUDE from %s\n' "$repo_url"
  if ! GIT_TERMINAL_PROMPT=0 git clone --quiet "$repo_url" "$install_root"; then
    fail "clone failed; verify network access and inspect $install_root before retrying"
  fi
fi

installer=$install_root/bin/agentsclaude
[ -x "$installer" ] || fail "cloned distribution is missing executable installer: $installer"

"$installer" install --dry-run
"$installer" install
"$installer" doctor

printf '\nAGENTSCLAUDE installation completed.\n'
case ":${PATH:-}:" in
  *":$user_root/.local/bin:"*) ;;
  *)
    printf 'Add %s to PATH, then start a new Codex, Claude Code, or Cursor session:\n' \
      "$user_root/.local/bin"
    printf '  export PATH="%s:$PATH"\n' "$user_root/.local/bin"
    ;;
esac
