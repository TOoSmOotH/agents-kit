# AGENTS.md — how to work in this repo

<!-- Preamble: one or two sentences. State who it is for and the what/why split, then the
     numbered read-next chain. Keep the chain to 2-4 entries; a long list is not read.
     Every agent working this repo reads this file, whichever tool it runs under, so never
     name one — no tool-specific paths or commands below. Drop the .memory entry if the
     project has no private half. Keep the symlink line: it is what makes this file the
     single manual instead of one of two that drift. -->

Operating manual for anyone, human or agent, making changes to <PROJECT>. This file is
**what to do**; [`MEMORY.md`](MEMORY.md) is **why**. Read this first, then:

1. [`MEMORY.md`](MEMORY.md) — design posture, constraints, and the decisions behind them.
2. `.memory/` — the untracked local half: hosts, accounts, and paths that cannot be
   committed. Read it before anything that touches a real environment.
3. <NEXT — e.g. a status file, the roadmap, or the design doc for the surface being touched>

**If your tool looks for its own instructions file, symlink it here rather than writing a
second one** — e.g. `ln -s AGENTS.md CLAUDE.md`. A symlink cannot drift; a copy will.

## What <PROJECT> is

<!-- One paragraph. The stack, and then THE NEGATIVE SPACE — "no X, no Y, no Z". The
     omissions tell a contributor more than the inclusions, because they pre-empt the
     proposal you'd otherwise have to reject in review.
     Then, if one exists, the single rule that settles most design arguments. One sentence
     a contributor can apply without asking anyone. Delete this line if there isn't one. -->

<ONE-PARAGRAPH DESCRIPTION + STACK. Then: no <A>, no <B>, no <C>.>

**The rule that settles most design arguments:** <ONE SENTENCE>.

## Hard constraints

<!-- Numbered, 2-5 of them. These are the things that make a change wrong no matter how
     good the code is. Keep the preface verbatim — it tells an agent what to do when a task
     collides with a constraint, which is the whole reason to write them down. -->

If a change violates one of these, say so up front and propose an alternative.

1. **<CONSTRAINT>.** <What it forbids, concretely.>
2. **<CONSTRAINT>.** <What it forbids, concretely.>

## Repo map

<!-- Layout, plus THE STRUCTURAL GOTCHA — the thing that makes an obvious command fail.
     Examples of the kind of line that earns its place: "there is no root go.mod, so
     `go build ./...` from the root fails — cd into a module first"; "src/ is a symlink";
     "the lockfile is pnpm's, npm install will silently produce a different tree". -->

<LAYOUT — a short list or fenced block, one line per top-level dir.>

**<THE STRUCTURAL GOTCHA.>** <What breaks, and what to do instead.>

## Commands that work

<!-- Every command here MUST have been run. Meta-claims first ("there is no Makefile",
     "always cd into a module first"), then copy-pasteable blocks grouped by area.
     Put each caveat INLINE next to its command, not in a footnote:
       - needs a server already running
       - requires env var X
       - BROKEN: <one clause>. Don't debug it mid-task.
       - # unverified — <reason>
     A documented broken command is worth more than a deleted one: the next person will
     find it in the task file anyway and burn an hour on it. -->

<META-CLAIM — e.g. "There is no Makefile; commands are typed directly." Delete if untrue.>

```sh
<COMMAND>          # <what it does / what it needs / whether it lies>
```

## Match deploy scope to change scope

<!-- Delete this whole section if the project has no deploy or run loop.
     Lead with the COST of the full loop in wall-clock time AND in what it destroys
     (data wiped, cache lost, snapshot rolled back). Without the cost, nobody has a reason
     to use the smaller options in the table. -->

A full <FULL DEPLOY COMMAND> takes about <N minutes> and <WHAT IT DESTROYS>. Use the
smallest unit that delivers the fix.

| Change touches | Minimum deploy |
|---|---|
| <PATH/AREA> | <SMALLEST STEPS THAT SUFFICE>. ~<time>. |
| <PATH/AREA> | <SMALLEST STEPS THAT SUFFICE>. ~<time>. |
| <ANYTHING ELSE> | Full <FULL DEPLOY COMMAND>. Don't try to incrementalize. |

### Mechanics you can't guess

<!-- Behaviour of the deploy tooling that is invisible from reading the code, and that
     fails SILENTLY. The archetype: "the bundler ships committed HEAD only — uncommitted
     work is not deployed, and nothing warns you." Delete the section if there are none. -->

- <MECHANIC>.

## <THE MOST COMMON CROSS-CUTTING CHANGE>

<!-- Optional but high value. Pick the change type that is done most often AND most often
     looks finished while silently doing nothing (adding a field, adding a route, adding a
     config key). Enumerate EVERY layer in order, and name the test that guards it.
     Delete the section if no such change type exists. -->

<Why this looks finished when it isn't.> A <THING> is not "added" until it has been threaded
through every layer below, in this order:

1. **<Layer>** — `<file>`. <What to do.>
2. **<Layer>** — `<file>`. <What to do.>

<THE TEST THAT CATCHES A MISSED LAYER>, and it is much faster than discovering the same
problem downstream.

