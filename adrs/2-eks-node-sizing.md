# ADR 002: EKS Node Group Sizing and Instance Type

**Status:** Accepted (revised once during the project)
**Date:** Phase 1, revisited Phase 4

## Decision
Run a managed EKS node group with 2-4 nodes, ultimately settling on
`t3.medium` as the instance type after directly comparing it against
`t3.small`.

## Context
Kubernetes' EKS-managed node groups have a real, often-overlooked
ceiling: the number of pods schedulable per node is limited by the
number of available IP addresses per network interface (via the AWS
VPC CNI plugin), not just raw CPU/memory. This became a real,
recurring bottleneck when installing heavier workloads (ArgoCD, then
later the kube-prometheus-stack).

## What we tried, in order
1. Started with 2x `t3.medium` — sufficient for the app alone.
2. Hit a genuine "Too many pods" scheduling failure when installing
   ArgoCD (7-8 additional pods).
3. Scaled to 3 nodes — insufficient; still hit the same ceiling.
4. Switched to 4x `t3.small` — more nodes, but each with a *lower*
   per-node pod/IP ceiling, which then surfaced a *different* failure
   mode: AWS CNI IP exhaustion (`failed to assign an IP address to
   container`), confirmed directly in pod scheduling events.
5. Settled back on `t3.medium` with node count sized to the actual
   workload (2-4 depending on what's installed at the time).

## Reasoning
`t3.medium` provides a meaningfully higher pod/IP ceiling per node
than `t3.small`, and fewer, larger nodes reduce the overhead of
per-node system pods (kube-proxy, CNI, node-exporter, Promtail all
run once per node regardless of node size) compared to more, smaller
nodes.

## Consequences
- This is a genuine, hands-on-verified finding: **instance type
  selection for Kubernetes must account for pod/IP density, not just
  CPU and memory**, especially for smaller instance types.
- A production cluster would likely use Cluster Autoscaler or Karpenter
  to right-size nodes dynamically rather than manually toggling
  desired/max size, which is what this project did throughout.
