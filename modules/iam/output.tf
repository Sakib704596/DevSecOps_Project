output "cluster_role_arn" {
  description = "Needed by the EKS module to create the cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "Needed by the EKS module to create the node group"
  value       = aws_iam_role.node.arn
}
