# AGENTS.md — Common AI Agent Instructions

> Canonical, self-contained global instructions shared across every coding agent and every repo. No internal `@`-imports to other files — this file must stand alone, since it's symlinked directly into each tool's global config slot. Personal/work/career context does NOT belong here — keep it in your private notes/vault instead.

---

## Read Instructions Fully

Before doing anything in a project — even answering a simple question — read that project's instruction file completely. Do not skim or stop at the first section that seems relevant.

- If the project has an `AGENTS.md`, read the whole thing. If `CLAUDE.md`/`GEMINI.md`/etc. are thin pointers to it (see below), follow the pointer and read the real file, not just the pointer.
- If that file defines a session-start protocol (state files to read, chat/session naming, an announcement to output first), execute those steps before responding to anything else — don't answer the user's question first and catch up on protocol afterward.
- Missing a mandatory step because it was buried past the first section is a protocol violation, not a reasonable shortcut.

## Instruction File Convention

- `AGENTS.md` is the canonical instruction file for a project. All real content — rules, context, protocol — lives there.
- `CLAUDE.md`, `GEMINI.md`, and any other agent-specific config file are thin pointers only. Never duplicate content into them — that's how drift happens.
- **Pointer template** (use this, not a bare one-liner):
  ```
  # <FILENAME>

  All agent instructions for this repository live in [AGENTS.md](AGENTS.md).
  The line below imports it via Claude Code's `@` syntax:

  @AGENTS.md

  > **Fallback — do not skip:** if your harness did not automatically load the
  > `@AGENTS.md` import above, read `AGENTS.md` now, before doing anything else
  > here. It contains the real rules, structure, and conventions.
  ```
  The `@AGENTS.md` line auto-expands in Claude Code specifically. For any other tool, it's harmless — either ignored as plain text or (if that tool has its own import syntax) it works the same way — and the fallback line covers the case where nothing auto-loads it. Strictly safer than a bare pointer, never worse.
- This applies at the project level the same way it applies globally here: one instruction file, referenced everywhere, never copy-pasted.
- **Pointers are literal text, not symlinks, inside any git-tracked project repo.** Symlinks are only used for machine-global config slots (what `install.sh` sets up under `~/.claude`, `~/.codex`, etc.) — those live outside any repo, so portability/rendering don't matter. A project's own `CLAUDE.md`/`GEMINI.md` must render as real content on GitHub and survive a plain clone or zip export, which a symlink doesn't reliably do. See `docs/adr/0001-instruction-pointers-not-symlinks.md` for the reasoning.

## AGENTS.md Template

