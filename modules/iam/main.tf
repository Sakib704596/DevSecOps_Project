# ---------------------------------------------------------------------------
# EKS CLUSTER ROLE — lets the EKS control plane manage AWS resources
# (load balancers, network interfaces) on your behalf
# ---------------------------------------------------------------------------
resource "aws_iam_role" "cluster" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"

  # "assume_role_policy" = WHO is allowed to use this role.
  # Here: only the EKS service itself can assume it — not you, not an EC2
  # instance, not anything else. This is the "least privilege" principle
  # in action: the role exists for exactly one purpose.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-cluster-role"
  }
}

# Attach AWS's managed policy that grants exactly what the EKS control
# plane needs — we don't write this policy ourselves, AWS maintains it.
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------------------------------------------------------------------------
# EKS NODE ROLE — lets worker nodes (EC2 instances) join the cluster,
# pull container images, and let networking plugins function
# ---------------------------------------------------------------------------
resource "aws_iam_role" "node" {
  name = "${var.project_name}-${var.environment}-eks-node-role"

  # Here the trust is different: EC2 instances are what will assume
  # this role, not the EKS service itself.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-node-role"
  }
}

# Three managed policies, each doing one specific job for worker nodes:

# 1. Lets nodes register with the cluster and do basic node-level operations
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# 2. Lets the CNI plugin (pod networking) manage ENIs and IPs
resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# 3. Lets nodes pull container images from Amazon ECR
resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
