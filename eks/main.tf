# VPC Module
module "vpc" {
  source = "https://github.com/SeungHyeonShin/terraform.git/modules/vpc?ref=v0.0.4"

  aws_vpc_cidr        = "10.0.0.0/16"
  aws_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  aws_public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  aws_region          = local.region
  aws_azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

  global_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# Bastion Module
module "bastion" {
  source                     = "git::https://github.com/Guimove/terraform-aws-bastion.git?ref=v2.1.0"
  region                     = local.region
  vpc_id                     = module.vpc.aws_vpc_id
  bucket_name                = "eks-logging-test"
  is_lb_private              = "false"
  bastion_host_key_pair      = "changman.pem"
  bastion_iam_policy_name    = "myBastionHostPolicy"
  elb_subnets                = module.vpc.public_subnets
  auto_scaling_group_subnets = module.vpc.public_subnets

  tags = {
    "name"        = "my_bastion_name",
    "description" = "my_bastion_description"
  }
  create_dns_record = "false"
}

# EKS Module
module "eks" {
  source          = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v12.1.0"
  cluster_name    = local.cluster_name
  vpc_id          = module.vpc.aws_vpc_id
  subnets         = module.vpc.private_subnets
  cluster_version = "1.17"

  node_groups = {
    eks_nodes = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 3
      key_name         = "sin"
      instance_type    = "t3.small"
      source_security_group_ids = [
        module.bastion.bastion_host_security_group]
    }
  }
  manage_aws_auth = false
}

# Local Variable
locals {
  cluster_name = "my-eks-cluster"
  region       = "ap-northeast-2"
}
