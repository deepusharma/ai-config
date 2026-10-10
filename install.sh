#!/usr/bin/env bash
# install.sh — symlinks ai-config's AGENTS.md and skills/ into each supported tool's
# global config location. Safe to re-run: existing non-symlink files are backed up first.
#
# Scope: Claude Code, opencode, Codex CLI, Kimchi, Windsurf, Antigravity — all expose a
# plain-file global config, so all are wired. Cursor and Devin cannot be automated (global
# config is locked in internal app state / cloud UI, not a file); Zed stores its rules in
# a binary LMDB database, not a plain file, so it can't be automated either — see README's
# "Scope" section for details on those. Antigravity's global skills mechanism is unconfirmed
# on this install (only plugin-internal skill dirs found) — not wired.
set -euo pipefail

usage() {
  cat <<'EOF'
install.sh — wire ai-config's AGENTS.md and skills/ into each AI tool

Usage:
  ./install.sh          Show this help (default — links nothing)
  ./install.sh run      Create the symlinks (idempotent, safe to re-run)

What `run` links (AGENTS.md + skills/ where supported):
  Claude Code (~/.claude), opencode (~/.config/opencode),
  Codex CLI (~/.codex), Kimchi (~/.config/kimchi/harness),
  Windsurf (~/.codeium/windsurf), Antigravity (~/.gemini)

Existing non-symlink files are backed up to ~/.ai-config_backup_<timestamp>.
EOF
}

case "${1:-}" in
  run) ;;  # continue into the linking below
  ""|-h|--help) usage; exit 0 ;;
  *) echo "Unknown argument: $1"; echo; usage; exit 1 ;;
esac

AI_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.ai-config_backup_$(date +%Y%m%d_%H%M%S)"

# Windows (Git Bash / MSYS): `ln -s` silently makes a *copy* unless native symlinks are
# requested. Needs Developer Mode on (Settings -> System -> For developers) or an elevated
# shell. Force native links and fail loudly rather than quietly copying files.
IS_WINDOWS=0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1; export MSYS=winsymlinks:nativestrict ;;
esac

symlink() {
  local src="$1" dest="$2"
  # On Windows only wire tools that are actually installed (their config dir already
  # exists) � don't create ~/.config/opencode etc. for tools that aren't there.
  if [[ $IS_WINDOWS -eq 1 && ! -d "$(dirname "$dest")" ]]; then
    echo "--  skipped $dest (tool not installed on this machine)"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP"
    mv "$dest" "$BACKUP/$(basename "$(dirname "$dest")")-$(basename "$dest")"
    echo "! backed up $dest"
  fi
  # Remove an existing link first � `ln -sf` onto a symlinked directory would
  # create the new link *inside* the target instead of replacing the link
  [[ -L "$dest" ]] && rm "$dest"
  ln -s "$src" "$dest"
  if [[ ! -L "$dest" ]]; then
    echo "ERROR: $dest is not a symlink (copy made instead). On Windows enable Developer Mode or run elevated." >&2
    exit 1
  fi
  echo "ok  linked $dest"
}

# Link the skills/ directory. Normally the whole directory is symlinked. But if the target is
# a real directory holding Claude-managed content (a `synced/` subfolder, created by the
# Claude app for account-synced skills), replacing it would hide that content � so link each
# skill (skills/<domain>/<skill-name>/ containing SKILL.md) individually into it instead.
link_skills() {
  local dest="$1"
  if [[ -d "$dest" && ! -L "$dest" && -e "$dest/synced" ]]; then
    local n=0 skill
    for skill in "$AI_CONFIG"/skills/*/*/; do
      [[ -f "${skill}SKILL.md" ]] || continue
      symlink "${skill%/}" "$dest/$(basename "$skill")"
      n=$((n+1))
    done
    echo "ok  $dest holds Claude-managed synced/ � linked $n skill(s) individually, directory left in place"
  else
    symlink "$AI_CONFIG/skills" "$dest"
  fi
}

symlink "$AI_CONFIG/AGENTS.md" ~/.claude/CLAUDE.md
link_skills ~/.claude/skills

symlink "$AI_CONFIG/AGENTS.md" ~/.config/opencode/AGENTS.md
symlink "$AI_CONFIG/skills"    ~/.config/opencode/skills

symlink "$AI_CONFIG/AGENTS.md" ~/.codex/AGENTS.md
# Codex CLI's global skills mechanism is deprecated/undocumented upstream — not wired yet.

symlink "$AI_CONFIG/AGENTS.md" ~/.config/kimchi/harness/AGENTS.md
symlink "$AI_CONFIG/skills"    ~/.config/kimchi/harness/skills

symlink "$AI_CONFIG/AGENTS.md" ~/.codeium/windsurf/global_rules.md
# Windsurf has no distinct global skills mechanism, and global_rules.md has a
# 6,000-character limit — keep AGENTS.md under that or this link degrades.

symlink "$AI_CONFIG/AGENTS.md" ~/.gemini/AGENTS.md
# Antigravity — verified working (2026-07-10): it reads this as "global rules (user_global)"
# and follows it correctly. Global skills path unconfirmed on this install — not wired.
