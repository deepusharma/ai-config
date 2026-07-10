# ai-config

Common AI-agent instructions and skills, shared globally across every coding agent and every repo — the AI-agent equivalent of a dotfiles repo. Companion to [`dotfiles`](../dotfiles), kept separate because it's a distinct concern (AI agent config vs. terminal/editor/tool config).

## What's here

- `AGENTS.md` — canonical, self-contained instructions (nomenclature, timestamp-footer rule, session-maintenance conventions). No personal/work/career content — keep that in your private notes/vault instead.
- `skills/` — reusable skills organized by domain (`coding/`, `writing/`, `brainstorming/`, ...), one `SKILL.md` per skill subfolder.
- `install.sh` — idempotent symlink script.

## Relationship to `dotfiles`

`ai-config` is a sibling of [`dotfiles`](../dotfiles) — same lifecycle (git-tracked, symlinked into place via its own `install.sh`, safe to re-run), same directory level (`~/Documents/GitProjects/public/`), but a different concern: `dotfiles` covers terminal/editor/tool configuration (shell, git, terminal emulators, prompt), while `ai-config` covers AI coding agent configuration (global instructions + skills for Claude Code, opencode, etc.). Kept as two repos rather than one folder inside the other, so each can be cloned, adopted, or shared independently.

## Install

```bash
git clone <repo-url> ~/Documents/GitProjects/public/ai-config
cd ~/Documents/GitProjects/public/ai-config
./install.sh
```

Safe to re-run. Any existing non-symlink file at a target path is backed up to `~/.ai-config_backup_<timestamp>/` before being replaced.

## Scope

**Automated (v1):** Claude Code, opencode — both expose a plain-file global config (`~/.claude/CLAUDE.md` + `~/.claude/skills/`, `~/.config/opencode/AGENTS.md` + `~/.config/opencode/skills/`), so `install.sh` symlinks directly into them.

**Not automated — manual sync only:**
- **Cursor** — global "User Rules" live inside Cursor's internal settings (not a plain file). Paste the contents of `AGENTS.md` into Settings → Cursor Settings → Rules by hand, and re-paste whenever `AGENTS.md` changes materially.
- **Devin** — runs in an ephemeral cloud sandbox with no local global config; the equivalent is org-level "Knowledge"/"Playbooks" managed via Devin's web UI. Paste relevant instructions there manually.

**Not yet wired (occasional/experimental use — add when they become regular):** Codex CLI (`~/.codex/AGENTS.md`), Kimchi (`~/.config/kimchi/harness/AGENTS.md` + `.../skills`), Windsurf (`~/.codeium/windsurf/global_rules.md`, 6,000-character limit). Adding one is a two-line addition to `install.sh`.

## Design rationale

Full background, alternatives considered (whole-directory symlinks were rejected — see why), and the per-tool research: see the design doc in the PKM vault, `04-Brainstorming/000.09_ai-config-repo-design.md`.
