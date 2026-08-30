# ADR 001: VPC Network Design

**Status:** Accepted
**Date:** Phase 1

## Decision
Built a VPC with 2 public and 2 private subnets, spread across 2
Availability Zones (ap-south-1a, ap-south-1b), with a single NAT
Gateway and Internet Gateway.

## Context
Every resource in this project needs somewhere to live on the
network, with a clear security boundary between what's internet-
reachable and what isn't.

## Reasoning
- **2 AZs, not 1:** allows testing real multi-AZ scheduling behavior
  (EKS nodes and pods spread across failure domains) without the
  cost of a 3rd AZ, which adds marginal learning value for a solo
  project at this scale.
- **Public/private split:** load balancers and NAT live in public
  subnets; EKS worker nodes live exclusively in private subnets, so
  application pods are never directly internet-addressable.
- **Single NAT Gateway (not one per AZ):** a production system would
  typically use one NAT Gateway per AZ for high availability of
  outbound traffic. We used a single NAT Gateway to reduce cost
  (~$32-35/month each) for a learning environment, accepting that
  this NAT Gateway is a single point of failure for outbound internet
  access. This trade-off would be revisited before any real
  production use.

## Consequences
- Outbound internet access for private-subnet resources has a single
  point of failure (acceptable for this project's purpose).
- The VPC CIDR (10.0.0.0/16) with /24 subnets leaves ample room for
  future subnet additions if the project were extended.
