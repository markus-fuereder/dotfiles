# Versioned Global Agent Instructions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Version the user-global agent instructions (canonical `AGENTS.md` + Claude shim `CLAUDE.md`) in this dotfiles repo and deploy them into `~/.claude/` on every flake build.

**Architecture:** Two tracked files in `collection/agents/`; home-manager `mkOutOfStoreSymlink` entries in `collection/nix/home.nix` link both into `~/.claude/` so edits apply live (no rebuild) while the flake owns link creation. Spec: `docs/superpowers/specs/2026-08-01-global-agent-instructions-design.md`.

**Tech Stack:** nix-darwin + home-manager (flake at `collection/nix/`), plain markdown.

## Global Constraints

- Content is **personal preferences only** — no project machinery (no d2/OpenSpec/Linear/Context Canary/naming rules; those stay in project CLAUDE.md files).
- The directory MUST be named `collection/agents/` (link.sh auto-links every `collection/*` dir into `~/.config/<name>`; `~/.config/agents` is harmless, `~/.config/claude` would look load-bearing).
- rtk guidance lives in `AGENTS.md` (agent-neutral phrasing); the shim holds only Claude-specific content.
- `~/.claude/CLAUDE.md.bak` / `RTK.md.bak` are NOT content sources; delete them only after verification passes.
- This repo has no test suite; every task ends with a concrete verification command instead.

---

### Task 1: Create the instruction files

**Files:**
- Create: `collection/agents/AGENTS.md`
- Create: `collection/agents/CLAUDE.md`

