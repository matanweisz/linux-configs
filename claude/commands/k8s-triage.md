---
description: Triage a failing Kubernetes resource with the k8s-debugger subagent (read-only).
argument-hint: "<resource> [namespace] [context]"
allowed-tools: Bash(kubectl get:*), Bash(kubectl describe:*), Bash(kubectl logs:*), Bash(kubectl top:*), Bash(kubectl rollout history:*), Bash(kubectl rollout status:*), Bash(helm history:*), Read, Grep, Task
---

Resource: `$1`  Namespace: `${2:-current}`  Context: `${3:-current}`

1. Confirm the active context (`kubectl config current-context`). If it looks like prod,
   flag it and stay strictly read-only.
2. Invoke the **k8s-debugger** subagent against `$1` in namespace `${2:-current}`.
3. Report: what's broken, the evidence, root cause, and the proposed fix for me to apply.
   Never apply/delete/scale/exec yourself.
