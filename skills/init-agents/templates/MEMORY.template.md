# MEMORY.md — why <PROJECT> is the way it is

<!-- Scope note first. It is what stops this file and AGENTS.md from collapsing into each
     other, which is the failure mode that makes both unreadable. Keep it verbatim. -->

This file is **why**. [`AGENTS.md`](AGENTS.md) is **what to do**. Constraints, design
posture, and the reasoning behind decisions live here; commands, workflows, and checklists
live there. If you find yourself writing a command here, it belongs in `AGENTS.md`.

**This file is public.** It is committed, so it holds the practice and the reason — never a
hostname, account, key path, or internal URL. Those go in the untracked `.memory/`, and a
line here points at them: "runs against the lab machine — see `.memory/`".

<!-- A hand-maintained table of contents pays for itself once this file passes ~200 lines.
     Delete it until then. -->

## Project context

<!-- What this is, who it is for, and what it is replacing or competing with. The framing a
     new contributor needs before any of the decisions below make sense. -->

## Design posture

<!-- The stance that generates decisions rather than the decisions themselves: what gets a
     clean break vs. what preserves compatibility, what is allowed to be slow, where
     duplication is preferred over coupling. If AGENTS.md has a "rule that settles most
     design arguments", this is where that rule is justified at length. -->

## Hard constraints

<!-- The same constraints AGENTS.md lists, but here with the REASONING — the customer
     requirement, the legal position, the incident that produced them. AGENTS.md tells an
     agent what not to do; this tells them why arguing about it is settled. -->

## Key decisions

<!-- One short subsection per decision that a newcomer would otherwise re-litigate.
     For each: what was chosen, what was rejected, and the deciding factor. Date them.
     A decision without its rejected alternative gets reopened every six months. -->

### <DECISION>

<What was chosen, what was rejected, and why. Date it.>

## Execution model

<!-- How work is actually organized: who decides, how work is split, what gets reviewed by
     a human, what an agent may do unsupervised. The rationale behind AGENTS.md's
     "Working in parallel" table. -->

## Working preferences

<!-- Durable preferences the project owner has stated, with enough context that they can be
     applied to situations they didn't literally cover. Promote these from private memory
     notes once they have held up across more than one occasion. -->

## Runtime realities

<!-- Hard-won facts about how the system actually behaves that are not derivable from the
     code: a component whose healthcheck lies, a queue that deadlocks when full, a cache
     that must be warmed. AGENTS.md's traps table says what to DO about these; this section
     explains the mechanism, so a new instance of the same class of bug is recognizable.
     State the mechanism here; if naming it requires a host or an account, name that in
     .memory/ and refer to it from here. -->

## Maintenance

<!-- Keep this section close to verbatim. It is what keeps the file alive. -->

**This file is the authoritative copy**, because it is the one that travels with the repo —
every branch, every worktree, every clone, every contributor who was not in the conversation
where a decision was made, and every agent that was not the one which learned it.

`.memory/` is the other half, not a lesser one: it holds what this file is not allowed to say.
Neither works alone. When you write something here that only makes sense on one machine, move
that part across and leave the reason behind.

**Scope:** this file is *why*; `AGENTS.md` is *what to do*. If you find yourself writing a
command here, move it there.

**Prune ruthlessly.** If a constraint changes, edit it. If a decision stops being
load-bearing, delete it. A `MEMORY.md` that only ever grows stops being read, and an
unread file is worse than no file, because people assume it is current.
