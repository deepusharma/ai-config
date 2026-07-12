# ADR 0001: Instruction pointers are literal files, not symlinks, inside project repos

## Status

Accepted — 2026-07-12

## Context

We use a two-layer instruction system:

1. **Machine-global:** `ai-config/AGENTS.md` is the single source of truth, wired into every tool's global config slot (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`, `~/.gemini/AGENTS.md`, etc.) via real symlinks created by `install.sh`.
2. **Per-project:** each project has its own `AGENTS.md` as the canonical file, with `CLAUDE.md`/`GEMINI.md` as thin pointers to it, so multiple agent tools reading the same repo get the same instructions without duplication.

The question: should the per-project pointers (`CLAUDE.md` → `AGENTS.md`) also be real symlinks, matching how the global layer works?

## Decision

No. Per-project pointers are literal small text files containing `Read \`AGENTS.md\` in this folder and follow it.` — not symlinks.

## Reasoning

The global layer and the project layer have different constraints:

- **Global config slots** (`~/.claude`, `~/.codex`, etc.) live outside any git repository. They exist only on this machine, are never committed, cloned, or viewed on GitHub. A real symlink is strictly better here: zero drift risk, and `install.sh` can safely recreate it any time.
- **Project repos** (e.g. `from-chatbot-to-personal-ai`, a public GitHub repo) get cloned onto other machines, browsed on GitHub's web UI, and potentially exported as a zip/tarball rather than a git clone. Symlinks are a worse fit there:
  - GitHub's file browser shows a symlink as a small arrow entry pointing at a path string — it does not render the target's content inline. A visitor clicking `CLAUDE.md` expecting to read instructions sees a path, not the instructions.
  - Symlink support depends on `core.symlinks` and filesystem support. It has historically been inconsistent on Windows checkouts.
  - A zip/tarball export of a repo (rather than `git clone`) turns a symlink into a plain file containing the literal target path string — silently breaking the pointer with no error.

A literal one-line pointer file avoids all three failure modes and costs nothing extra to maintain — it never needs editing once written.

## Consequence

- Global config: real symlinks, managed by `ai-config/install.sh`.
- Project-level `CLAUDE.md`/`GEMINI.md`: literal one-line text files, never symlinks, even though git can technically track symlinks.
