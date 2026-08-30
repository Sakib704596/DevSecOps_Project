# Runbook: ArgoCD Application Shows `OutOfSync` or `Missing`

## Symptoms
`kubectl get application <name> -n argocd` shows `SYNC STATUS` other
than `Synced`, or `HEALTH STATUS` other than `Healthy`.

## Diagnosis steps
1. `kubectl describe application <name> -n argocd` — check the
   `Status` and `Events` sections for the specific operation result
   and any error message.
2. Confirm the Application's `source.path` actually points to a valid
   Kustomize/manifest path in the target Git branch — a typo here
   produces a silent `OutOfSync`/`Missing` state with no other error.
3. If `HEALTH STATUS` is `Degraded` but resources appear `Running`:
   check whether a resource ArgoCD monitors (e.g. an HPA) lacks a
   dependency to report status correctly. Observed real case: HPA
   showed `Degraded` health because `metrics-server` was not
   installed, so the HPA could not read CPU utilization at all.
   Installing `metrics-server` resolved this without any change to
   the Application itself.

## Fix
- Trigger a manual sync via the UI ("Sync" button) or
  `argocd app sync <name>` (if the CLI is installed) to force
  re-evaluation immediately rather than waiting for the default
  reconciliation interval.
- If newly created and stuck `Missing`: this is normal for the first
  few seconds after `kubectl apply -f <app>.yaml` — resources created
  manually (outside ArgoCD) before the Application existed are not
  automatically recognized as matching; a manual Sync resolves this.

## Related note
If `automated.selfHeal: true` is enabled, expect any manual
`kubectl` change to this Application's managed resources to be
reverted automatically, usually within seconds. This is correct,
intended behavior — see ADR 004.
