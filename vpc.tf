provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  azs = ["ap-northeast-2a", "ap-northeast-2c"]
  name = "testing"

  tags = {
    "TerraformManaged" = "true"
  }
}
