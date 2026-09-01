# agents-kit

An [Agent Skills](https://agentskills.io/specification) skill, **`init-agents`**, that writes a
project's `AGENTS.md` operating manual and its `MEMORY.md` companion. It runs under Claude Code,
Codex, pi, and opencode from one shared copy.

Two splits do the work:

- **`AGENTS.md` is what to do** (commands, the deploy ladder, the definition of done, traps);
  **`MEMORY.md` is why** (constraints, design posture, decisions). Keeping them apart is what
  stops either from becoming an unread wall of text.
- **`MEMORY.md` is public; `.memory/` is not.** The committed file says "integration tests run
  against the lab machine, not in CI"; the gitignored `.memory/` says which host, which account,
  and which key. Neither half is useful alone.

A tool that wants its own instructions file gets a symlink — `ln -s AGENTS.md CLAUDE.md` — so
there is one manual rather than two that drift.

## Install

One command, from anywhere:

```sh
curl -fsSL https://raw.githubusercontent.com/TOoSmOotH/agents-kit/main/get.sh | sh
```

That clones into `~/.local/share/agents-kit` and symlinks the skill into the two places that
cover all four tools. Re-running it pulls and re-links, so it doubles as the updater. To read
it before running it — which you should, for any `curl | sh` — download it first:

```sh
curl -fsSL https://raw.githubusercontent.com/TOoSmOotH/agents-kit/main/get.sh -o get.sh
less get.sh && sh get.sh
```

<details>
<summary>Or clone it yourself</summary>

```sh
git clone https://github.com/TOoSmOotH/agents-kit.git
cd agents-kit
./install.sh
```

Keep the clone where it is — the links point at it. Re-run `./install.sh` if you move it, and
`./install.sh --uninstall` to remove the links. Because they are symlinks, a `git pull` takes
effect immediately with no re-install.
</details>

| Tool | Picks it up from | Invoke as |
|---|---|---|
| Claude Code | `~/.claude/skills/init-agents` | `/init-agents`, or just ask for an `AGENTS.md` |
| Codex | `~/.agents/skills/init-agents` | ask for an `AGENTS.md` |
| pi | `~/.agents/skills/init-agents` | `/skill:init-agents` |
| opencode | `~/.agents/skills/init-agents` | ask for an `AGENTS.md` |

`~/.agents/skills/` is the standard location Codex, pi, and opencode all discover. Claude Code
does not read it, which is why it gets a second link.

### Into one project, for the whole team

To commit the skill so everyone who clones the repo gets it, run this **from the project root**:

```sh
curl -fsSL https://raw.githubusercontent.com/TOoSmOotH/agents-kit/main/get.sh | sh -s -- --project
```

It vendors a real copy into `.agents/skills/init-agents` and points `.claude/skills/init-agents`
at it with a relative symlink, then tells you what to commit. No machine-wide install needed.

One caveat: **pi only loads project-local skills after you trust the project.** Interactively it
asks once and remembers; non-interactive runs (`-p`) skip untrusted project resources silently,
so pass `--approve` there. The other three need no trust step. A generated `AGENTS.md` is read
by pi either way — trust gates project *skills*, not context files.

<details>
<summary>Alternative: install as a plugin, with no clone</summary>

The repo is also a one-plugin marketplace. Don't do both — Claude Code would then see the skill
twice.

In Claude Code:

```
/plugin marketplace add TOoSmOotH/agents-kit
/plugin install agents-kit@agents-kit
```

Codex's marketplace loader accepts `.claude-plugin/marketplace.json` as well as its own, so the
same manifest works there:

```sh
codex plugin marketplace add TOoSmOotH/agents-kit
```
</details>

---

# Using it

Run it from the repo root, in an **interactive** session. The skill interviews you for the
things it cannot read, so a one-shot non-interactive run will guess instead of ask.

Both walkthroughs below are real output, not illustrations.

## On an existing project

This is the common case, and the one where the skill earns its keep: it reads the repo before
asking you anything, runs every command it is about to document, and reports what it found.

Start it:

```
/init-agents
```

It reads build files, lockfiles, CI workflows, layout, and history first. Then it asks only
what it could not read — what the project deliberately *isn't*, the hard constraints, what the
deploy loop really costs, and what "verified" means here. Then it **runs each candidate
command** before writing it down.

On a small JS repo, one run produced:

```
 .gitignore |   1 +
 AGENTS.md  | 120 +++++++++++++++++++++++++++++++++++++++++++
 CLAUDE.md  |   4 +--
 MEMORY.md  |  70 ++++++++++++++++++++++++++++
```

Three things happened there that are worth calling out.

**It reported contradictions rather than papering over them.** The README said `npm install`,
CI ran `pnpm`, and the committed `pnpm-lock.yaml` was zero bytes. That went into the manual as
a warning, not a silent choice:

```markdown
There is no Makefile or task runner. pnpm 10 is the package manager indicated by CI and the
committed lockfile; do not follow the README's or former `CLAUDE.md`'s npm instruction.
```

**Commands are annotated with what actually happened when run**, including the broken ones —
a documented broken command saves more time than a deleted one, because the next person finds
it in `package.json` anyway:

```sh
node --check src/index.js  # passes; syntax-only check, no dependencies required
pnpm test                  # unverified: install did not complete; no tests are committed
pnpm e2e                   # BROKEN: Playwright is not declared and no e2e tests/config exist
```

**An existing `CLAUDE.md` became a symlink, and the secret in it moved out.** The old file had
`The camera rig is at 10.0.4.22, ssh as birdcam with ~/.ssh/lab_ed25519` — committed. After:

```diff
-# tallybird
-Use npm. Run tests before committing.
-The camera rig is at 10.0.4.22, ssh as `birdcam` with ~/.ssh/lab_ed25519.

 diff --git a/CLAUDE.md b/CLAUDE.md
 new file mode 120000
+AGENTS.md
```

The host, account, and key path moved to `.memory/camera-rig.md`, which is untracked, and the
committed `MEMORY.md` recorded the split as a decision — with the alternative it rejected:

```markdown
### Separate hardware access from public rationale (2026-09-01)

The repository records that camera-backed verification matters, but keeps connection
particulars in `.memory/camera-rig.md`. Committing those particulars was rejected because a
public operating manual should remain safe to publish, while deleting them would make the
integration environment needlessly rediscovered.
```

If you already have a `CLAUDE.md`, `GEMINI.md`, or `.cursorrules`, the skill reads it and asks
before touching it. It will not overwrite a manual you did not tell it to replace.

## On a new project

A new project has almost nothing to read, so the run is mostly interview — and the output is
honest about how little is known yet, rather than padded to look complete.

Starting from a repo containing only a `README.md`, the same skill produced a 104-line
`AGENTS.md` in which the commands section is one line long:

```sh
go version # verified locally: Go 1.27.0; this is not yet a declared project requirement
```

...the CI section says so plainly instead of implying coverage that isn't there:

```markdown
**Doesn't exist:** there is no CI configuration. No automated build, test, formatting,
performance, secret-scanning, or end-to-end check currently gates changes.
```

...and the traps table ships empty, because nothing has gone wrong yet. It earns rows by
accretion; a generator that seeds it with plausible guesses destroys the one thing that makes
it trustworthy.

What the interview *did* capture is the part no amount of code-reading would have found — the
negative space and the real test:

```markdown
**The rule that settles most design arguments:** if it needs a database, it is out of scope.
```

and the definition of done, which names the real user-facing path and what falls short of it:

```markdown
2. **A real feed item landed in the real development Slack channel through the built CLI.**
   Use the untracked `.memory/slack.md` for local verification particulars.
...
Parser unit tests and mocked Slack responses are necessary once they exist, but are **not
sufficient**: they do not prove end-to-end delivery. If the real Slack check cannot be run,
say "local checks passed; real Slack delivery unverified" — never "this works".
```

It also created `.memory/slack.md` for the private webhook and channel — and, not having been
given their values, wrote a placeholder saying so instead of inventing them:

```markdown
The webhook URL and test channel name are private. They have not been provided in this
workspace yet.

- Supply the webhook through `SLACK_WEBHOOK_URL`; do not write its value here because this
  directory is untracked, not encrypted.
```

Both files are meant to grow from here. `AGENTS.md` gains a trap row each time something costs
an hour; `MEMORY.md` gains a decision each time one gets made.

## What goes where

| | Committed | Holds |
|---|---|---|
| `AGENTS.md` | yes | what to do — commands, deploy ladder, definition of done, traps |
| `MEMORY.md` | yes | why — constraints, posture, decisions, the practice |
| `.memory/` | **no** | the particulars: hosts, accounts, key paths, internal URLs |

`.memory/` is gitignored, not encrypted. It holds *where to find* a secret — which host, which
account, which env var — never the secret itself.

## Developing on it

From a clone:

```sh
claude plugin validate .
claude --plugin-dir .
```

Run `/reload-plugins` after editing `SKILL.md` — it is cached otherwise. Under the symlink
install there is no cache to clear.

## Layout

```
get.sh                              one-shot fetch + install (curl | sh entry point)
install.sh                          symlinks the skill into each tool's path
.claude-plugin/plugin.json          plugin manifest
.claude-plugin/marketplace.json     one-plugin marketplace, source "./"
skills/init-agents/
  SKILL.md                          the interview + generation procedure
  templates/AGENTS.template.md      operating-manual skeleton
  templates/MEMORY.template.md      the "why" companion skeleton
  references/memory-notes.md        the public/private split
  references/worked-example.md      one compact filled-in example
```

`SKILL.md` refers to its bundled files by plain relative path, which every tool resolves
against the directory holding `SKILL.md`. It deliberately avoids `${CLAUDE_SKILL_DIR}`, which
only Claude Code expands.

The templates are named `*.template.md` rather than `AGENTS.md` / `MEMORY.md` on purpose: a
file literally named `AGENTS.md` sitting in this tree would be picked up as instructions
when working in this directory.
