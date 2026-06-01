# Kubernetes working rules

Applies to: Kubernetes manifests, Helm charts, and any `kubectl`/`helm` usage.

- **Context awareness:** check `kubectl config current-context` before acting. Treat any
  context matching `prod`/`prd`/`production` as high-risk and color it red in summaries.
- **Never** `apply` / `delete` / `patch` / `scale` / `rollout` / `helm upgrade` against a
  prod context without explicit approval.
- **Don't `kubectl exec`** into containers as a debugging strategy — prefer `logs`,
  `describe`, events, and ephemeral debug pods (`kubectl debug`).
- Respect resource requests/limits and probe timeouts; flag missing ones.
- For mutations, show the diff/dry-run (`kubectl diff` / `--dry-run=server`) first.
- Prefer GitOps (ArgoCD/Flux) over imperative changes where a repo manages the resource.
