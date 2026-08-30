# Chaos Engineering Log

Deliberate failure experiments run against the live cluster, to verify
resilience claims rather than just assume them.

---

## Experiment 1: Node Drain

**Date:** 2026-08-30

**What we did:**
Cordoned and drained node `ip-10-0-101-227.ap-south-1.compute.internal`
using:
```
kubectl drain ip-10-0-101-227.ap-south-1.compute.internal \
  --ignore-daemonsets --delete-emptydir-data
```

**Hypothesis:**
Any pods running on this node would be evicted and automatically
rescheduled onto other healthy nodes, with the application remaining
available throughout (since it runs 2 replicas across different nodes).

**What actually happened:**
The node had more running on it than expected — draining it evicted
6 pods across 4 different namespaces simultaneously, not just our
application:

| Namespace | Pod evicted |
|---|---|
| devsecops-dev | dev-devsecops-app-69448cbbb9-dczfb (our app) |
| argocd | argocd-server |
| argocd | argocd-applicationset-controller |
| monitoring | monitoring-grafana |
| monitoring | monitoring-kube-prometheus-operator |
| kube-system | metrics-server |

DaemonSet-managed pods (aws-node, kube-proxy, loki-promtail,
node-exporter) were correctly left alone, since drain is aware those
are meant to run on every node by design.

**Result:**
All 6 evicted pods were rescheduled onto remaining nodes and returned
to Running/Ready without manual intervention. The application
(devsecops-dev) remained available throughout, since its second
replica was on a different, undrained node the entire time.

**Key finding:**
A single node failure in this cluster can simultaneously impact
application availability AND the observability/GitOps tooling used to
manage and monitor it (ArgoCD server, Grafana, metrics-server all
happened to be co-located on the same node). In a larger production
setup, spreading critical management tooling across dedicated nodes
or using pod anti-affinity rules would reduce this blast radius.
This is a real, observed trade-off of running a small, low-node-count
cluster for a learning/portfolio environment.

**Recovery:** Automatic, no manual pod recreation needed. Confirmed
~3-4 minutes after the drain, all 6 evicted pods were back to
Running/Ready across every affected namespace (devsecops-dev, argocd,
monitoring, kube-system) with zero manual intervention. One pod
(argocd-applicationset-controller) showed a single restart during
rescheduling but stabilized on its own — a minor, self-resolved
hiccup, not a failure. Node was uncordoned afterward to restore full
cluster capacity.

---

## Experiment 2: [Pod deletion — not run this session]
## Experiment 3: [Full infra rebuild timing — not run this session]
