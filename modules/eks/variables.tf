variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_role_arn" {
  description = "From the IAM module — lets the EKS control plane manage AWS resources"
  type        = string
}

variable "node_role_arn" {
  description = "From the IAM module — lets worker nodes join the cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "From the VPC module — worker nodes live here, never in public subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "From the VPC module — needed so the EKS control plane ENIs can be placed here too, required for the API server to be reachable"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Pin this explicitly — never let it silently drift to 'latest'"
  type        = string
  default     = "1.34"
}

variable "node_instance_types" {
  description = "t3.medium is a reasonable balance of cost vs being able to actually run real workloads"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  type    = number
  default = 4
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}
