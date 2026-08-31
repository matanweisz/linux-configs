---
paths:
  - "**/*.yaml"
  - "**/*.yml"
  - "**/charts/**"
  - "**/helm/**"
  - "**/k8s/**"
  - "**/kubernetes/**"
  - "**/manifests/**"
---

# Kubernetes working rules

Applies to: Kubernetes manifests, Helm charts, and any `kubectl`/`helm` usage.

## Safety

- **Context awareness:** check `kubectl config current-context` before acting. Treat any
  context matching `prod`/`prd`/`production` as high-risk and call it out in summaries.
- **Never** `apply` / `delete` / `patch` / `scale` / `rollout` / `helm upgrade` against a
  prod context without explicit approval.
- **Don't `kubectl exec`** into containers as a debugging strategy — prefer `logs`,
  `describe`, events, and ephemeral debug pods (`kubectl debug`).
- For mutations, show the diff/dry-run (`kubectl diff` / `--dry-run=server`) first.
- Prefer GitOps (ArgoCD/Flux) over imperative changes where a repo manages the resource.

## Image tags

- Never `latest`. Always pin to an immutable tag (semver or commit sha).
- Prefer digest references (`image@sha256:...`) for prod-tier charts.

## Resource limits

Every container must have:
- `resources.requests.cpu` and `resources.requests.memory`
- `resources.limits.memory` (CPU limits are optional / debatable; defer to the existing
  convention in the repo)

Flag any container missing them.

## Probes

Every long-running workload must have:
- `livenessProbe` (exec or HTTP)
- `readinessProbe`
- `startupProbe` if the app takes >30s to start.

Respect exec-probe timeouts — recent Kubernetes releases enforce `timeoutSeconds` on exec
probes that older ones silently ignored, so long-running exec scripts that used to pass can
start failing. Use `timeoutSeconds: 5` minimum and prefer HTTP probes where possible.

## Identity & access

- Workload-specific `ServiceAccount` (no `default`).
- Bind only the minimum `Role`/`ClusterRole` required.
- On GCP: prefer Workload Identity over service-account JSON keys.

## Network policy

- Default-deny `NetworkPolicy` in prod namespaces. Explicit allow for required egress only
  (image registry, telemetry/log collectors, the specific services the workload calls).
- Where a service mesh is enforced, confirm the sidecar is actually injected
  (`kubectl get pod -o yaml`) before debugging connectivity.

## Helm

- A chart's prod values file MUST differ meaningfully from its dev one (replicas, resources,
  autoscaling). If they look identical, that's a smell.
- `helm upgrade --install` is the standard idempotent pattern.
- Before any `helm upgrade` against prod, run `helm diff upgrade ...` first and review.
- Pin chart `version:` in `Chart.yaml` dependencies — never track latest.

## Forbidden

- `hostNetwork: true`, `hostPID: true`, `privileged: true` outside explicit infra workloads
  (CNI, node-problem-detector, etc.).
- `kubectl apply -f -` from stdin in CI scripts (use checked-in manifests).
- `imagePullPolicy: Always` with a `:latest` tag (defeats the purpose).

## Naming

- Namespace == application name where possible.
- Resource names: `<app>-<component>`, lowercase-hyphenated.
- Labels: `app.kubernetes.io/name`, `app.kubernetes.io/instance`,
  `app.kubernetes.io/component`, `app.kubernetes.io/part-of` — fill them all.
