---
description: Triage a failing Kubernetes pod / deployment / StatefulSet — gathers events, logs, describe, probes, and rollout history. Read-only.
argument-hint: "<pod-or-deployment> [namespace] [context]"
allowed-tools: Read, Bash(kubectl get:*), Bash(kubectl describe:*), Bash(kubectl logs:*), Bash(kubectl top:*), Bash(kubectl rollout history:*), Bash(kubectl explain:*), Bash(kubectl config:*), Bash(helm history:*), Bash(helm get:*), Bash(helm status:*), Bash(jq:*), Glob, Grep
---

Triage a failing Kubernetes workload via the `k8s-debugger` subagent.

## Parsing arguments

- `$1` = resource (required) — pod or `deployment/<name>` or `statefulset/<name>`
- `$2` = namespace (optional, default `kubectl config view --minify -o jsonpath='{..namespace}'`)
- `$3` = kube context (optional, default `kubectl config current-context`)

If `$1` is missing, ask for it.

## Steps

1. **Confirm scope** — print the resolved `<resource> in <ns>@<ctx>` and ask the user to confirm if `$ctx` matches `prod|prd` (don't proceed without ack).

2. **Hand off to `k8s-debugger`** with the parsed args.

3. **Print the subagent's hypothesis + suggested commands**.

## What this command never does

- It never runs `kubectl delete`, `apply`, `patch`, `scale`, `rollout restart`, `helm upgrade`, `helm rollback`. Those are *suggestions only* — the user runs them.
- It never `kubectl exec`s into containers.
