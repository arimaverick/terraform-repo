provider "aws" {
  region = "eu-west-1"
}

module "ec2_ref" {
  source        = "../../modules/ec2"
  index         = var.index
  instance_type = "t2.large"
}

module "terraform" {
  source = "../../modules/terraform"
}


output "module_ec2_out" {
  value = module.ec2_ref.myec2_priv_ip
}

output "current_region" {
  value = module.ec2_ref.current_region
}