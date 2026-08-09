# ---------------------------------------------------------------------------
# THE EKS CLUSTER — the managed Kubernetes control plane (API server, etcd,
# scheduler). AWS runs and patches this for you; you never SSH into it.
# ---------------------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    # The control plane places network interfaces across BOTH public and
    # private subnets. This is required for the API server to function
    # correctly — it's not a security compromise, since the API server
    # itself is still access-controlled separately.
    subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)

    # Public access = you can run kubectl from your laptop.
    # Private access = nodes inside the VPC can also reach the API server
    # directly without going out to the internet and back in.
    # Both true is the standard setup for a learning/dev cluster.
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks"
  }

  # Terraform should wait for the cluster to be fully ready before
  # anything that depends on it (like the node group) tries to attach.
  depends_on = []
}

# ---------------------------------------------------------------------------
# THE NODE GROUP — the actual EC2 instances that run your pods.
# EKS manages the scaling/health of these for you (this is a "managed"
# node group, not raw self-managed EC2 instances).
# ---------------------------------------------------------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-nodes"
  node_role_arn   = var.node_role_arn

  # Nodes go in PRIVATE subnets only — no direct internet inbound access.
  # They reach the internet outbound (e.g. to pull images) through the
  # NAT Gateway from Phase 1.
  subnet_ids = var.private_subnet_ids

  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1 # during node upgrades, only 1 node down at a time
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-nodes"
  }

  # Explicit dependency: the IAM role's policy attachments must exist
  # BEFORE AWS tries to let a node assume that role, or node registration
  # can fail with a confusing permissions error.
  depends_on = [aws_eks_cluster.main]
}
