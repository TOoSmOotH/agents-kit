# Public memory and private memory

Two files, split by **what can be published** — not by how mature or how certain a fact is.

| | `MEMORY.md` | `.memory/` |
|---|---|---|
| Committed? | Yes | No — gitignored |
| Holds | the practice, the reason, the shape of things | the particulars that make it executable here |
| Read by | everyone who clones the repo | whoever is working on this machine |

The test is one question: **would this be fine in a public repo?** If not, it goes in
`.memory/`. Hostnames, IPs, account names, absolute paths on someone's laptop, internal URLs,
ticket numbers, a colleague's name — none of those belong in a committed file, and all of them
are exactly what an agent needs to actually do the work.

## They pair up

Write the practice in `MEMORY.md` and the particulars in `.memory/`. Neither is useful alone:
the public half without the private half can't be executed, and the private half without the
public half is a pile of trivia with no stated purpose.

`MEMORY.md`:

> Integration tests run against the lab machine, not in CI — the suite needs real hardware
> attached. See `.memory/` for how to reach it.

`.memory/test-machine.md`:

> Lab box is `10.0.4.22`, user `deploy`, key `~/.ssh/lab_ed25519`. The hardware is on USB0.
> It sleeps after 30 minutes idle; wake it with a ping before the suite starts or the first
> three tests fail with a timeout that looks like a code bug.

## Setting it up

```sh
mkdir -p .memory
```

Add `.memory/` to `.gitignore`, checking first that no existing rule already covers it.

One file per topic, named for the topic — `test-machine.md`, `staging-access.md`. When a fact
stops being true, delete the file rather than editing around it.

**Do not put the private half under `.agents/`.** Codex mounts that path read-only as
protected workspace metadata, and `mkdir` there exits 0 without creating anything, so the
failure is silent.

## `.memory/` is not a secret store

Gitignored is not encrypted. It is one `git add -f` or one shared screen away from being
public, and it is not backed up. So it holds **the details needed to find and use a secret**,
never the secret itself:

- Fine: which host, which account, which key file, which env var, which vault path.
- Not fine: passwords, private keys, tokens, connection strings with credentials in them.

If a real credential ever lands there, treat it as leaked and rotate it.