**Interfaces:**
- Produces: `collection/agents/AGENTS.md` and `collection/agents/CLAUDE.md` at exactly these paths — Task 2's nix symlinks point at `/etc/dotfiles/collection/agents/<name>` (the canonical install path; `/etc` → `/private/etc` on macOS).
- `CLAUDE.md` line 1 MUST be `@AGENTS.md` (Claude Code import syntax, resolves relative to the file's directory).

- [x] **Step 1: Create `collection/agents/AGENTS.md`** with exactly this content:

````markdown
# Personal Agent Instructions

Global preferences for any coding agent on this machine. Project instructions
override these where they conflict.

## Working rules

- Do what's asked; nothing more, nothing less.
- NEVER create files unless needed — prefer editing existing ones.
- NEVER create documentation files unless explicitly asked.
- ALWAYS read a file before editing it.
- NEVER commit secrets, credentials, or `.env` files.

## Answer style — adaptive TLDR

Default to the LEAST verbose tier the stakes warrant. Length + which sections
appear scale with complexity/risk. The user pulls detail — don't push it.
This governs DEPTH of interactive answers. Project-mandated sections and
footers ride ON TOP of the tier budget — compress them, never drop them.
Budgets bind the turn's FINAL answer; tool narration stays minimal +
uncounted. Output written for later readers (PR bodies, issue comments,
commit messages) has NO tier cap — there, omitted detail is destroyed, not
deferred.

**Tiers** (multiple triggers in one turn → highest wins; tie → higher)

- **T0 · fact** — single fact / yes-no → 1 line, answer only.
- **T1 · small** — task done with nothing to flag (no fork · no tradeoff
  worth naming · nothing unverified), or a choice whose alternatives aren't
  worth stating → ≤4 lines. Also the **catch-all**: clarifying question,
  blocker/error, mid-task progress, refusal → T1 shape (the thing + what's
  needed / next).
- **T2 · substantive** — any named tradeoff, open fork, real risk, or
  opinion/discussion → mini-report (rec → risks → asks → next),
  bullets/table, ~5–12 lines. (Opinion → T2 depth, skip the report
  skeleton.)
- **T3 · full** — high-risk scope (per-project list; typically
  auth/schema/migrations/infra/security) · irreversible/destructive · or the
  user says "full" → **TLDR of the topic/problem first, THEN the full
  report.** Fixed sections: context · what changed/found · checks run / NOT
  run · risks · decisions & asks · next. Omit a section only by naming it
  n/a.

**Must-haves × tier** (✅ always · "✅ if X" = required whenever X holds,
never cut for brevity · ◐ = judgment call · — omit):

| Element | T0 | T1 | T2 | T3 |
|---|---|---|---|---|
| Answer / result | ✅ | ✅ | ✅ | ✅ |
| Recommendation (+ 1-line why) | — | ◐ if a choice | ✅ | ✅ |
| Risks / caveats | — | ◐ if real | ✅ if any | ✅ thorough |
| Decisions / asks (called out) | — | ◐ if fork | ◐ if fork | ◐ if fork |
| Next step / stopping point | — | ✅ | ✅ | ✅ |
| Checks run / NOT verified | — | ◐ if code | ✅ if verifiable | ✅ always |
| Confidence flag (when unsure) | — | — | ◐ if uncertain | ◐ if uncertain |

Budget tiebreak: if elements overflow the line budget, drop conditionals
first (rec before checks); never drop a ✅.

**Escalation:** user asks for more → expand exactly the asked scope at the
current tier; the word "full" (or any T3 trigger) → T3.

**Auto-expand:** jump to T3 unprompted ONLY for high-risk scope or
irreversible/destructive ops. Otherwise sit at the warranted tier; if real
depth is held back, end with one line — "want the detail on X?" — pull,
don't push.

## rtk — token-optimized CLI proxy

When `rtk` is installed, prefer `rtk <cmd>` for dev/git/shell commands — it
filters output for large token savings. A hook may already rewrite commands
to `rtk` transparently; don't stack (`rtk rtk …`).

- `rtk proxy <cmd>` — run unfiltered when the filtering mangles output you
  need whole. The escape hatch, not the default.
- Native file tools (Read/Grep/Glob) bypass rtk by design — don't route
  reads through the shell to force it.
- Meta: `rtk gain` (savings analytics) · `rtk discover` (missed
  opportunities).

## Finalization & task closure

- Before the final answer of a work turn, account for: what changed · checks
  run · checks NOT run · unresolved risks/assumptions — compressed to the
  active tier.
- When a task is genuinely done, say so plainly and STOP. Name a clean
  stopping point; don't invent next steps or keep going.
````

- [x] **Step 2: Create `collection/agents/CLAUDE.md`** with exactly this content:

````markdown
@AGENTS.md

# Claude Code

## Model guidance

- **Sonnet** — capable default for routine build/fix work. **Opus / Fable**
  — think/debug, hard-to-reverse changes, security/schema work. Honor the
  active session model — don't force a downgrade. On a lighter model, if
  routine work escalates to think/debug → tell the user to switch up.
````

- [x] **Step 3: Verify the files are tracked and well-formed**

Run: `git -C /etc/dotfiles status --short collection/agents/ && head -1 /etc/dotfiles/collection/agents/CLAUDE.md`
Expected: both files listed as untracked/added (NOT ignored — `collection/` is whitelisted in `.gitignore`); first line of CLAUDE.md is exactly `@AGENTS.md`.

- [x] **Step 4: Commit**

```bash
git -C /etc/dotfiles add collection/agents/
git -C /etc/dotfiles commit -m "feat: Add versioned global agent instructions"
```

---

### Task 2: Deploy via home-manager

**Files:**
- Modify: `collection/nix/home.nix` (inside the `home = { … }` attrset, after the existing `file.".tmux/plugins/tmux-monokai-pro"` line at `collection/nix/home.nix:28`)

**Interfaces:**
- Consumes: `collection/agents/AGENTS.md` + `collection/agents/CLAUDE.md` from Task 1 (referenced by absolute install path `/etc/dotfiles/collection/agents/…`).
- Produces: `~/.claude/AGENTS.md` and `~/.claude/CLAUDE.md` symlinks after the next `darwin-rebuild switch` (Task 3 verifies).
- `home.nix`'s module args already include `config` (line 1), which provides `config.lib.file.mkOutOfStoreSymlink`.

- [x] **Step 1: Add the two symlink entries to `home.nix`**

Insert directly after line 28 (`file.".tmux/plugins/tmux-monokai-pro".source = tmux-monokai-pro;`):

```nix
    # Global agent instructions — AGENTS.md is the canonical cross-agent file,
    # CLAUDE.md a thin shim (@AGENTS.md import + Claude-only bits). Claude Code
    # does not read AGENTS.md natively, hence the shim. Out-of-store symlinks,
    # NOT store copies: edits in /etc/dotfiles (incl. via /memory) apply
    # instantly without a rebuild, while every switch still (re)creates the
    # links. Both live in ~/.claude/ so the relative @AGENTS.md import resolves
    # whether Claude reads it through the link or its target.
    file.".claude/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/collection/agents/AGENTS.md";
    file.".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/collection/agents/CLAUDE.md";
```

(Repeated `file.…` attrpaths merge in Nix; no restructuring of the existing tmux line is needed.)

- [x] **Step 2: Syntax-check the flake**

Run: `nix --extra-experimental-features "nix-command flakes" flake check "$(readlink -f ~/.config/nix)" 2>&1 | tail -5`
Expected: no evaluation errors mentioning `home.nix` (pre-existing warnings are fine).

- [x] **Step 3: Commit**

```bash
git -C /etc/dotfiles add collection/nix/home.nix
git -C /etc/dotfiles commit -m "feat: Deploy global agent instructions via home-manager"
```

---

### Task 3: Switch, verify, clean up

**Files:**
- None (host state only: `~/.claude/`)

**Interfaces:**
- Consumes: Task 2's home-manager entries.

- [x] **Step 1: Rebuild** (needs sudo — if the session can't elevate, ask the user to run it, e.g. via `! sudo darwin-rebuild switch --flake "$(readlink -f ~/.config/nix)#shared"`)

Run: `sudo darwin-rebuild switch --flake "$(readlink -f ~/.config/nix)#shared"`
Expected: activation completes without error.

- [x] **Step 2: Verify the link chain**

Run: `readlink ~/.claude/CLAUDE.md ~/.claude/AGENTS.md && cat ~/.claude/CLAUDE.md | head -1`
Expected: both are symlinks (into the home-manager store indirection, which itself points at `/etc/dotfiles/collection/agents/…`); `cat` succeeds and prints `@AGENTS.md` — proving the chain resolves.

- [x] **Step 3: Verify live-edit (no rebuild)**

Run: `printf '\n<!-- live-edit probe -->\n' >> /etc/dotfiles/collection/agents/AGENTS.md && tail -1 ~/.claude/AGENTS.md && git -C /etc/dotfiles checkout collection/agents/AGENTS.md`
Expected: `tail` shows `<!-- live-edit probe -->` through `~/.claude/AGENTS.md` without any rebuild; checkout restores the file.

- [x] **Step 4: Manual session check (user)**

Ask the user to run `/context` in a NEW Claude Code session and confirm the user CLAUDE.md appears under **Memory files** (import expanded — answer-style content present).

- [x] **Step 5: Delete stale backups** (only after Steps 1–4 pass)

Run: `rm ~/.claude/CLAUDE.md.bak ~/.claude/RTK.md.bak && ls ~/.claude/*.bak 2>&1`
Expected: `ls` reports no matches.

- [x] **Step 6: Done** — no commit (host-state cleanup only). Report completion.
