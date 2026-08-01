# Versioned Global Agent Instructions (AGENTS.md + CLAUDE.md)

**Date:** 2026-08-01 · **Status:** Approved (Option A)

## Goal

Version-control the user-global agent instructions in this dotfiles repo and
deploy them to the host on every flake build. One canonical file serves both
the cross-agent `AGENTS.md` standard and Claude Code's `CLAUDE.md`.

Content scope: **personal preferences only** — communication style, output
format, personal tooling habits. Project-specific machinery (frameleap's d2,
OpenSpec, Linear, Context Canary, naming rules) stays in the respective
project CLAUDE.md.

## Layout

```
collection/agents/
├── AGENTS.md    # canonical, agent-neutral
└── CLAUDE.md    # thin Claude shim: @AGENTS.md import + Claude-only bits
```

- Claude Code does not read `AGENTS.md` natively; official guidance is a
  `CLAUDE.md` that imports it (`@AGENTS.md`) with optional Claude-specific
  lines below — exactly the shim above.
- Existing `~/.claude/CLAUDE.md.bak` / `RTK.md.bak` are outdated and NOT a
  content source; they are deleted after the first successful switch.

## Content split

**AGENTS.md (agent-neutral):**

1. **Answer style — adaptive TLDR** — the T0–T3 tier system + must-haves
   matrix, written project-agnostic (high-risk list phrased as "per-project
   list"; project-mandated footers ride on top of tier budgets).
2. **rtk** — prefer `rtk <cmd>` for dev/git/shell when installed;
   `rtk proxy <cmd>` as the unfiltered escape hatch; meta commands
   (`rtk gain`, `rtk discover`). Phrased neutrally — the Claude Code
   hook-rewrite is mentioned as "a hook may already rewrite these
   transparently". rtk is NOT Claude-specific, so it lives here, not in the
   shim.
3. **Portable working rules** — do what's asked, no more; don't create files
   (esp. docs) unless needed; never commit secrets/`.env`; read before edit.
4. **Finalization & task closure style** — end-of-task summary (changed ·
   checks run · not run · risks); when done, say so plainly and stop.

**CLAUDE.md (Claude-only shim):**

- `@AGENTS.md` import (first line).
- **Model guidance** — Sonnet for routine, Opus/Fable for think/debug/
  hard-to-reverse; honor the active session model.
- Room for future Claude-only bits (skill triggers, etc.). Kept minimal.

## Deployment (home-manager, every flake build)

`collection/nix/home.nix`:

```nix
home.file.".claude/AGENTS.md".source =
  config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/collection/agents/AGENTS.md";
home.file.".claude/CLAUDE.md".source =
  config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/collection/agents/CLAUDE.md";
```

- `mkOutOfStoreSymlink` (not `home.file.source` store copy): links point at
  the live repo files, so edits — including via `/memory` — apply instantly
  with no rebuild; the flake still owns link creation on every switch and
  restores them if anything renames/removes them.
- Both files link into `~/.claude/` so the relative `@AGENTS.md` import
  resolves regardless of whether Claude resolves it from the symlink path or
  its target.
- Other agents are one-liners later (`~/.codex/AGENTS.md`,
  `~/.gemini/GEMINI.md` + `contextFileName`) — deliberately NOT wired now;
  neither directory exists on this machine.

## Side effects & housekeeping

- `link.sh` symlinks every `collection/*` dir into `~/.config/<name>`, so a
  harmless `~/.config/agents` link appears. Naming the dir `agents` (not
  `claude`) is deliberate — `~/.config/claude` would look load-bearing.
- Root `.gitignore` whitelists top-level dirs; `!docs/` is added so this spec
  is trackable.
- Cleanup after first verified switch: delete `~/.claude/CLAUDE.md.bak` and
  `~/.claude/RTK.md.bak`.

## Verification

1. `nix-rebuild` succeeds; `readlink ~/.claude/CLAUDE.md` →
   `/etc/dotfiles/collection/agents/CLAUDE.md` (via home-manager indirection).
2. New Claude Code session: `/context` lists the user CLAUDE.md under Memory
   files (import expanded).
3. Edit `collection/agents/AGENTS.md`, start a new session **without**
   rebuilding → change is visible.

## Out of scope / follow-ups

- **frameleap dedup**: frameleap's CLAUDE.md carries its own specialized
  answer-style section; once the global file is live, frameleap sessions load
  both. Consistent but duplicated context — slimming frameleap's copy to a
  delta over the global baseline is a separate change in that repo.
- Wiring codex/gemini context files.
- Moving other personal Claude assets (output styles, skills) into the repo.
