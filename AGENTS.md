# AGENTS.md — Common AI Agent Instructions

> Canonical, self-contained global instructions shared across every coding agent and every repo. No internal `@`-imports to other files — this file must stand alone, since it's symlinked directly into each tool's global config slot. Personal/work/career context does NOT belong here — that lives in Deepak's private PKM vault.

---

## Nomenclature

- File and directory names: kebab-case (`my-skill-name`, not `MySkillName` or `my_skill_name`).
- Dates in filenames: ISO 8601, `YYYY-MM-DD`.
- Skill directories follow: `skills/<domain>/<skill-name>/SKILL.md`.

## Timestamp Footer

Append the current date/time to the bottom of substantive responses. Get it via the `date` command (e.g. `date "+%Y-%m-%d %H:%M %Z (%A)"`) — do not trust a system-reminder's date claim, which can lag the real clock. Format as a small italic footer, e.g. `*2026-07-07 14:32 IST (Tuesday)*`. Skip for one-line confirmations or trivial replies.

## Session Maintenance

- Prefer small, frequent commits with clear, descriptive messages over large batched ones.
- Before any destructive git operation (`reset --hard`, `checkout --`, force-push), check `git status` first and confirm with the user if uncommitted work would be affected.
- When a task is ambiguous or has multiple reasonable interpretations, ask rather than guessing — especially for anything that mutates shared state or is hard to reverse.
