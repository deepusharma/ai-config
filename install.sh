#!/usr/bin/env bash
# install.sh — symlinks ai-config's AGENTS.md and skills/ into Claude Code and opencode's
# global config locations. Safe to re-run: existing non-symlink files are backed up first.
#
# Scope (v1): Claude Code and opencode only — the two tools in active daily/regular use.
# Codex CLI, Kimchi, Windsurf are intentionally not wired yet (see 000.09 design doc,
# "Per-tool wiring" section) — add a two-line block per tool here when needed.
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
