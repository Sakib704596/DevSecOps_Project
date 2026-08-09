output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_gateway_ip" {
  value = module.vpc.nat_gateway_ip
}
output "cluster_role_arn" {
  value = module.iam.cluster_role_arn
}

output "node_role_arn" {
  value = module.iam.node_role_arn
}
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}