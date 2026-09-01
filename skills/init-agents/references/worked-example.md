# Worked example

A filled-in `AGENTS.md` for a small fictional project — **Ledgerline**, a self-hosted
invoicing service. Shown after six months of use, so its traps table has rows in it; a
freshly generated file starts with that table empty.

Read this for *density and voice*, not for structure. Note how many lines say something
that is only true here, and how few say something a competent contributor already knew.

---

```markdown
# AGENTS.md — how to work in this repo

Operating manual for anyone, human or agent, making changes to Ledgerline. This file is
**what to do**; `MEMORY.md` is **why**. Read this first, then `MEMORY.md`, then the design
note for the surface you're touching under `docs/`.

## What Ledgerline is

A self-hosted invoicing service for freelancers. Python 3.12 + FastAPI + Postgres 16 behind
a React/Vite frontend, deployed by docker compose. No Celery (background work is Postgres
`LISTEN/NOTIFY` plus a single worker), no Redis, no multi-tenancy — one deployment serves
one business, and features that assume otherwise get rejected.

**The rule that settles most design arguments:** money is integer cents in a `Money` value
object, never a float and never a bare int, all the way to the template boundary.

## Hard constraints

If a change violates one of these, say so up front and propose an alternative.

1. **Invoices are immutable once issued.** Corrections are credit notes. No endpoint may
   `UPDATE` a row in `invoices` where `issued_at IS NOT NULL`.
2. **No outbound network calls during a request.** Payment-provider sync happens in the
   worker; a request that blocks on a third party times out under load.

## Repo map

`api/` (FastAPI app) · `worker/` (the NOTIFY consumer) · `web/` (Vite frontend) ·
`migrations/` (raw SQL, applied by `dbmate`) · `deploy/` (compose files) · `docs/`

**The frontend is built into the API image** — `web/dist/` is copied into `api/static/` at
image build time. A web-only change still rebuilds the `api` image, which is why the
"web only" row below is not free.

## Commands that work

There is no Makefile. `uv` manages the Python env; `pnpm` manages the frontend. Not pip,
not npm — there is no `requirements.txt` and no `package-lock.json`.

```sh
uv sync                      # once, and after any pyproject change
uv run pytest                # ~40s
uv run ruff check .          # must print nothing
uv run ruff format --check . # CI runs this; ruff format is not the same as ruff check

cd web
pnpm install --frozen-lockfile
pnpm test                    # vitest
pnpm build                   # -> web/dist/

uv run pytest tests/e2e      # BROKEN: expects a seeded DB that the fixture no longer
                             # creates. Fix it or skip it; don't debug it mid-task.
```

`pytest` needs a Postgres on :5433 — `docker compose -f deploy/dev.yml up -d db` first.
Without it you get a connection error that reads like a code bug.

## Match deploy scope to change scope

A full `deploy/push.sh` rebuilds both images and runs migrations — about four minutes, and
it drops the staging database. Use the smallest unit that delivers the fix.

| Change touches | Minimum deploy |
|---|---|
| `web/**` only | `pnpm build`, rsync `web/dist/` into the running container's `/app/static`, no restart. ~15s. |
| `api/**` Python only | rsync the package in, `docker compose restart api`. ~20s. |
| `migrations/**` or `pyproject.toml` | Full `deploy/push.sh`. Don't try to incrementalize. |
| Tests | Nothing. They run from your machine. |

### Mechanics you can't guess

- `deploy/push.sh` ships **committed HEAD only**. Uncommitted work is silently not
  deployed, and the script reports success.
- `docker compose restart` does not re-read `deploy/.env`. An env change needs
  `up -d --force-recreate`.

## Definition of done

In order. A step skipped is a step to declare out loud.

1. `uv run pytest` and `pnpm test` pass; `ruff check` and `ruff format --check` are clean.
2. **You issued an invoice through the actual UI** — logged in, created a client, issued it,
   downloaded the PDF.
3. Rebased on the latest `main`.
4. Pushed, and a PR is open. Local commits are not delivery.

On step 2: passing API tests are necessary but **not sufficient**. The PDF renderer, the
currency formatting in the browser locale, and the session refresh have each passed the test
suite and failed on first real use. If you genuinely cannot open a browser, the phrase is
"API verified, UI path untested" — never "this works".

## Commits and PRs

- One logical change per commit. Imperative subject ≤ 70 chars, scoped: `api/invoices: ...`.
- Reference the design note in the body when there is one.
- No `Co-Authored-By` trailers and no generated-with footer.

## What CI actually gates

**Blocking:** `pytest`, `ruff check`, `ruff format --check`, `pnpm build`.

**Advisory — looks red, does not block:** `mypy` runs `continue-on-error` against a large
backlog. Don't treat a red mypy as a blocker and don't re-gate it until the backlog clears.

**Doesn't exist:** nothing checks migrations. A migration that fails to apply is discovered
on deploy.

**Conditional — may silently skip:** the `e2e` job only runs on PRs labelled `ci:e2e`, and
it `exit 0`s when the staging secret is absent. A green check there may mean "didn't run".

## Traps that have already cost real time

Append a row whenever something costs more than an hour. Index by the symptom you saw, not
by the component at fault.

| Trap | What to do |
|---|---|
| Totals off by one cent on ~1 in 300 invoices | Rounding was applied per line item instead of once on the summed total. Round at the boundary only. |
| A migration "ran" but the column isn't there | `dbmate` skips a file whose timestamp is older than the last applied one. Regenerate the filename, don't hand-edit the timestamp. |
| Worker stops processing with no error in the log | `LISTEN/NOTIFY` payloads are dropped when the connection blips; the worker reconnects but does not re-poll. Restart it, then check the backlog query in `worker/README.md`. |
| PDF renders blank in staging, fine locally | The container image has no system fonts. The renderer fails silently to a blank page. |

## Environment

- There is one staging host. Its address, the deploy account, and the SSH key are in
  `.memory/staging.md`, which is untracked — this file is public.
- Credentials live in `deploy/.env` (gitignored) — reference the file, never paste secrets
  into code, docs, or commit messages.

## Which docs to trust

**Authoritative and current:** `docs/money.md`, `docs/invoice-lifecycle.md`.

**Stale — verify before trusting:** the root `README.md` still documents the pre-`uv` pip
workflow, and `docs/deploy.md` describes a Fly.io setup that was abandoned. Fix a stale line
when you pass through it.

## Keep going

Don't ask permission between tasks. Green tests and a working staging deploy mean "start the
next thing". Stop and ask only for schema changes, anything touching the invoice immutability
rule, and hard-to-reverse actions — force pushes, dropping staging data.

This does **not** dilute the UI check. The two fit together by batching: keep moving through
code and tests without checking in, then deploy once and walk the real paths for everything
in that batch together. A four-minute deploy amortised across a batch is cheap; a batch
shipped without anyone opening the app is what the rule exists to stop. The check gates the
**PR**, not every commit.
```
