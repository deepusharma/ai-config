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
./install.sh run
```

Safe to re-run. Any existing non-symlink file at a target path is backed up to `~/.ai-config_backup_<timestamp>/` before being replaced.

## Scope

**Automated:** Claude Code, opencode, Codex CLI, Kimchi, Windsurf, Antigravity — all expose a plain-file global config, so `install.sh` symlinks directly into each:
- Claude Code: `~/.claude/CLAUDE.md` + `~/.claude/skills/`
- opencode: `~/.config/opencode/AGENTS.md` + `~/.config/opencode/skills/`
- Codex CLI: `~/.codex/AGENTS.md` (no global skills mechanism — deprecated/undocumented upstream)
- Kimchi: `~/.config/kimchi/harness/AGENTS.md` + `.../skills/`
- Windsurf: `~/.codeium/windsurf/global_rules.md` (no distinct global skills mechanism; file has a 6,000-character limit — keep `AGENTS.md` under that)
- Antigravity: `~/.gemini/AGENTS.md` — verified working by live test (2026-07-10): it reads this as "global rules (`user_global`)" and follows it correctly. Global skills path unconfirmed on this install (only plugin-internal skill dirs found under `~/.gemini/`) — not wired.

**Not automated — manual sync only:**
- **Cursor** — global "User Rules" live inside Cursor's internal settings (not a plain file). Paste the contents of `AGENTS.md` into Settings → Cursor Settings → Rules by hand, and re-paste whenever `AGENTS.md` changes materially.
- **Devin** (now the same company as Windsurf, following its acquisition — the cloud-agent product, distinct from the Windsurf IDE app above) — runs in an ephemeral cloud sandbox with no local global config; the equivalent is org-level "Knowledge"/"Playbooks" managed via Devin's web UI. Paste relevant instructions there manually.
- **Zed** — its "Rules Library" is stored in a binary LMDB database (`~/.config/zed/prompts/prompts-library-db.0.mdb`), not a plain file — confirmed on this install, contrary to some documentation describing a plain `AGENTS.md`. Not symlink-able.
- **Gemini Code Assist** (the VS Code/JetBrains extension — distinct from Antigravity) — no global mechanism found; customization is repo-scoped only (`.gemini/config.yaml`, `.gemini/styleguide.md`) or stored in extension-internal state.
- **Mistral Vibe** — does not read any workspace/global instruction file at all (confirmed by direct testing) — no mechanism to hook into.

## Design rationale

**Why per-file symlinks, not whole-directory symlinks:** tool config directories (e.g. `~/.claude`, `~/.codex`, `~/.config/opencode`) mix generic config with sensitive, machine-local state — API credentials, chat history, session transcripts, local caches. Since this repo is public, symlinking a whole tool directory into it would risk committing credentials or private conversation history. Only two known-safe, generic artifacts are ever symlinked: `AGENTS.md` and `skills/`.

**Why not every tool is wired:** not every agent exposes a plain-file global config. Cursor's global "User Rules" and Zed's "Rules Library" are both locked in internal databases (a settings DB and an LMDB store, respectively), not files — not symlink-able. Devin runs in an ephemeral cloud sandbox with no local global config at all — its equivalent ("Knowledge"/"Playbooks") is managed via its web UI. Claude Code, opencode, Codex CLI, Kimchi, Windsurf, and Antigravity all expose symlink-able global files and are wired — adding a newly-adopted tool later is a two-line addition to `install.sh` (see the comment at the top of that file).

**Why one flat `AGENTS.md` instead of topic files + a trigger table:** the common-instruction set is small today (nomenclature, timestamp footer, session-maintenance). Split into topic files only if it grows unwieldy — premature splitting for a handful of rules isn't worth the added indirection.
