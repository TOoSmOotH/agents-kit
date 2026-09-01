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

## What the skill does

1. Reads the repo — build files, CI workflows, lockfiles, layout, history — before asking
   anything.
2. Interviews only for what can't be read: what the project deliberately isn't, the hard
   constraints, the real cost of the deploy loop, and what "verified" actually means here.
3. **Runs each candidate command** and records what happened, including "this one is broken,
   don't debug it mid-task". A command it can't run is marked unverified rather than
   asserted.
4. Writes both files, dropping sections that don't apply rather than leaving empty
   scaffolding. The traps table ships empty — it earns its authority by containing only
   things that actually happened.
5. Sets up `.memory/` for whatever couldn't be committed, and adds the `.gitignore` line —
   or says the project has no private half and skips it.

## Install

```sh
git clone https://github.com/TOoSmOotH/agents-kit.git
cd agents-kit
./install.sh
```

That symlinks `skills/init-agents/` into the two places that cover all four harnesses. Keep the
clone where it is — the links point at it. Re-run `./install.sh` if you move it, and
`./install.sh --uninstall` to remove the links. Because they are symlinks, a `git pull` takes
effect immediately with no re-install.

| Harness | Picks it up from | Invoke as |
|---|---|---|
| Claude Code | `~/.claude/skills/init-agents` | `/init-agents`, or just ask for an `AGENTS.md` |
| Codex | `~/.agents/skills/init-agents` | ask for an `AGENTS.md` |
| pi | `~/.agents/skills/init-agents` | `/skill:init-agents` |
| opencode | `~/.agents/skills/init-agents` | ask for an `AGENTS.md` |

`~/.agents/skills/` is the standard location Codex, pi, and opencode all discover. Claude Code
does not read it, which is why it gets a second link.

### Alternative: as a plugin, with no clone

The repo is also a one-plugin marketplace, so it can be installed by name instead. Don't do
both — Claude Code would then see the skill twice.

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
install.sh                          symlinks the skill into each harness's path
.claude-plugin/plugin.json          plugin manifest
.claude-plugin/marketplace.json     one-plugin marketplace, source "./"
skills/init-agents/
  SKILL.md                          the interview + generation procedure
  templates/AGENTS.template.md      operating-manual skeleton
  templates/MEMORY.template.md      the "why" companion skeleton
  references/memory-notes.md        shared memory-note conventions
  references/worked-example.md      one compact filled-in example
```

`SKILL.md` refers to its bundled files by plain relative path, which every harness resolves
against the directory holding `SKILL.md`. It deliberately avoids `${CLAUDE_SKILL_DIR}`, which
only Claude Code expands.

The templates are named `*.template.md` rather than `AGENTS.md` / `MEMORY.md` on purpose: a
file literally named `AGENTS.md` sitting in this tree would be picked up as instructions
when working in this directory.
