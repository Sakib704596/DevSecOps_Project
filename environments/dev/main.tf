module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = "dev"
  vpc_cidr     = "10.0.0.0/16"

  azs                   = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
}
module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = "dev"
}
module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = "dev"

  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  depends_on = [module.vpc, module.iam]
}