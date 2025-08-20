# AWS Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# VPC Creation
resource "aws_vpc" "bookshop_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "bookshop-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "bookshop_igw" {
  vpc_id = aws_vpc.bookshop_vpc.id

  tags = {
    Name = "bookshop-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.bookshop_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.bookshop_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.bookshop_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.bookshop_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "private-subnet-2"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "bookshop-nat-eip"
  }
}

resource "aws_nat_gateway" "bookshop_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "bookshop-nat"
  }

  depends_on = [aws_internet_gateway.bookshop_igw]
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.bookshop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bookshop_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.bookshop_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.bookshop_nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_1_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_1_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "bookshop-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.bookshop_vpc.id

  # Allow HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bookshop-alb-sg"
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "bookshop-frontend-sg"
  description = "Security group for frontend instances"
  vpc_id      = aws_vpc.bookshop_vpc.id

  # Allow HTTP traffic from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow HTTPS traffic from ALB
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow SSH from anywhere (for administration)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bookshop-frontend-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "bookshop-backend-sg"
  description = "Security group for backend instances"
  vpc_id      = aws_vpc.bookshop_vpc.id

  # Allow HTTP traffic from frontend
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  # Allow HTTPS traffic from frontend
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  # Allow database port from frontend
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  # Allow SSH from anywhere (for administration)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bookshop-backend-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "bookshop-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.bookshop_vpc.id

  # Allow MySQL traffic from backend
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  # Allow MySQL traffic from frontend (if needed)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bookshop-rds-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "bookshop_alb" {
  name               = "bookshop-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "bookshop-alb"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "bookshop_tg" {
  name     = "bookshop-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.bookshop_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

  tags = {
    Name = "bookshop-target-group"
  }
}

# ALB Listener
resource "aws_lb_listener" "bookshop_listener" {
  load_balancer_arn = aws_lb.bookshop_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bookshop_tg.arn
  }
}

# Frontend EC2 Instances
resource "aws_instance" "frontend" {
  count         = 2
  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id              = count.index == 0 ? aws_subnet.public_subnet_1.id : aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Bookshop Frontend Server $(hostname -f)</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "bookshop-frontend-${count.index + 1}"
  }
}

# Backend EC2 Instances
resource "aws_instance" "backend" {
  count         = 2
  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id              = count.index == 0 ? aws_subnet.private_subnet_1.id : aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Bookshop Backend Server $(hostname -f)</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "bookshop-backend-${count.index + 1}"
  }
}

# RDS Database
resource "aws_db_instance" "bookshop_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.bookshop_db_subnet_group.name

  tags = {
    Name = "bookshop-database"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "bookshop_db_subnet_group" {
  name       = "bookshop-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "bookshop-db-subnet-group"
  }
}