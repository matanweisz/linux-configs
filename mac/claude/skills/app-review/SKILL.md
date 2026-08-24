---
name: app-review
description: "Use when the user wants their app/project critically tested and reviewed for feedback and improvement ideas (e.g. /app-review, 'test my app', 'get persona feedback', 'review the app like a first-time user') — runs 5 persona agents (UI/UX designer, senior dev, 3 first-time users) against the running app via Playwright and/or the codebase, then synthesizes a severity-ranked findings report and a phased improvement roadmap."
---

# /app-review

Multi-persona critical review of the current project. Five agents — a UI/UX expert, a senior developer, and three first-time-user personas (24F HR coordinator, 49M logistics manager, 17M high-schooler) — each test the app in character, log every issue with evidence, and the results are synthesized into a findings report plus a phased improvement roadmap. The roadmap is the deliverable: **never auto-implement fixes** as part of this skill.

## Usage

```
/app-review                          # auto-detect running app, else code-only review
/app-review http://localhost:5173    # review this running app
/app-review <url> onboarding         # optional second arg: focus area for all personas
/app-review code-only                # skip browser testing even if an app is running
```

## Step 0 — Detect context and mode

1. Identify the stack: read `package.json` (or `pyproject.toml`, `go.mod`, …), note framework + key dependencies + dev/build/test scripts. Skim the README and top-level structure. Do NOT deep-read the codebase yourself — that's the agents' job.
2. Find a running app URL:
   - Explicit URL arg → verify with `curl -s -o /dev/null -w '%{http_code}' <url>`.
   - Else probe common dev ports: `for p in 3000 5173 8080 4200 8000 4321; do curl -s -o /dev/null -m 2 -w "$p:%{http_code}\n" http://localhost:$p; done` and take the first non-000.
   - Else, if a dev script exists, ask the user: start it (`run_in_background`, then re-probe) or proceed code-only.
3. Record the mode: **hybrid** (URL found — browser personas + code review) or **code-only**. Tell the user which mode is active and why before launching agents.

## Step 1 — Run the review agents

Persona definitions live in `references/personas.md` (read it now). Each agent prompt = the persona block + the shared instructions block from that file + this context header:

```
App under review: <name, one-line description from README>
Stack: <framework/deps summary from Step 0>
Repo path: <abs path>   App URL: <url or "none — code-only review">
Focus area (if given): <arg 2>
```

**Concurrency rule: Playwright MCP is ONE shared browser. Browser-using agents must run strictly one at a time. Never launch two browser personas concurrently.**

### Hybrid mode

- Launch **Alex (senior dev)** immediately as a background `general-purpose` agent — he works from the code plus his own `curl`/CLI probing of the URL, and must NOT use Playwright/browser MCP tools (reserve the browser for the personas).
- Then run the browser personas **sequentially, foreground (`run_in_background: false`), in this order**: Maya (UI/UX) → Dana (24F) → Oren (49M) → Tom (17M). Each uses the Playwright MCP tools (`browser_navigate`, `browser_snapshot`, `browser_click`, `browser_resize`, …; prefer snapshots over screenshots).
- **Between personas, reset the browser for a true first visit.** Instruct each persona to START its session by navigating to the app and clearing state:
  `browser_run_code_unsafe` → `localStorage.clear(); sessionStorage.clear();` then clear cookies (`document.cookie` loop or re-navigate), then a fresh `browser_navigate` to the URL. The persistent profile carries auth across runs — without this reset, later personas are not first-time users.
- Collect Alex's background result after the persona chain finishes.

### Code-only mode

Launch all 5 agents **in parallel** (single message, multiple Agent calls). Each reviews the codebase from its persona's viewpoint: Maya reads templates/components/styles for UX and accessibility issues; Alex does the full technical pass; the three user personas trace the actual entry → onboarding → core-task flow through the code/copy and report where a real user would be confused, judging the strings and screens they'd actually see.

### If an agent fails or returns nothing

Note it in the report ("persona X could not complete: <reason>") — do not silently drop a persona, and do not retry more than once.

## Step 2 — Synthesize

1. **Dedupe** findings across agents (same root issue reported twice = one finding, credited to all reporters).
2. **Cross-validate:** an issue independently hit by 2+ personas moves up one severity notch (max P0). Keep each persona's best verbatim quote as evidence.
3. **Score** each finding: severity (P0–P3) × effort (S/M/L, your engineering estimate from the code).
4. **Research best practices for the top findings** (P0/P1 and recurring P2 themes only — not every nitpick):
   - `context7` (`resolve-library-id` → `query-docs`) for the project's actual framework — current idioms for the specific problems found.
   - `WebSearch` only for time-sensitive topics (current security advisories, evolving UX conventions).
   - Anchor without searching where the canon is stable: UX → Nielsen heuristics + WCAG 2.2 AA; performance → Core Web Vitals; security → OWASP Top 10.

## Step 3 — Deliver

Write two files into the project (create `reviews/` if missing; use today's real date):

**`reviews/app-review-<YYYY-MM-DD>.md`** — the evidence:
- Header: date, mode (hybrid/code-only), app URL, commit (`git rev-parse --short HEAD` if a repo).
- Summary table: all findings — ID, severity, effort, title, which personas hit it.
- Full deduped findings (evidence, impact, suggestion, best-practice reference where researched).
- Per-persona verdicts and "what worked well" (keep their voice — verbatim highlights).

**`reviews/roadmap-<YYYY-MM-DD>.md`** — the plan:
- **Phase 1 — Critical fixes:** all P0s + security/data-loss P1s.
- **Phase 2 — UX & onboarding:** remaining P1s + cross-validated P2 themes.
- **Phase 3 — Polish & delight:** P2/P3 worth doing.
- Each item: what to change, why (finding IDs), best-practice reference, effort. Order phases so each ends in a shippable state.

Finish with a short chat summary: mode, agent count, top 5 findings (one line each), and pointers to both files. Do not start implementing — suggest the user open a fresh session (or say "go") to execute Phase 1.

## What this skill never does

- Implement fixes, commit, or modify project files other than the two `reviews/*.md` outputs.
- Destructive in-app actions: deletes of pre-existing data, purchases, real emails/messages, real credentials (agents use fake test data).
- Run browser personas in parallel, or skip the browser state reset between personas.
