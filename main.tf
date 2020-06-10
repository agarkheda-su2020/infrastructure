provider "aws" {
    region="us-east-1"  
}

module "vpc_module" {
  source ="/home/ashwin/snap/expt/modules"
  vpc_cidr ="10.0.0.0/16"
  subnet1_cidr="10.0.1.0/24"
  s1az="us-east-1a"
  subnet2_cidr="10.0.2.0/24"
  s2az="us-east-1b"
  subnet3_cidr="10.0.3.0/24"
  s3az="us-east-1c"
}