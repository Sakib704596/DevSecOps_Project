# ADR 004: GitOps via ArgoCD App-of-Apps, Automated Sync Limited to Dev

**Status:** Accepted
**Date:** Phase 4

## Decision
Used ArgoCD's app-of-apps pattern: one root Application
(`devsecops-platform-root`) watches a Git folder containing three
child Application definitions (dev, staging, prod). Only the dev
Application has `automated: { prune: true, selfHeal: true }` enabled;
staging and prod exist and are tracked by ArgoCD but require manual
sync.

## Reasoning
This is consistent with ADR 003 — since staging/prod are not meant to
run live given cluster capacity, enabling automated sync on their
Applications would either fail immediately (attempting to schedule
pods with no room) or silently succeed and then compete for the same
constrained resources as dev. Manual-sync-only Applications let us
demonstrate the full app-of-apps mechanism (one root managing three
children, each independently trackable) without contradicting the
capacity decision made in Phase 3.

## Proof of correctness
Self-heal was verified live: manually scaling the dev Deployment from
2 to 5 replicas via `kubectl` (bypassing Git) was detected and
reverted back to 2 within seconds — new pods were terminated mid-
startup before even reaching Ready. This confirms Git, not the live
cluster state, is the actual source of truth enforced by ArgoCD.

## Consequences
- A Git commit to `argocd/apps/dev-app.yaml` alone triggers a cluster
  change — no `kubectl apply` needed for day-to-day dev changes.
- Staging/prod require a manual "Sync" click in the ArgoCD UI (or CLI)
  when their turn comes to actually run, which is the correct,
  deliberate behavior given the capacity constraint.
