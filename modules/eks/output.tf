output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The Kubernetes API server URL"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Needed by kubectl/kubeconfig to trust the API server"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
