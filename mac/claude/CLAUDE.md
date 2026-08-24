# Personal context for Claude Code (Matan Weisz)

## About me

- **Role:** DevOps / Cloud Infrastructure engineer.
- **Location / TZ:** Israel (Asia/Jerusalem). Use UTC in incident/timeline output.
- This is my **personal macOS laptop** (not a work machine). Keep things generic — no
  employer-internal systems, hostnames, or credentials belong here.

## My environment

- **OS:** macOS. **Shell:** zsh in **Ghostty** (truecolor + Nerd Font).
- **Home:** `/Users/matan.weisz`. Window tiling via **Raycast**; `borders` draws the
  active-window outline.
- **Default tools (prefer over the classics):** `eza`>`ls`, `bat`>`cat`, `rg`>`grep`,
  `fd`>`find`, `gh` for GitHub, `kubectx`/`kubens` for k8s context, `lazygit`/`lazydocker`
  for TUIs. Editor is `$EDITOR` (nvim).
- Everything — CLI and GUI — installs from Homebrew via `mac/Brewfile` (`brew bundle`).

## My stack (generic)

- **Cloud:** GCP and AWS. **Orchestration:** Kubernetes (GKE/EKS) + Helm + ArgoCD.
- **IaC:** Terraform (+ Terragrunt). **Containers:** Docker.
- **Observability/secrets:** treat all credentials as untouchable; never print or commit them.

## Critical never-do rules

- Never run `terraform apply` / `terraform destroy` without showing the plan first.
- Never run `kubectl apply` / `kubectl delete` against a prod context without explicit OK.
- Never run `helm install` / `helm upgrade` against a prod kube-context without explicit OK.
- Never push to `main` / `master` directly — open a PR.
- Never commit or print secrets. `~/.aws/credentials`, `*.pem`, `*.key`, `.env`,
  `*.tfstate` are blocked at the Read layer — do not try to bypass.
- Prefer logs / describe / ephemeral debug pods over `kubectl exec` for debugging.

## Workflow preferences

- **Plan mode** for any change touching >2 files or any infra mutation.
- Small PRs over big ones. Validate before commit (`terraform validate`, `helm lint`,
  `shellcheck`, etc.). Prefer `git switch` / `git restore` over `git checkout`.
- Subagents: `terraform-reviewer` (plan reviews), `k8s-debugger` (failing workloads).
- Slash commands: `/tf-plan-review`, `/k8s-triage`, `/standup`.

## Output style

- Terse, code-first, no preamble. Reference code as `file_path:line_no` so I can jump.
- No emoji unless I ask. One- or two-sentence end-of-turn summaries — I read the diff myself.
- For multi-step work, show the plan before executing; one tool call per logical step.
