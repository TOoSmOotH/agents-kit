---
name: init-agents
description: Write or refresh a project's AGENTS.md operating manual and its MEMORY.md companion. Use when asked to set up AGENTS.md, onboard an agent or a new contributor to a repo, write an operating manual or contributor guide, document how a codebase is built/tested/deployed so an agent can work in it unsupervised, or establish memory conventions for a project.
---

# Initialize a project's agent operating manual

Produce two committed files at the repo root, plus an untracked third:

- **`AGENTS.md` — what to do.** Commands, the run/deploy loop, definition of done, traps.
- **`MEMORY.md` — why.** Constraints, design posture, decisions, hard-won runtime facts.
- **`.memory/` — the part that can't be committed.** Hosts, accounts, key paths. Gitignored.

Two splits, and they are different splits. **What to do vs. why** separates `AGENTS.md` from
`MEMORY.md`, and keeps either from becoming an unreadable 900-line dump: if you find yourself
writing a command in `MEMORY.md` it belongs in `AGENTS.md`, and if you find yourself
justifying a decision in `AGENTS.md` it belongs in `MEMORY.md`.

**Public vs. private** separates `MEMORY.md` from `.memory/`. `MEMORY.md` is committed, so it
names the practice — "integration tests run against the lab rig, not CI". `.memory/` is
gitignored, so it holds the particulars that make that executable — which host, which account,
which key. Neither half is useful alone. See `references/memory-notes.md`.

Templates and references are bundled alongside this file. The paths below are relative to
the directory containing this `SKILL.md`:

- `templates/AGENTS.template.md`
- `templates/MEMORY.template.md`
- `references/memory-notes.md` — the shared memory-note conventions
- `references/worked-example.md` — a short filled-in example

Read the worked example before you start writing. It shows the intended density: specific,
short, and honest about what is broken.

## What makes these files worth having

A generic contributor guide is worthless — the agent already knows what `npm test` does.
The value is entirely in the things that are **true of this repo and surprising**: the
command that looks right and isn't, the check that is green because it silently skipped,
the deploy that quietly ships the last commit instead of your working tree.

So the standard for every line you write is: **would someone lose an hour if this line were
missing?** If not, cut it.

## Write for every agent, not yours

Every agent on this repo reads the same three files, whichever tool it runs under. So do not
name a tool in the generated files, and do not leave a fact another agent needs sitting only
in your own tool's private memory store, where nothing else can see it.

## Procedure

### 1. Locate the repo, and don't clobber

```sh
git rev-parse --show-toplevel
ls AGENTS.md CLAUDE.md GEMINI.md MEMORY.md .cursorrules 2>/dev/null
ls -d .claude .codex .pi .opencode .agents 2>/dev/null
```

If any of those manuals already exists: read it, then ask whether to **refresh** it (keep its
true content, restructure and fill gaps) or **leave it alone**. Never overwrite an existing
manual without being told to.

`AGENTS.md` is the canonical one, because every tool reads it. So where a tool-specific manual
exists and `AGENTS.md` does not, propose consolidating its true content into `AGENTS.md` and
replacing the old file with a **symlink**:

```sh
ln -sfn AGENTS.md CLAUDE.md
```

A symlink, not a copy and not a one-line pointer: it cannot drift, and there is nothing to keep
in sync. Two manuals on one repo is the failure mode to avoid — they diverge, and each agent
trusts whichever one it was pointed at. (Verified: Claude Code follows the symlink and reads the
target. If the project must support Windows checkouts, use a one-line pointer file instead and
say why.)

### 2. Investigate before you interview

Do not ask what you can read. Before asking a single question, gather:

- **Build and task definitions** — `Makefile`, `justfile`, `Taskfile.yml`, `package.json`
  scripts, `pyproject.toml`, `Cargo.toml`, `go.mod` (how many? nested? is there a
  `go.work`?), `mise.toml`, `.tool-versions`.
- **Package manager evidence** — which lockfile actually exists. `pnpm-lock.yaml` and a
  `npm install` in the README is exactly the kind of contradiction this file exists to fix.
- **CI** — every file under `.github/workflows/` (or `.gitlab-ci.yml`, etc.). Note which
  jobs are `continue-on-error`, which are gated behind labels or `if:` conditions, and which
  `exit 0` when a secret is missing. Note duplicate job *names* across workflows.
- **Tests** — frameworks, config files, whether e2e needs a server already running.
- **Layout** — top-level directories and what each is for; anything structurally surprising.
- **Deploy/run tooling** — `docker-compose.yml`, `Dockerfile`s, `deploy/`, `scripts/`,
  helm charts, terraform.
