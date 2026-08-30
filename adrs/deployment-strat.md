# ADR 006: Rolling Update as Default, Blue-Green as a Demonstrated Pattern

**Status:** Accepted
**Date:** Phase 6

## Decision
Configured the main application Deployment with explicit
`maxUnavailable: 0, maxSurge: 1` rolling update settings. Separately
built and demonstrated a Blue-Green deployment pattern (two parallel
Deployments + a Service selector switch) as a standalone exercise, not
integrated into the ongoing ArgoCD-managed application.

## Reasoning
Rolling updates are the right default for this project's actual
release pattern (frequent, low-risk changes to a single environment)
— they need no extra resources beyond a brief surge capacity, and
Kubernetes manages the entire process natively via the Deployment
controller. Blue-Green is valuable to understand and demonstrate
(instant cutover and rollback, at the cost of running double the
resources during a release window) but was not adopted as the
project's primary strategy, since it doesn't meaningfully benefit a
single-developer project without a real pre-production validation
step to justify running two full environments simultaneously.

## Proof of correctness
- **Rolling update:** ran a continuous health-check loop (~5
  requests/sec) against the Service throughout a live pod rollout
  (`kubectl rollout restart`). Zero failed requests were observed
  during the entire pod replacement window, directly confirming
  `maxUnavailable: 0` prevents any capacity drop.
- **Blue-Green:** deployed both `blue` and `green` versions
  simultaneously, confirmed via `kubectl get endpoints` that the
  Service routed to blue's pod IP, patched the selector to `green` and
  confirmed the endpoint IP changed instantly, then reverted and
  confirmed an equally instant rollback to blue's original IP.

## Consequences
Both patterns are proven with real evidence, not just configured and
assumed — this is genuine, demonstrated understanding of the
trade-off between "safe, gradual, single-environment" (rolling) and
"safe, instant-cutover, double-resource" (Blue-Green) deployment
strategies.
