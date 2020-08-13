provider "aws" {
    region=var.vpc_region   
}

module "vpc_module" {
  source ="/home/ashwin/Desktop/demoA6/infrastructure/modules"
 
 
}