## Definition of done

<!-- Ordered. Step 2 is the important one: it must name the REAL user-facing path and say
     what commonly passes while being broken for a real user. Keep the named escape phrase —
     it gives an honest out, which is what stops "this works" from being claimed untested. -->

In order. A step skipped is a step to declare out loud.

1. Tests pass in every area you touched; <FORMATTER CHECK> is clean on the files you changed.
2. **<YOU EXERCISED THE REAL USER-FACING PATH.>** <Concretely what that means here.>
3. Rebased on the latest `<MAIN BRANCH>`.
4. Pushed, and a **PR is open**. Local commits are not delivery.

On step 2: <WHAT PASSES BUT ISN'T SUFFICIENT — e.g. API 200s, green unit tests, a
programmatic login that bypasses the real one> are necessary but **not sufficient**.
<EXAMPLES OF THINGS THAT PASSED THOSE AND FAILED FOR A REAL USER.> If you genuinely cannot
do the real check, the phrase is "<ESCAPE PHRASE, e.g. API verified, UI path untested>" —
never "this works".

## Working in parallel

<!-- Delete if work is never parallelized. The last table row must be ambiguous -> serial;
     that default is the point of the table. -->

<WORKTREE / BRANCH NAMING CONVENTION.>

| Situation | Mode |
|---|---|
| Independent areas, independent designs | parallel |
| Same module or same files | serial |
| Same schema or shared interface | serial |
| Ambiguous | serial |

<N> concurrent agents is the comfortable cap. **No agent merges to `<MAIN BRANCH>`
unsupervised.** <ANY AREA NEEDING A SECURITY REVIEW PASS.>

## Commits and PRs

- One logical change per commit. Imperative subject ≤ <N> chars, scoped:
  `<area>: <what changed>`.
- <SIGN-OFF / DCO REQUIREMENT, or delete.>
- <TRAILER POLICY — state it explicitly either way, since it overrides tool defaults.>
- <NEW-FILE REQUIREMENTS — license headers, etc., or delete.>

## Naming

<!-- Delete unless there are naming rules a reviewer would actually bounce a PR over. -->

- <PREFIX / CASING RULES.>
- Forbidden in new code: <TOKENS>, and <VOCABULARY BEING MIGRATED AWAY FROM>.

## What CI actually gates

<!-- The honesty section. Most repos' docs overstate this. Four buckets — the second and
     fourth are the ones that save real time, because a green check that didn't run reads
     exactly like a green check that passed. -->

**Blocking:** <JOBS THAT GENUINELY FAIL THE BUILD.>

**Advisory — looks red, does not block:** <JOBS THAT ARE continue-on-error, AND WHY.>

**Doesn't exist:** <CHECKS PEOPLE ASSUME ARE THERE AND AREN'T.>

**Conditional — may silently skip:** <LABEL- OR SECRET-GATED JOBS.> Several `exit 0` when
their preconditions are absent, so a green check there may mean "didn't run".

<ANY NAME COLLISIONS BETWEEN JOBS, AND WHO MERGES.>

## Traps that have already cost real time

<!-- Ships EMPTY. Do not seed this with plausible-sounding entries — the table's whole
     authority comes from every row being something that actually happened.
     Index rows by the OBSERVABLE SYMPTOM, not by the subsystem, so someone can find their
     own error message here. Append a row each time a real one is found. -->

Append a row whenever something costs more than an hour. Index by the symptom you saw, not
by the component at fault.

| Trap | What to do |
|---|---|
| | |

## Environment

<!-- This file is committed, so name WHAT exists, not WHERE it is: "one staging host, one
     database" belongs here; the address, the account, and the key path belong in .memory/.
     Never inline a secret in either place. -->

- <WHAT EXISTS — hosts, services, ports by role. Specifics go in `.memory/<FILE>.md`.>
- Credentials live in `<GITIGNORED FILE>` — reference the file, never paste secrets into
  code, docs, or commit messages.

## Which docs to trust

<!-- Name individual files and say what is wrong with each. A vague "some docs are out of
     date" helps nobody. Delete if the docs are genuinely all current. -->

**Authoritative and current:** <FILES>.

**Stale — verify before trusting:** <FILE> <WHAT IS WRONG WITH IT>.

Fix a stale line when you pass through it.

## Keep going

<!-- The autonomy grant and its counterweight must travel together. The grant alone
     degrades into "never verify"; the counterweight alone degrades into "ask permission
     constantly". The reconciliation is batching. Delete both halves or neither. -->

<AUTONOMY GRANT — when to keep moving without checking in.> Stop and ask only for
<STOP-AND-ASK CATEGORIES: load-bearing architectural calls, policy gray zones, and
hard-to-reverse actions>.

This does **not** dilute the verification gate above. The two fit together by batching: keep
moving through code and tests without checking in, then <DEPLOY/VERIFY> once and walk the
real user paths for everything in that batch together. The <EXPENSIVE STEP> amortised across
a batch is cheap; a batch shipped without anyone doing it is what the rule exists to stop.
The check gates the **PR**, not every commit.
