module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
}

module "eks" {
  source             = "./modules/eks"
  project_name       = var.project_name
  environment        = var.environment
  cluster_subnet_ids = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids    = module.vpc.private_subnet_ids
  kubernetes_version = "1.31"
  node_instance_type = "t3.small"
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
}

module "ec2" {
  source                 = "./modules/ec2"
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.public_subnet_ids[0]
  instance_type          = "t3.small"
  jenkins_ssh_public_key = var.jenkins_ssh_public_key
}
