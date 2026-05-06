# Personal context for Claude Code (Matan Weisz)

## About me

- **Name / role:** Matan Weisz, DevOps Engineer I, ZoomInfo Infrastructure Engineering — **CloudInfra IL** team.
- **Location / TZ:** Israel (Asia/Jerusalem). Default to UTC in incident timelines.
- **Manager:** Arkady Landes. Sister team: CloudInfra US (joint owners of cloud network infra).
- **IDs:** Slack `U0ACK0LS5SL`. Atlassian `712020:ecaa54e4-a33f-41b9-933a-c094bcd10c30`. Primary Jira project: **IEDO**.
- **Channels I live in:**
  - `#ie-cloudinfra-il-public` — team public channel
  - `#ie-cloudinfra` — customer-facing (R&D requests land here)
  - `#ie-alerts-cloudinfra-il-low-priority` — alert noise
  - `#ie-env0-internal-support`, `#zoominfo-env0` — env0 vendor coordination
  - `#ie-mongodb-atlas-cluster-cloudinfra-il-core-alerts` — Atlas alerts

## My environment

- **Shell:** zsh on macOS, in **Ghostty** terminal. Truecolor + Nerd Font + OSC 8 supported.
- **Default tools (prefer over standard ones):** `eza` over `ls`, `bat` over `cat`, `rg` over `grep`, `fd` over `find`, `gh` for GitHub ops, `kubectx`/`kubens` for k8s context, `aws-vault` for AWS creds.
- **Editor:** preferred is whatever opens via `$EDITOR`. Don't assume vim.
- **Internal git host:** `git.zoominfo.com`. Use `gh --hostname git.zoominfo.com` if calling `gh`.

## My tech stack

- **Cloud:** GCP (primary, multi-account), AWS (heavy on `il-central-1`), Cloudflare for edge.
- **Orchestration:** GKE + Istio + Helm + ArgoCD. Multi-cluster fleet via Google Foundations.
- **Data:** MongoDB Atlas (we own `tf-atlas-mongodb-module`), Confluent Kafka, BigQuery.
- **API gateway:** Apigee X (AI Gateway: `aigateway.apigee.*.zi-int.com` etc).
- **IaC:** Terraform via **env0** (Terraform Cloud equivalent SaaS). All workspaces under GF naming.
- **Observability:** Datadog (APM, logs, RUM, monitors) — accessible via the `codex` MCP server.
- **CI:** env0 for IaC; GitHub Actions / Drone for service code.
- **Secrets:** Vault and 1Password (never paste secrets in chat or files).

## Domain vocabulary (use freely, no need to re-explain)

- **Hyperion** — RESTful cloud-infrastructure metadata API; source-of-truth for the application hierarchy. Lives in `idp-core` namespace.
- **IDP Core** — internal developer platform housing Hyperion.
- **IE Automation MCP** — exposes Hyperion + workspace + Tasker tools (the `mcp__ie-automation__*` tools in this session).
- **Tasker** — Temporal-based workflow service that executes ZObjects.
- **ZObjects** — deprecated DTOs that carry parameters for generating Terraform.
- **Managed Entities** — resource records produced by Tasker.
- **env0** — Terraform Cloud-equivalent SaaS. "Environment" == workspace. Templates: cloud-services and namespace per tier. Workflows feature is being evaluated.
- **Google Foundations / GF / gcpf** — ZoomInfo's GCP naming and provisioning conventions.
- **Application platform** = a GCP project, addressed by **pet name** (e.g. `pudgy-penguin`, `war-games`, `merry-mantis`, `promoted-goat`). 121 platforms registered in Hyperion.
- **Functional application** = bounded context; analog for GKE namespace + TF workspace per tier.
- **yazi** — GCP project prefix; "Yet Another ZoomInfo".
- **Tiers:** `dev` / `stg` / `prd` (avoid spelling out as "staging"/"production").
- **EDP / ZDP / C-Data** — Enterprise Data Platform / ZoomInfo Data Platform / Customer Data.
- **IE / R&D** — Infrastructure Engineering (internal-facing) / product engineering (customer-facing).
- **OPA** — `Terraform/opa-iac-policies` repo gates IaC.
- **Firefly** — ClickOps detection bot that posts heavily into team channels.

## Naming conventions

