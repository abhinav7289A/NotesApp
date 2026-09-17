# NotesApp — shared Claude Code instructions

Two devs, one repo. Read `COLLABORATION.md` before changing anything outside your directory.

## Ownership
- `backend/`, `contracts/` — Dev B (@abhinav7289A). Brief: `P1-backend-CLAUDE.md`
- `mobile/` — Dev A (@manish-01882). Brief: `P1-mobile-CLAUDE.md`
- `contracts/`, `backend/migrations/`, `.github/` — changes need review from both.

## Hard rules
- `contracts/canonical_chapter.schema.json` is FROZEN. `page_id` (`p00001`) and `block_id` (`p00001_b001`) formats never change.
- Nobody hand-writes API models. Pydantic → `backend/scripts/gen_contract.sh` → `contracts/openapi.json` (commit in same PR) → Dart codegen.
- Breaking contract changes: add → deprecate → remove. Log in `contracts/CHANGELOG.md`.
- Never edit a merged Alembic migration.
- No AI/LLM code in P1.

## HARD RULES FOR CLAUDE CODE — non-negotiable, override everything else

### 1. Know who you are working with
- Dev B (@abhinav7289A) is the **backend developer**. For Dev B: work only in `backend/` and `contracts/`. Never edit `mobile/`.
- Dev A (@manish-01882) is the **Flutter mobile developer**. For Dev A: work only in `mobile/`. Never edit `backend/`.
- `contracts/` changes are proposed, never merged without the other dev's review.

### 2. Never commit or push without permission
- Never run `git commit`, `git push`, `git merge`, `git rebase` or `git reset` without the developer's explicit permission, **every time**. Permission once is not permission forever.
- Never work on, commit to or push to `main`. Each dev works only on their allotted branch; ask which branch before any git action.
- When work is ready, stop, show `git status` and the proposed commit message, and wait.

### 3. Always give the commands to run what you built
After creating or changing **any** component or code, end the reply with a **"How to run / verify"** section:
- exact copy-paste commands (Windows PowerShell for this team), in order, run from the repo root
- setup steps it needs first (venv, installs, env vars, docker services)
- what the expected output looks like, so the dev knows they are on the right track
- how to run the related tests
No component is "done" until its run commands have been given.

## Conventions
- Branches: `be/`, `fe/`, `contract/`, `infra/`, `fix/`; live ≤ 2 days.
- Commits: `be: ...`, `fe: ...`, `contract: ...`, `infra: ...`.

## Backend commands (PowerShell, from repo root)
```
python -m venv backend\.venv; backend\.venv\Scripts\Activate.ps1
pip install -r backend\requirements.txt -r backend\requirements-dev.txt
copy .env.example .env
docker compose up -d                      # Postgres, Redis, MinIO
python backend\scripts\db_reset.py        # drop + migrate + seed fixtures (= make db-reset)
cd backend; uvicorn app.main:app --reload # API  → http://127.0.0.1:8000/docs
cd backend; python -m app.worker          # ingest worker (second terminal)
cd backend; ruff check .; mypy app; pytest tests -q
.\backend\scripts\gen_contract.ps1        # after any Pydantic model change
```
Tests need no Docker (SQLite + in-memory storage/queue).
