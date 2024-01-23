module "vpc" {
  source = "./modules/vpc"
  for_each = var.vpc
  vpc_cird = each.value["vpc_cidr"]
  env      = var.env
  project_name = var.project_name
}