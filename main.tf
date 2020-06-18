provider "aws" {
    region=var.vpc_region   
}

module "vpc_module" {
  source ="/home/ashwin/Desktop/CloudComputing6225/infrastructure/modules"
 
  s1az="${var.s1az}"
  s2az="${var.s2az}"
  s3az="${var.s3az}"
  s3_bucket_name="${var.s3_bucket_name}"
  ssh_key_name="${var.ssh_key_name}"
  username_rds_db="${var.username_rds_db}"
  password_rds_db="${var.password_rds_db}"
}