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

# Kubernetes / Helm rules

These apply when editing Kubernetes manifests or Helm charts.

## Image tags

- Never `latest`. Always pin to an immutable tag (semver or commit sha).
- Prefer digest references (`image@sha256:...`) for prod-tier charts.

## Resource limits

Every container must have:
- `resources.requests.cpu` and `resources.requests.memory`
- `resources.limits.memory` (CPU limits are optional / debatable; defer to existing convention in repo)

## Probes

Every long-running workload must have:
- `livenessProbe` (exec or HTTP)
- `readinessProbe`
- For GKE 1.35+: **respect exec probe timeouts**. The default changed; long-running exec scripts that previously worked may now fail. Use `timeoutSeconds: 5` minimum and prefer HTTP probes where possible.
- `startupProbe` if the app takes >30s to start.

## Identity & access

- Workload-specific `ServiceAccount` (no `default`).
- Bind only the minimum `Role`/`ClusterRole` required.
- For GCP: prefer Workload Identity over service-account JSON keys.

## Network policy

- Default-deny `NetworkPolicy` in prod namespaces. Explicit allow for required egress (Datadog, registry, internal services).
- Istio sidecar present where mesh is enforced — confirm with `kubectl get pod -o yaml | grep istio`.

## Helm

- Chart `values-prd.yaml` MUST differ meaningfully from `values-dev.yaml` (replicas, resources, autoscaling). If they look identical, that's a smell.
- `helm upgrade --install` is the standard idempotent pattern.
- Before any `helm upgrade` against prd, run `helm diff upgrade ...` first and review.
- Pin chart `version:` in `Chart.yaml` dependencies — never track latest.

## Forbidden

- `hostNetwork: true`, `hostPID: true`, `privileged: true` outside of explicit infra workloads (CNI, node-problem-detector, etc.).
- `kubectl apply -f -` from stdin in CI scripts (use checked-in manifests).
- `imagePullPolicy: Always` with `:latest` tag (defeats the purpose).

## Naming

- Namespace == functional-application name where possible.
- Resource names: `<app>-<component>` lowercase-hyphenated.
- Labels: `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/component`, `app.kubernetes.io/part-of` — fill them all.
