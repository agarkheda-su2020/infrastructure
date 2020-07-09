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
          echo "export SPRING_DATASOURCE_URL=${aws_db_instance.csye6225.address}">>/etc/environment
          echo "export SPRING_DATASOURCE_USERNAME=${var.username_rds_db}">>/etc/environment
          echo "export SPRING_DATASOURCE_PASSWORD=${var.password_rds_db}">>/etc/environment
          echo "export SPRING_DATASOURCE_BUCKET=${var.s3_bucket_name}">>/etc/environment
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
  name = "CodeDeployEC2ServiceRole"

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
#Assignment 6 starts--------------------->>>>

#S3 bucket for CodeDeploy

resource "aws_s3_bucket" "CodeDeploy_bucket" {
  bucket = var.CodeDeploy_bucket
  

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }

    expiration {
      days = 30
    }
  }

  lifecycle_rule {
    id      = "tmp"
    prefix  = "tmp/"
    enabled = true

  }
}

resource "aws_s3_bucket_object" "bucket_object_CodeDeploy" {
  key                    = "someobject"
  bucket                 = "${aws_s3_bucket.CodeDeploy_bucket.id}"
  server_side_encryption = "AES256"
}

#CodeDeploy-EC2-S3 Policy for the Server (EC2)

resource "aws_iam_policy" "CodeDeploy-EC2-S3" {
  name        = "CodeDeploy-EC2-S3"
  description = "CodeDeploy-EC2-S3 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "s3:Get*",
              "s3:List*"
          ],
          "Effect": "Allow",
          "Resource": [
              "arn:aws:s3:::${var.CodeDeploy_bucket}",
              "arn:aws:s3:::${var.CodeDeploy_bucket}/*"
          ]
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_CodeDeploy_attach" {
  role       = "${aws_iam_role.ec2_s3_role.name}"
  policy_arn = "${aws_iam_policy.CodeDeploy-EC2-S3.arn}"
}


#CircleCI-Upload-To-S3 Policy for CircleCI to Upload to AWS S3

resource "aws_iam_policy" "CircleCI-Upload-To-S3" {
  name        = "CircleCI-Upload-To-S3"
  description = "CircleCI-Upload-To-S3 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "s3:Get*",
              "s3:List*",
              "s3:PutObject"
          ],
          "Effect": "Allow",
          "Resource": [
              "arn:aws:s3:::${var.CodeDeploy_bucket}",
              "arn:aws:s3:::${var.CodeDeploy_bucket}/*"
          ]
      }
  ]
}
EOF
}

#CircleCI-Upload-To-S3 Policy for CircleCI to Upload to AWS S3 Attachment

resource "aws_iam_user_policy_attachment" "CircleCI-Upload-To-S3-attach" {
  user       = "circleci"
  policy_arn = "${aws_iam_policy.CircleCI-Upload-To-S3.arn}"
}

#CircleCI-Code-Deploy Policy for CircleCI to Call CodeDeploy¶

resource "aws_iam_policy" "CircleCI-Code-Deploy" {
  name        = "CircleCI-Code-Deploy"
  description = "allows CircleCI to call CodeDeploy APIs to initiate application deployment on EC2 instances."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:application:${var.CODE_DEPLOY_APPLICATION_NAME}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}


#CircleCI-Code-Deploy Policy for CircleCI to Call CodeDeploy¶ Attachment

resource "aws_iam_user_policy_attachment" "CircleCI-Call-To-S3-attach" {
  user       = "circleci"
  policy_arn = "${aws_iam_policy.CircleCI-Code-Deploy.arn}"
}

#Policy for Circle Ci : circleci-ec2-ami
resource "aws_iam_policy" "Circleci-ec2-ami" {
  name        = "Circleci-ec2-ami"
  description = "Circleci-ec2-ami policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

#Circleci-ec2-ami Policy for CircleCI 

resource "aws_iam_user_policy_attachment" "Circleci-ec2-ami-attach" {
  user       = "circleci"
  policy_arn = "${aws_iam_policy.Circleci-ec2-ami.arn}"
}






# #Code Deploy EC2 service Role  Just created not attached any policies till now

# resource "aws_iam_role" "CodeDeployEC2ServiceRole" {
#   name = "CodeDeployEC2ServiceRole"

#   assume_role_policy = "${file("ec2s3role.json")}"

#   tags = {
#     Name = "CodeDeployEC2ServiceRole"
#   }
# }



# CodeDeploy Deployment group

resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.CodeDeployServiceRole.name}"
}

resource "aws_codedeploy_app" "csye6225-webapp" {
  name = "csye6225-webapp"
  # compute_platform= "EC2/On-premises"
}

# resource "aws_sns_topic" "example" {
#   name = "example-topic"
# }

resource "aws_codedeploy_deployment_group" "csye6225-webapp-deployment" {
  app_name              = "${aws_codedeploy_app.csye6225-webapp.name}"
  deployment_group_name = "csye6225-webapp-deployment"
  service_role_arn      = "${aws_iam_role.CodeDeployServiceRole.arn}"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "ec2 instance"
    }

  }

  # trigger_configuration {
  #   trigger_events     = ["DeploymentFailure"]
  #   trigger_name       = "example-trigger"
  #   trigger_target_arn = "${aws_sns_topic.example.arn}"
  # }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  # alarm_configuration {
  #   alarms  = ["my-alarm-name"]
  #   enabled = true
  # }
}

#Assignment 7 starts--------------------->>>>

resource "aws_iam_role_policy_attachment" "AWSCloudWatchPolicyAttachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  role       = "${aws_iam_role.ec2_s3_role.name}"
}