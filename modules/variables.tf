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
    default= "us-east-1a"
}
variable  "subnet2_cidr" {
    type = string
    default= "10.0.2.0/24"
}
variable  "s2az" {
    type = string
    default= "us-east-1b"
}
variable  "subnet3_cidr" {
    type = string
    default= "10.0.3.0/24"
}
variable  "s3az" {
    type = string
    default= "us-east-1c"
}