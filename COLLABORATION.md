# Collaboration guide

Two people, one repo. Dev A writes Flutter. Dev B writes Python.

The thing that will hurt this project is not merge conflicts — we touch different files. It is **contract drift**: the backend returns something the client does not expect, and we find out on integration day. Everything here exists to prevent that.

---

## 1. Roles

| | Dev A | Dev B |
|---|---|---|
| Owns | `mobile/` | `backend/`, `contracts/` |
| Stack | Flutter, Dart, pdfrx, Riverpod | FastAPI, Celery/ARQ, Postgres, Redis |
| Also owns | Store listings, device testing | Migrations, infra, API keys, spend caps |

Dev B is the contract owner. That means Dev B writes the Pydantic models and regenerates `openapi.json`, but **Dev B does not get to change it unilaterally** — see section 6.

---

## 2. Repo layout

```
studyapp/
├── contracts/
│   ├── canonical_chapter.schema.json   ← frozen in P0
│   ├── openapi.json                    ← generated, committed
│   ├── fixtures/                       ← real sample responses
│   └── CHANGELOG.md
├── backend/
│   ├── app/
│   ├── migrations/
│   └── scripts/gen_contract.sh
├── mobile/
├── .github/workflows/
├── .env.example
├── CLAUDE.md
└── COLLABORATION.md   ← this file
```

One repo, not two. A single PR can change the API and the client together, so the contract can never be half-updated.

---

## 3. Nobody hand-writes API models

This is the most important rule in this document.

Pydantic models are the source of truth. FastAPI generates `openapi.json`. Dev A generates the Dart client from that file.

```bash
# Dev B, after any model change
./backend/scripts/gen_contract.sh     # writes contracts/openapi.json

# Dev A, after pulling
cd mobile && dart run build_runner build --delete-conflicting-outputs
```

If a field renames, Dev A's build breaks immediately with a clear error — not at 11pm in week 9 with a null crash.

**CI enforces this.** A job regenerates `openapi.json` and fails if it differs from what is committed. Twenty lines of YAML; prevents the single most expensive class of bug on a two-person team. Set it up in week 1.

---

## 4. Dev A never waits on Dev B

The worst version of this project is Dev A idle for three days because an endpoint is not ready.

**Mock server**, from the same contract:

```bash
npx @stoplight/prism mock contracts/openapi.json --port 4010
```

Dev A points the app at `localhost:4010` and gets realistic responses for endpoints that do not exist yet.

**Fixtures beat mocks.** Commit real sample responses in `contracts/fixtures/` — an actual canonical chapter, an actual AI answer with source refs, an actual quiz. Dev A builds UI against real shapes from day one, and Dev B gets regression fixtures for free.

Add `examples` to every Pydantic model so generated mocks contain sensible data instead of `"string"`.

---

## 5. Branching

Trunk-based. `main` is always deployable. No `develop` branch, no gitflow.

```
main
 ├── be/ask-endpoint          (Dev B)
 ├── fe/selection-handles     (Dev A)
 └── contract/add-source-refs (either — needs review)
```

**Branch lifetime: two days maximum.** If a branch lives a week, we are building in the dark and the merge will hurt. Break it smaller, or merge behind a feature flag before it is finished.

Prefixes: `be/`, `fe/`, `contract/`, `infra/`, `fix/`.

---

## 6. Reviews, asymmetric on purpose

Dev B cannot meaningfully review Dart layout code. Dev A cannot review Celery config. So we do not pretend.

| Touches | Review |
|---|---|
| `mobile/` only | Self-merge if CI green |
| `backend/` only | Self-merge if CI green |
| `contracts/` | **Mandatory review by the other person** |
| `migrations/` | **Mandatory, with a plain-English explanation in the PR body** |

This keeps velocity high while putting review exactly where it prevents bugs.

---

## 7. Breaking changes

Additive is free. Removal and rename are not.

**Protocol: add new → deprecate old → remove after both sides ship.**

```
week 1  add `source_refs`, keep `source_ref`, mark deprecated
week 2  Dev A migrates the client
week 3  Dev B deletes `source_ref`
```

Never rename a field in a single PR.

Log every contract change in `contracts/CHANGELOG.md`. Three lines, not a document:

```
2026-03-14  added source_refs (list). source_ref deprecated, removed after 2026-03-28. — Dev A to migrate.
```

---

## 8. Migrations

- Alembic. Commit every migration. **Never edit a migration that has been merged.**
- Additive-then-cleanup, same as contracts. Adding a nullable column is safe. Dropping one while an old client is live is an outage.
- Ship `make db-reset` (drop, migrate, seed fixtures) so Dev A can fix his own local data problems without blocking on Dev B.

---

## 9. CI — the useful minimum

```yaml
backend:  ruff → mypy → pytest → contract-drift-check
mobile:   dart analyze → flutter test → flutter build apk --debug
integration: boot backend in docker → smoke test 5 real endpoints
```

Under three minutes total. The integration job is the one that catches what we actually care about.

**Do not add yet:** coverage gates, complexity linters, semantic-release, a release pipeline. They cost time and catch nothing at this scale.

---

## 10. Rhythm

**Daily standup, 15 minutes, same time.** Three questions:
1. What shipped yesterday?
2. What is blocked?
3. **Does anything in `contracts/` change today?**

Question 3 is the reason the meeting exists.

**Friday integration hour.** Both pull `main`. Dev A points the app at the real staging backend — not the mock. Walk the full loop together on a real phone. Every Friday, no exceptions.

A bug found on Friday costs an hour. The same bug found in week 11 costs a day.

**End of each phase:** demo the gate criteria to each other before starting the next phase. If the gate is not met, do not move on. Finishing it later always costs more.

---

## 11. Environments

| | Backend | Database | Payments |
|---|---|---|---|
| local | docker-compose or prism mock | local Postgres | — |
| staging | auto-deploy from `main` | separate Supabase project | Razorpay test keys |
| prod | manual promote | separate Supabase project | Razorpay live keys |

**Never share one Supabase project between dev and prod.** A destructive migration against real user data is not recoverable. Separate projects from day one, while it costs nothing.

---

## 12. Secrets and spend

- `.env.example` is committed, with every key name and a dummy value.
- Real secrets live in a shared 1Password or Bitwarden vault. Never in the repo. Never in Slack. Rotate anything that lands in either.
- **Each dev gets a separate model API key with a hard daily spend cap.** We will each run the pipeline hundreds of times debugging prompts. A runaway loop on a shared production key is how a week of budget disappears overnight.
- A global kill switch lives in the router. Know where it is before you need it.

---

## 13. Conventions

**Commits:** `be: add ask endpoint`, `fe: selection action bar`, `contract: add source_refs`. Prefix, colon, plain description. No ceremony beyond that.

**Issues:** one board, three columns — todo, doing, done. Label by phase (`P2`, `P4`). Nothing else.

**Blocked?** Say so in standup the same day. A blocker held quietly for two days is the most expensive thing on a two-person team.

**Disagreement:** if it is reversible, whoever owns that directory decides and we move on. If it is not reversible — schema, contract, framework, pricing — both must agree before anyone writes code.

---

## 14. What we deliberately skip

Story points. Sprint ceremonies. A five-column board. Nx or Turborepo. Semantic-release. A design-system package. Microservices. Code coverage targets.

Two people in a shared repo with a frozen contract and a Friday integration hour will outrun any of it.

---

## 15. If you do only one thing

Make the contract-drift check a required CI job in **week 1**.

It is twenty lines of YAML and it prevents the specific class of bug that costs two-person teams the most days.
