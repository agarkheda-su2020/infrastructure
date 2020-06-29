variable  "vpc_cidr" {
    type = string
    default= "10.0.0.0/16"
    
}

variable  "subnet1_cidr" {
    type = string
    default= "10.0.1.0/24"
}
variable  "s1az" {
    type = string
   
}
variable  "subnet2_cidr" {
    type = string
    default= "10.0.2.0/24"
}
variable  "s2az" {
    type = string
    
}
variable  "subnet3_cidr" {
    type = string
    default= "10.0.3.0/24"
}
variable  "s3az" {
    type = string
  
}
//Assignment -5
variable  "internet_gateway_name" {
    type = string
    default= "Ass4_internet_gateway"
  
}



variable  "password_rds_db" {
    type = string
    default= "Northeastern4"
  
}
variable  "username_rds_db" {
    type = string
    default= "csye6225su2020"
  
}

variable  "s3_bucket_name" {
    type = string
    default= "webappashwinagarkhed"
  
}
variable  "ssh_key_name" {
    type = string
    default= "CSYE_6225_prod" // in dev it is CSYE_6225_SU2020
  
}

#Assignment 6 starts--------------------->>>>

variable  "CodeDeploy_bucket" {
    type = string
    default= "codedeploy.ashwinagarkhed.xyz"
  
}

variable  "AWS_ACCOUNT_ID" {
    type = string
    default= "381808703129"
  
}

variable  "AWS_REGION" {
    type = string
    default= "us-east-1"
  
}

variable  "CODE_DEPLOY_APPLICATION_NAME" {
    type = string
    default= "csye6225-webapp"
  
}