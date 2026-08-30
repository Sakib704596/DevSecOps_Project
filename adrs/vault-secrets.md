# ADR 005: HashiCorp Vault for Secrets, Dev Mode, KV v2 Rotation Limitation

**Status:** Accepted
**Date:** Phase 5

## Decision
Deployed HashiCorp Vault in dev mode (in-memory storage, auto-
unsealed) rather than a production storage backend. Used the
Kubernetes auth method so pods authenticate via their own service
account identity — no stored Vault credentials anywhere. Used the KV
v2 secrets engine with the Vault Agent Injector to deliver secrets to
pods as files, with zero Vault-aware code in the application itself.

## Reasoning for dev mode
Production Vault requires a real storage backend (e.g. Consul, S3, or
integrated Raft storage) and a manual/auto-unseal process — genuine
operational complexity that would distract from learning Vault's core
secret-delivery mechanics. Dev mode isolates that complexity while
preserving the parts that matter: authentication, policy-based access
control, and automatic injection.

## Consequence discovered through testing: KV v2 rotation delay
Deliberately rotated a secret's value in Vault while a pod was
running, without restarting it. Observed that the injected secret
file did NOT update for several minutes. Root cause, confirmed via
Vault Agent sidecar logs: KV v2 secrets are "static" from Vault
Agent's perspective (no lease), so the agent falls back to polling on
a fixed interval (default ~5 minutes) rather than reacting instantly.
The file eventually updated correctly, confirming the mechanism
works, just not instantly.

**Separately observed:** even once the injected file updates, nothing
in the application code re-reads it after startup — so a real running
process would not actually pick up a rotated secret without either an
application-level file watcher or a pod restart. This is a genuine
gap between "the secret was rotated" and "the running application is
using the new value."

## Consequences
- A production setup handling frequently-rotated secrets would either
  configure a shorter `static_secret_render_interval`, use a secrets
  engine that supports leases (e.g. database dynamic credentials), or
  add a restart-on-change mechanism (e.g. Reloader) — none of which
  were necessary for this project's purpose but are documented here as
  known next steps.
- Vault authentication role was configured without an `audience`
  claim, which Vault flagged as a warning. Acceptable for this
  single-cluster learning setup; would add audience restriction for a
  production, multi-tenant, or multi-cluster Vault deployment.
