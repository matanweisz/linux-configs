# Terraform working rules

Applies to: `**/*.tf`, `**/*.tfvars`, `**/*.hcl`

- **Plan before apply, always.** Show the plan, list add/change/destroy counts, and wait
  for explicit approval (a clear "yes/apply", not just "ok"/"proceed") before `terraform apply`.
- **Never** `terraform destroy` without an explicit, scoped request and a shown plan.
- Stateful resources (databases, buckets, KMS keys, clusters, disks) should carry
  `lifecycle { prevent_destroy = true }`. Flag any change that removes it or replaces them.
- **No** hardcoded secrets, `0.0.0.0/0` ingress, `roles/owner`, or `*FullAccess`.
- Pin module and provider versions. Prefer `terraform validate` + `terraform fmt` before commit.
- Tag/label resources consistently (owner, environment, cost-center) where the provider supports it.
- Keep state out of git; never read or print `*.tfstate`.
