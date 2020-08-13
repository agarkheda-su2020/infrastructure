# Cloud Infrastructure

**Infrastructure created using Terraform:**

* created custom VPC with network setup
* Attached Load balancers, auto scaling groups, SES and SNS services
* Created necessary service roles and policies for AWS resources
* Implemented Lambda function for emailing service 

**AWS Services Created USing Terraform**

  <table>
    <thead>
      <tr>
        <th>AWS Service</th>
        <th>Use Case</th>
      </tr>
    </thead>
    <tbody>
        <tr>
            <td>VPC</td>
            <td>Contains ALB, ASG, RDS, EC2, DynamoDB, Security groups, Route tables, Subnets</td>
        </tr>
        <tr>
            <td>Lambda Function</td>
            <td>Triggered by SNS to create/add token in DynamoDB and send a password reset mail to user <td>
        </tr>
         <tr>
            <td>Simple Email Service</td>
            <td>Used by Lambda function to send a password reset mail to user after clicking forgot password</td>
        </tr>
         <tr>
            <td>Simple Notification Service</td>
            <td>Email id is put in SNS topic and sent to Lambda Function which also triggers Lambda</td>
        </tr>
          <tr>
            <td>DynamoDB</td>
            <td>Used to Store Token generated using UUID which has a time to live(TTL) of 15 mins</td>
        </tr>
       <tr>
            <td>RDS</td>
            <td>version MySQL 5.7, stores user and book data</td>
        </tr>
        <tr>
            <td>Application Load Balancers</td>
            <td>Used to distribute the traffic of infrastructure experienced by the application</td>
        </tr>
        <tr>
            <td>Route53</td>
            <td>A records, CNAME and Text records are generated to create domain and prod/dev subdomains</td>
        </tr>
        <tr>
            <td>Cloud-Watch Alarm</td>
            <td>Used for autoscaling up or down incase average CPU utilization exceeds 30% or goes below 10%</td>
        </tr>
        <tr>
            <td>Security Groups</td>
            <td>Application security group, Database security group</td>
        </tr>
        <tr>
            <td>Roles</td>
            <td>CodeDeployEC2ServiceRole, CodeDeployServiceRole, AWSServiceRoleForRDS, AWSServiceRoleForAutoScaling, AWSElasticLoadBalancingServiceRolePolicy</td>
        </tr>
        <tr>
            <td>Policies</td>
            <td>WebAppS3, CodeDeploy-EC2-S3, CircleCI-Upload-To-S3, CircleCI-lambda, Circleci-ec2-ami, CircleCI-Code-Deploy</td>
        </tr>
        <tr>
            <td>Load Balancer Listeners</td>
            <td>httpslb on port 443, httplb on port 80</td>
        </tr>
        <tr>
            <td>Launch Configuration</td>
            <td>Conatins the userdata environment variables and EC2 configurations: t2micro, image id etc </td>
        </tr>
        <tr>
            <td>Autoscaling Groups</td>
            <td>Conatins target group arn, Max/Min number of EC2 instances, subnets, launch config arn,lifecycle policy</td>
        </tr>
        <tr>
            <td>Loadbalancer Target Group</td>
            <td>Provides sticky sessions, protocol (htpp/htpps etc), vpc and port</td>
        </tr>
        <tr>
            <td>CodeDeploy Deployment Group</td>
            <td>Mentions EC2 instances on which deployment should be done</td>
        </tr>
    </tbody>
  </table>
  

## Architecture Design

![](AWSArchitecture.png)


# Other Links to check

## CI/CD Pipeline - AMI - Hashicorp Packer

[HashiCorp Packer Code Repository](https://github.com/agarkheda-su2020/ami)

## Serverless Computing - Lambda(function as a service) 

[Serverless Lambda Code Repository](https://github.com/agarkheda-su2020/faas)

## Deploying a web application on AWS-EC2

[Web Application Code Repository](https://github.com/agarkheda-su2020/webapp)

`Author: Ashwin Agarkhed` <br />
`Email: agarkhed.a@northeastern.edu`