- **History** — `git log --oneline -30`, and the commit message format actually in use.
- **Existing docs** — README, `docs/`, `CONTRIBUTING.md`. Note which are stale; you will
  need this for the "Which docs to trust" section.

### 3. Interview only for what is unreadable

Ask **one question at a time**. Skip any question the investigation already answered. These
are the ones that matter:

1. **What is this, in a sentence — and what is it deliberately *not*?** The negative space
   ("no ORM", "no Kubernetes", "not a fork of X") carries as much signal as the stack list.
2. **Is there a rule that settles most design arguments here?** A single sentence a
   contributor can apply without asking. If there is one, it goes near the top.
3. **Hard constraints** — the things that make a change wrong no matter how good the code
   is. Licensing, offline operation, compatibility, compliance, performance floors.
4. **The run/deploy loop** — how a change is actually observed working, what it costs in
   wall-clock time, and what it destroys (data wiped? cache lost?). Then: what is the
   *smallest* deploy for each kind of change?
5. **What does "verified" mean here?** Specifically: what is the real user-facing path, and
   what commonly passes at the API/unit level while being broken for a real user? This
   becomes step 2 of the definition of done, and it is the single most valuable line in the
   file.
6. **Autonomy** — should an agent keep going between tasks, or check in? What are the
   stop-and-ask categories?
7. **Commit and PR conventions** — subject format, sign-off/DCO, and the trailer policy
   (whether generated-by trailers and footers are wanted). Check the current harness's global
   instruction file first — `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`,
   `~/.config/opencode/AGENTS.md`, or pi's settings — and if it already rules on this, restate
   it rather than ask.

Anything the user does not know or care about: drop the section. An honestly absent section
beats an empty scaffold.

### 4. Run the commands before you write them down

**This is the quality gate.** A command goes into "Commands that work" only after it has
actually been executed here. Record what happened, inline, next to the command:

- It worked → write it plainly.
- It worked but is slow, needs a running server, or needs an env var → say so inline.
- It is **broken** → say it is broken, say why in one clause, and say *don't debug it
  mid-task*. A documented broken command saves more time than a deleted one, because the
  next person will otherwise find it in `package.json` and try it.
- It could not be run (needs credentials, hardware, a deployed environment) → keep it and
  mark it `# unverified — <reason>`.

Never assert that a command works because `package.json` declares it. That is precisely the
staleness this file exists to prevent.

Also record the *meta*-facts you learned while doing this: "there is no Makefile", "always
`cd` into a module first", "the lint script is `check`, not `lint`".

### 5. Generate the files

Fill the templates. Section-by-section guidance lives in the HTML comments inside them —
**delete each comment as you fill its section**, and delete any section that does not apply
to this project rather than leaving a stub.

Two hard rules:

- **Do not invent traps.** The "Traps that have already cost real time" table ships empty,
  with a one-line instruction to append to it. It earns its authority by containing only
  things that actually happened. If you hit a genuine trap during step 4, that one goes in.
- **Do not leave `<PLACEHOLDER>` tokens.** Grep for `<` + uppercase before you finish.

Keep it tight. A first `AGENTS.md` is usually 80–150 lines. It grows by accretion as real
traps are found; it should not be born padded.

### 6. Set up the private half

Read `references/memory-notes.md` and follow it: create `.memory/`, add it to `.gitignore`, and
move anything you were about to commit that names a host, an account, a key path, or an
internal URL into a file there — leaving the practice, and a pointer, in `MEMORY.md`.

If nothing in this project has a private half yet, say so and skip it rather than creating an
empty directory.

### 7. Report

Show the user the two files and name explicitly:

- which commands you ran and which you could not verify,
- which sections you dropped and why,
- anything you found that contradicts the existing README or CI config, since that is a
  real bug you just surfaced.

## Anti-patterns

| Tempting | Why it ruins the file |
|---|---|
| Documenting commands from `package.json` without running them | Reproduces the staleness the file exists to fix. |
| Inventing plausible traps | One fabricated row and no one trusts the table again. |
| Writing "run tests before committing" | Generic advice. The reader knew that. Cut it. |
| Leaving empty scaffolding sections | A heading with nothing under it reads as "nobody maintains this". |
| A 400-line first draft | Length is earned by incidents, not by the generator. |
| Putting rationale in `AGENTS.md` | That is `MEMORY.md`'s job, and mixing them makes both unreadable. |
| Asking what `git log` would have told you | Investigate first, interview second. |
