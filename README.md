# Two-Tier Terraform Project for Bookshop Application

This project provisions a two-tier web application infrastructure for a bookshop using Terraform on AWS.

## Architecture Overview

The infrastructure consists of:

1. **VPC** with public and private subnets across two availability zones
2. **Application Load Balancer** in public subnets
3. **Frontend tier** with EC2 instances in public subnets
4. **Backend tier** with EC2 instances in private subnets
5. **RDS database** in private subnets
6. **Security groups** for each tier with appropriate access controls
7. **NAT Gateway** for outbound internet access from private subnets

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0 or later)
- AWS CLI configured with appropriate credentials
- An AWS account

## Infrastructure Components

### Networking
- VPC (10.0.0.0/16)
- Public Subnets (10.0.1.0/24, 10.0.2.0/24)
- Private Subnets (10.0.3.0/24, 10.0.4.0/24)
- Internet Gateway
- NAT Gateway
- Route Tables

### Security
- Security groups for ALB, frontend, backend, and RDS
- Restricted inbound/outbound rules

### Compute
- Frontend EC2 instances (t2.micro) in public subnets
- Backend EC2 instances (t2.micro) in private subnets

### Database
- RDS MySQL instance (db.t3.micro) in private subnets

## Getting Started

1. Clone this repository
2. Navigate to the project directory
3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the execution plan:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

6. To destroy the infrastructure when no longer needed:
   ```bash
   terraform destroy
   ```

## Customization

You can customize the deployment by modifying variables in `variables.tf` or by creating a `terraform.tfvars` file:

```hcl
aws_region         = "us-east-1"
instance_type      = "t3.small"
db_instance_class  = "db.t3.small"
```

## Outputs

After successful deployment, Terraform will output:
- VPC and subnet IDs
- Security group IDs
- Load balancer DNS name
- EC2 instance IDs
- RDS endpoint and database name

## Security Notes

- SSH access is allowed from anywhere (0.0.0.0/0) for demonstration purposes
- In production, restrict SSH access to specific IP ranges
- Database credentials are defined in variables and should be secured appropriately
- Consider using AWS Secrets Manager for managing database credentials

## Cost Considerations

This infrastructure will incur costs for:
- EC2 instances (frontend and backend)
- RDS database instance
- NAT Gateway
- Load balancer

Use `terraform destroy` when the infrastructure is no longer needed to avoid unnecessary charges.