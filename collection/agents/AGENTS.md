# Personal Agent Instructions

Global preferences for any coding agent on this machine. Project instructions
override these where they conflict.

## Working rules

- NEVER create documentation files unless explicitly asked.
- NEVER commit secrets, credentials, or `.env` files.

## Answer style — adaptive TLDR

Pick the LEAST verbose tier the stakes warrant. Detail is pulled, not pushed.
**The line budget is a hard cap.** When the pieces don't fit, cut pieces —
never widen the budget. Detail is pulled, not pushed.

Governs **interactive** answers only. Output for later readers (PR bodies,
issue comments, commit messages) has **no cap** — there, omitted detail is
destroyed, not deferred.

Brevity means *cutting what the reader doesn't need*, not compressing prose
into fragments. Complete sentences at every tier.

- **T0 · fact** — single fact / yes-no → 1 line, answer only.
- **T1 · small** — done, or a question / blocker / progress note → ≤4 lines.
- **T2 · substantive** — a tradeoff that changes what you'd *do*, or an
  opinion that was asked for → ~5–12 lines.
- **T3 · full** — high-risk scope (per-project list) · irreversible · or the
  user says "full" → TLDR first, THEN: context · what changed · checks run /
  NOT run · risks · decisions & asks · next.

Nothing is mandatory except the answer. Add a risk, an unverified check, or a
next step only when it changes the reader's next move; a recommendation only
when there is a real choice; a confidence flag only when genuinely unsure.
Default to leaving them out.

**Hard override — "tldr" / "short" / "one line" / "just the answer":** answer
only. No recommendation, no risks, no next step, no finalization, no offer of
more. Only hook-enforced footers survive. This beats every rule above.

Escalate on request to exactly the asked scope. Go T3 unprompted only for
high-risk or irreversible work.

## rtk — token-optimized CLI proxy

When installed, prefer `rtk <cmd>` for dev/git/shell — it filters output for
large token savings. A hook may already rewrite transparently; don't stack
(`rtk rtk …`). `rtk proxy <cmd>` runs unfiltered when filtering mangles
output you need whole. Read/Grep/Glob bypass rtk by design.

## Finalization

After a **work** turn that changed something: what changed · checks run ·
checks NOT run · unresolved risks. Not on answer-only turns, and never under
the tldr override. When done, say so and STOP.