Use this skeleton whenever creating a project's `AGENTS.md` from scratch, or substantially restructuring an existing one. Keep the section names and order — that's what makes moving between projects predictable. Sections marked "if applicable" can be dropped when a project genuinely has no such concern (a docs-only repo doesn't need Testing Rules); content under each section is entirely project-specific.

```
# AGENTS.md — <Project>
One line: what this is; note that CLAUDE.md/GEMINI.md are pointers to this file.

## Project Overview
What it is, in 2-4 sentences. Key constraints if any (deployment tier, quotas, single-user, etc.)

## Tech Stack
Languages, frameworks, key dependencies. Verify version claims against the actual
lockfile/package manifest before writing them down — don't guess (a stale or guessed
version number is worse than no version number).

## Dev Commands / Getting Started   (if applicable)
Install, run, test, build.

## Coding Standards   (if applicable)
File/function size limits, naming conventions, per-language subsections.

## Git Workflow   (if applicable)
Branch naming, commit format, PR requirements.

## Testing Rules   (if applicable)
Coverage requirements, mocking rules, test types.

## [Project-Specific Sections]
Whatever doesn't fit above: milestone/sprint tracking, a domain-specific comparison
table, architecture patterns, specialized workflows. No fixed shape — this is where
a project's actual personality lives. Don't force it into the categories above.

## Session Protocol
State file and naming-prefix declaration (see "Session Protocol" below), or an
explicit opt-out with a reason.
```

## Path References

Within a single project, reference that project's own files with relative paths (e.g. `session-notes/NEXT-SESSION.md`, not an absolute path into the same repo) — keeps instructions portable across clones and machines. Absolute (or `~`-relative) paths are for genuinely external references only: another repo, the vault, a location outside the current project.

## Session Protocol (Default — Opt-Out Must Be Explicit)

This protocol applies to every project by default. A project does not need to declare anything to get it — silence means it's active. To skip it, a project's `AGENTS.md` must say so explicitly, with a reason:

> Opts out of the ai-config session protocol — `<reason, e.g. "throwaway script, no session continuity needed">`.

A project can declare two optional parameters without opting out of anything:

> Session state file: `<relative-path>`. Naming prefix: `<ProjectName>`.

Every project needs *some* declared "what's next" mechanism — a state file, or an explicitly-named alternative (e.g. "Tracked via GitHub Issues, no local state file" or "See 'Current Milestone' section above"). Silent absence isn't acceptable; an unexamined gap is exactly what this is meant to prevent. If a project genuinely hasn't decided yet, say that explicitly too, rather than leaving it unaddressed. If no naming prefix is declared, use free-form descriptive session names instead of `<prefix> - NN`.

**Session start — mandatory, before answering anything:**
1. Read the project's `AGENTS.md` (already required above) and its state file, if one is declared.
2. Output exactly: `📋 Context loaded: [files read]`
3. Ask for a session name: *"Session name? (e.g. '<prefix> - 02'). Skip to proceed unnamed."* — must appear right after the 📋 line, before answering the user's actual question.

**Closure rules:**
- **Compressed context:** if the conversation shows a compression summary, say so and don't proceed until acknowledged: `⚠️ This conversation has compressed context. Responses may be less reliable. Start a new chat to avoid context degradation. Use /clear or open a new session.`
- **Closed chat:** if the user already said something like "close this chat" / "moving to new chat" earlier, and then asks a follow-up, don't answer it — reply only: `⚠️ You closed this chat. Start a new session to keep context clean. Use /clear or open a new session.`
- **Wrap-up starter prompt:** when the user signals the session is ending ("wrapping up", "that's all for today", etc.), generate a ready-to-paste starter prompt before any closure message, as a fenced code block, first line = next session name (`<prefix> - NN`, incremented, or a descriptive name + `- 01` if this one was unnamed):
  ```
  [next session name]

  Continuing from [current session name]:

  Completed:
  - [bullet]

  Pending:
  - [item or "None"]

  Suggested first task:
  [one specific task]
  ```
  Don't duplicate if one was already given earlier in the same session.

A project's own `AGENTS.md` may layer extra steps on top of this template (e.g. creating a per-chat file, a transcript symlink) — the template covers the common core, not every project's specific extras.

## State Files — Federated, Not Centralized

State lives at two levels, and they don't duplicate each other:

- **Top-level index** (e.g. the vault's own `Session-State.md`): a compact, cross-project list — one line per active project, pending items only, linking out to where the real detail lives. Stays short by design; if it's growing because one project's detail is leaking into it, that detail belongs one level down instead.
- **Project-level state file**: the actual pending items, recent decisions, and open threads for that one project. This is what the Session Protocol template's "state file" parameter points to.

**Every project needs one of these, or an explicitly-named alternative** — a state file, GitHub Issues, a milestone/roadmap section in the project's own `AGENTS.md`, whatever fits. The point isn't the specific mechanism, it's that "what's next" always has a documented answer instead of living only in someone's head or an old chat.

**Keep it current as you go, not only at the bookends.** Update the relevant state file immediately after a completed step, a decision, or a plan change — not only when explicitly asked to reconcile, and not only when a session closes cleanly. The Session Protocol's closure rules capture a wrap-up prompt when a session visibly ends, but a session that just trails off (closed laptop, switched task, no "wrapping up" signal) leaves nothing behind unless the state file was already kept current. Treat every substantive step as a trigger to write, not just the two bookends.

New projects should name their state file `Session-State.md` (Title-Case-With-Hyphens — matching the vault's own precedent-setting file, not the all-caps `README.md`/`AGENTS.md` convention, which is for true root-level meta-files, not regular tracked docs). Don't rename existing state files that predate this convention (e.g. a vault file in active use, or one another tool's tooling depends on by exact name) purely for consistency — the churn and break risk isn't worth it for a naming preference. Apply the convention going forward, not retroactively.

## ADRs — Where They Live

Architecture decisions that affect the shared instruction system itself (naming conventions, file structure, protocol design — decisions that apply "to every project") get an ADR here, in `ai-config/docs/adr/`.

A decision specific to one project (why it picked a particular tool, a particular data layout) can get its own ADR in that project's own `docs/adr/`, using the same `NNNN-title.md` numbering convention, numbered independently per repo. Don't route project-specific decisions through `ai-config` just because the pattern originated here — only genuinely cross-project decisions belong in the shared one.

## Nomenclature

- File and directory names: kebab-case (`my-skill-name`, not `MySkillName` or `my_skill_name`).
- Dates in filenames: ISO 8601, `YYYY-MM-DD`.
- Skill directories follow: `skills/<domain>/<skill-name>/SKILL.md`.

## Default Naming Conventions (Code)

Defaults for common languages, for any project that doesn't define its own more specific naming rules in its Coding Standards section. Override there if a project needs something different — don't restate these defaults verbatim when they already apply as-is.

- **Python:** `snake_case` for functions/variables, `PascalCase` for classes, `UPPER_CASE` for constants.
- **TypeScript/JavaScript:** `camelCase` for functions/variables, `PascalCase` for classes/components/interfaces.

## Communication

- Refer to the user with he/him pronouns. Never substitute singular "they."

## Timestamp Footer

Append the current date/time to the bottom of substantive responses. Get it via the `date` command (e.g. `date "+%Y-%m-%d %H:%M %Z (%A)"`) — do not trust a system-reminder's date claim, which can lag the real clock. Format as a small italic footer, e.g. `*2026-07-07 14:32 <TZ> (Tuesday)*`. Skip for one-line confirmations or trivial replies.

## Default Git Workflow

Defaults for any project that doesn't define its own more specific Git Workflow section — override there if a project needs something different (e.g. a stricter commit format, a specific PR-approval requirement).

- **Branch naming:** `feature/description`, `fix/description`, `chore/description`, `test/description`.
- **Commit format:** Conventional commits — `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- **Pushing:** Prefer a feature branch + PR over a direct push to main/master, even when the branch isn't protected — it's the safer default regardless of what's actually configured on GitHub. Whether a branch enforces PR-only changes is a per-repo GitHub setting, not something this file can guarantee — check, don't assume.
- **If a direct push is rejected due to branch protection: never force past it or bypass the check.** Push the commits to a new branch and open a PR instead.

## Session Maintenance

- Prefer small, frequent commits with clear, descriptive messages over large batched ones.
- Before any destructive git operation (`reset --hard`, `checkout --`, force-push), check `git status` first and confirm with the user if uncommitted work would be affected.
- When a task is ambiguous or has multiple reasonable interpretations, ask rather than guessing — especially for anything that mutates shared state or is hard to reverse.
