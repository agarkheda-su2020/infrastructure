resource "aws_vpc" "Ass4_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "Ass4_vpc"
  }
}


resource "aws_subnet" "subnet1" {
    cidr_block              = var.subnet1_cidr
    vpc_id                  =aws_vpc.Ass4_vpc.id
    availability_zone       = var.s1az
    map_public_ip_on_launch = true

    tags={
        Name="Ass4_subnet1"
    }
}

resource "aws_subnet" "subnet2" {
    cidr_block              = var.subnet2_cidr
    vpc_id                  =aws_vpc.Ass4_vpc.id
    availability_zone       = var.s2az
    map_public_ip_on_launch = true

    tags={
        Name="Ass4_subnet2"
    }
}

resource "aws_subnet" "subnet3" {
    cidr_block              = var.subnet3_cidr
    vpc_id                  =aws_vpc.Ass4_vpc.id
    availability_zone       = var.s3az
    map_public_ip_on_launch = true

    tags={
        Name="Ass4_subnet3"
    }
}



resource "aws_internet_gateway" "Ass4_internet_gateway" {
  vpc_id = aws_vpc.Ass4_vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_route_table" "Ass4_route_table" {
  vpc_id = aws_vpc.Ass4_vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Ass4_internet_gateway.id
  }

  tags = {
    Name = "Ass4_route_table"
  }
}

resource "aws_route_table_association" "routeTosubnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.Ass4_route_table.id
}

resource "aws_route_table_association" "routeTosubnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.Ass4_route_table.id
}

resource "aws_route_table_association" "routeTosubnet3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.Ass4_route_table.id
}

resource "aws_security_group" "application" {
  name        = "application"
  description = "This is the security group for EC2 instances that will host web application."
  vpc_id      = "${aws_vpc.Ass4_vpc.id}"

  ingress {
    description = "TCP from HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP from SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP from HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP for application"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group Application"
  }
}

resource "aws_security_group" "database" {
  name        = "database"
  description = "This is the security group for RDS instances that will host web application."
  vpc_id      = "${aws_vpc.Ass4_vpc.id}"

  ingress {
    description = "TCP from HTTPS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.application.id}"]
  }

  tags = {
    Name = "Security Group Database"
  }
}


resource "aws_s3_bucket" "webappashwinagarkhed" {
  bucket = var.s3_bucket_name
 

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

  

    expiration {
      days = 90
    }
  }

  lifecycle_rule {
    id      = "tmp"
    prefix  = "tmp/"
    enabled = true

  }
}

resource "aws_s3_bucket_object" "bucket_object" {
  key                    = "someobject"
  bucket                 = "${aws_s3_bucket.webappashwinagarkhed.id}"
  server_side_encryption = "AES256"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = ["${aws_subnet.subnet3.id}", "${aws_subnet.subnet2.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "csye6225" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  multi_az             = "false"
  instance_class       = "db.t3.micro"
  name                 = "csye6225"
  parameter_group_name = "default.mysql5.7"
  username             = var.username_rds_db
  password             = var.password_rds_db
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.name}"
  skip_final_snapshot =  "true"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["418350900893"] # Canonical
}

resource "aws_instance" "ec2" {
  ami                     = "${data.aws_ami.ubuntu.id}"
  instance_type           = "t2.micro"
  subnet_id               = "${aws_subnet.subnet3.id}"
  depends_on              = [aws_db_instance.csye6225]
  vpc_security_group_ids  = ["${aws_security_group.application.id}"]
  iam_instance_profile    = "${aws_iam_instance_profile.ec2_profile.name}"

  user_data = <<-EOF
          #!/bin/bash
          echo "export SPRING_DATASOURCE_URL=${aws_db_instance.csye6225.address}">>/home/ubuntu/.bashrc
          echo "export SPRING_DATASOURCE_USERNAME=${var.username_rds_db}">>/home/ubuntu/.bashrc
          echo "export SPRING_DATASOURCE_PASSWORD=${var.password_rds_db}">>/home/ubuntu/.bashrc
          echo "export SPRING_DATASOURCE_BUCKET=${var.s3_bucket_name}">>/home/ubuntu/.bashrc
      EOF

  key_name = "${var.ssh_key_name}"
  tags = {
    Name = "ec2 instance"
  }
}



resource "aws_dynamodb_table" "csye6225" {
  name           = "csye6225"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}


resource "aws_iam_policy" "WebAppS3" {
  name        = "WebAppS3"
  description = "S3 bucket policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject"
          ],
          "Effect": "Allow",
          "Resource": [
              "arn:aws:s3:::${var.s3_bucket_name}",
              "arn:aws:s3:::${var.s3_bucket_name}/*"
          ]
      }
  ]
}
EOF
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "EC2-CSYE6225"

  assume_role_policy = "${file("ec2s3role.json")}"

  tags = {
    Name = "EC2-Iam role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_s3_attach" {
  role       = "${aws_iam_role.ec2_s3_role.name}"
  policy_arn = "${aws_iam_policy.WebAppS3.arn}"
}

#Profile for attachment to EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name =  "ec2_profile"
  role = "${aws_iam_role.ec2_s3_role.name}"
}
