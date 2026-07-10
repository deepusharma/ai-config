#!/usr/bin/env bash
# install.sh — symlinks ai-config's AGENTS.md and skills/ into each supported tool's
# global config location. Safe to re-run: existing non-symlink files are backed up first.
#
# Scope: Claude Code, opencode, Codex CLI, Kimchi, Windsurf — all expose a plain-file
# global config, so all are wired. Cursor and Devin cannot be automated (global config
# is locked in internal app state / cloud UI, not a file) — see README's "Scope" section
# for the manual-sync notes on those. Antigravity and Zed also have plain-file global
# configs but aren't wired yet — exact paths need verifying on-machine before adding.
set -euo pipefail

AI_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.ai-config_backup_$(date +%Y%m%d_%H%M%S)"

symlink() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP"
    mv "$dest" "$BACKUP/$(basename "$(dirname "$dest")")-$(basename "$dest")"
    echo "! backed up $dest"
  fi
  # Remove an existing link first — `ln -sf` onto a symlinked directory would
  # create the new link *inside* the target instead of replacing the link
  [[ -L "$dest" ]] && rm "$dest"
  ln -s "$src" "$dest"
  echo "ok  linked $dest"
}

symlink "$AI_CONFIG/AGENTS.md" ~/.claude/CLAUDE.md
symlink "$AI_CONFIG/skills"    ~/.claude/skills

symlink "$AI_CONFIG/AGENTS.md" ~/.config/opencode/AGENTS.md
symlink "$AI_CONFIG/skills"    ~/.config/opencode/skills

symlink "$AI_CONFIG/AGENTS.md" ~/.codex/AGENTS.md
# Codex CLI's global skills mechanism is deprecated/undocumented upstream — not wired yet.

symlink "$AI_CONFIG/AGENTS.md" ~/.config/kimchi/harness/AGENTS.md
symlink "$AI_CONFIG/skills"    ~/.config/kimchi/harness/skills

symlink "$AI_CONFIG/AGENTS.md" ~/.codeium/windsurf/global_rules.md
# Windsurf has no distinct global skills mechanism, and global_rules.md has a
# 6,000-character limit — keep AGENTS.md under that or this link degrades.