- Terraform workspace: `gf-<tier>-<func-app>-<cs|ns>-gcp` (where `cs`=cloud-services, `ns`=namespace).
- IaC repo: `tfc-gf-<func-app>-<cs|ns>-gcp` under `git.zoominfo.com/Terraform/`.
- Service code repo: `git.zoominfo.com/CloudDevOps/<name>`.
- GCP project: `yazi-<tier>-<pet-name>` typically.

## Mandatory protocols

- **Generating Terraform:** `terraform_list_modules` → `terraform_module_generation <name>` → write HCL → `terraform_local_validate_and_plan_instructions <dir>` → review. Never skip.
- **Creating env0 environments:** validate (`tasker_validate_env0_environment`) → show diff → wait for OK → create (`tasker_create_env0_environment`). Never skip validate.
- **AWS tagging:** dry-run (`tasker_apply_aws_tags` with `dryRun: true`) → review → apply.

## Critical never-do rules

- Never run `terraform apply` / `terraform destroy` without showing the plan first.
- Never run `kubectl apply` / `kubectl delete` against a `prd` / `prod` context without explicit OK.
- Never run `helm install` / `helm upgrade` against a prod kube-context without explicit OK.
- Never push to `main` / `master` directly. Open a PR.
- Never commit secrets. Never print secrets. Treat `~/.aws/credentials`, `*.pem`, `*.key`, `.env`, `terraform.tfstate` as untouchable.
- Never `kubectl exec` into containers as a debug strategy. Use logs / describe / ephemeral debug pods.
- Never bypass OPA findings — fix them or escalate.
- Never auto-post to Slack or auto-create Jira tickets without explicit OK (drafts are fine).
- Never target the GCP `seed`, `org`, or shared-infra projects without paired-review.

## Workflow preferences

- **Plan mode** for any change touching >2 files or any infra mutation.
- **Small PRs** preferred over big ones, even at the cost of more PRs.
- **Validate before commit** (`terraform validate`, `helm lint`, `shellcheck`, etc.).
- Prefer `git switch` / `git restore` over `git checkout`.
- Subagents:
  - `terraform-reviewer` — for plan reviews
  - `k8s-debugger` — for failing workloads
  - `incident-responder` — for incidents (drafts only)
  - `env0-tf-helper` — for env0 + TF generation
- Slash commands: `/tf-plan-review`, `/k8s-triage`, `/incident`, `/standup`, `/env0-new-env`, `/creds-rotate`.

## Output style

- Terse, code-first, no preamble.
- Reference code as `file_path:line_no` so I can jump.
- No emoji unless I ask.
- One- or two-sentence end-of-turn summaries — I read the diff myself.
- For multi-step work, show me the plan before executing; one tool call per logical step.

## Active themes (May 2026)

You can mention these casually when relevant:
- **Apigee AI Gateway** buildout with Dekel Malul (`CloudDevOps/apigee-zi`, PR #34, IEDO-96057). Vertex/Gemini proxy.
- **env0 Workflows** vendor evaluation for orchestrating Apigee envs.
- **GKE 1.35 exec-probe-timeout fleet remediation** — 165 workloads, 9 clusters, June 2026 deadline. I own the Confluence tracker.
- **Static NAT removal** on `yazi-*-war-games` PRD subnets (IEDO-94002).
- **MongoDB Atlas v7/v8 EOL upgrades** as embedded DevOps for product teams.
- Terraform drift on `tfc-gf-customer-facing-analytics-ns-gcp` and `tfc-gf-mosi-temporal-workers-ns-gcp`.

## High-signal references (link, don't load)

- Confluence "CloudInfra IL": `/wiki/spaces/IE/pages/200233190072`
- Confluence "GKE 1.35 — Exec Probe Timeouts Tracker" (mine): `/wiki/spaces/IE/pages/202764255311`
- Confluence "GKE Cluster Upgrades (Fleet)" (mine): `/wiki/spaces/IE/pages/202649239555`
- Confluence "GCP Fleet" (mine): `/wiki/spaces/IE/pages/202648453134`
- Confluence "Hyperion Database Access": `/wiki/spaces/IE/pages/201342157281`
- Confluence "IE Automation MCP Server Overview": `/wiki/spaces/IE/pages/202035691803`
- Repo: `git.zoominfo.com/CloudDevOps/apigee-zi`
- Repo: `git.zoominfo.com/Terraform/tf-atlas-mongodb-module`
- Repo: `git.zoominfo.com/Terraform/opa-iac-policies`

When in doubt about company-specific terms, processes, or systems, prefer the `atlassian:search-company-knowledge` skill (it searches Confluence + Jira) over guessing or web search.
