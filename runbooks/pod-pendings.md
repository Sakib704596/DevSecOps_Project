# Runbook: Pod Stuck in `Pending`

## Symptoms
`kubectl get pods` shows one or more pods stuck in `Pending` status,
not progressing to `Running`.

## Diagnosis steps
1. `kubectl describe pod <pod-name> -n <namespace>` — read the
   `Events` section at the bottom. This almost always states the
   exact reason.
2. Common causes actually observed in this project:
   - `Too many pods` — the node has hit its maximum schedulable pod
     count (often IP/ENI limited on smaller instance types like
     t3.small/t3.medium, not just CPU/memory).
   - `Insufficient cpu` / `Insufficient memory` — genuine resource
     shortage across all nodes.
   - `failed to assign an IP address to container` — AWS VPC CNI has
     run out of available IPs on that node.

## Fix
- **If it's a pod-count/IP ceiling:** scale the node group
  (`terraform apply -var="node_desired_size=N"`) or switch to a larger
  instance type (see ADR 002). Verify with
  `aws eks describe-nodegroup ... --query "nodegroup.scalingConfig"`.
- **If it's a temporary, non-essential component:** consider scaling
  it to 0 temporarily (`kubectl scale deployment <name> --replicas=0`)
  to free room for higher-priority pods, as done with ArgoCD's
  notifications-controller during initial install capacity issues.
- **Always recheck after any fix:** `kubectl get pods -n <namespace>`
  until all pods show `Running`.

## Prevention
Right-size node groups relative to actual workload before installing
a new heavy component (Helm charts like kube-prometheus-stack or
ArgoCD add many pods at once). Check current node capacity headroom
first.
