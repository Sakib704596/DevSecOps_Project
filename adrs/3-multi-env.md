# ADR 003: Multi-Environment Strategy via Kustomize, Limited to Dev Deployment

**Status:** Accepted
**Date:** Phase 3

## Decision
Defined dev, staging, and prod environments as Kustomize overlays on
a shared base (Deployment, Service, ConfigMap, HPA). Only the `dev`
overlay is actually deployed to the live cluster; staging and prod
are verified correct via `kubectl kustomize` rendering but
intentionally not applied.

## Context
The overlays differ in real, meaningful ways — not just cosmetic
renaming:
- dev: 2 replicas, base resource limits (250m CPU / 256Mi memory)
- staging: 3 replicas
- prod: 4 replicas, higher resource limits (500m CPU / 512Mi memory),
  higher HPA ceiling (10 vs base 5)

## Reasoning
Running dev + staging + prod simultaneously would require 9 pods
minimum, which exceeds the practical and cost-reasonable capacity of
this project's small (2-4 node, t3.medium) cluster — confirmed
directly by hitting real scheduling ceilings in ADR 002. Rather than
force-fit all three onto undersized infrastructure (or pay for a much
larger cluster purely to run idle staging/prod environments with no
real traffic), we chose to prove the *mechanism* is correct — the
overlays produce exactly the intended, differentiated output — without
running environments that serve no real purpose in a solo learning
project.

## Consequences
- Staging and prod Kustomize output has been verified correct
  (replica counts, resource limits, HPA ceilings all confirmed via
  rendered YAML) but never validated by actually running pods.
- A production version of this platform would run each environment on
  separate, appropriately-sized node groups or clusters, or use
  Kubernetes ResourceQuotas per namespace to safely share one cluster.
- This is a deliberate, documented scope decision — not an oversight.
