# VPC Output
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.bookshop_vpc.id
}

# Public Subnet Outputs
output "public_subnet_1_id" {
  description = "ID of the first public subnet"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "ID of the second public subnet"
  value       = aws_subnet.public_subnet_2.id
}

# Private Subnet Outputs
output "private_subnet_1_id" {
  description = "ID of the first private subnet"
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "ID of the second private subnet"
  value       = aws_subnet.private_subnet_2.id
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "frontend_security_group_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend_sg.id
}

output "backend_security_group_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend_sg.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.bookshop_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the application load balancer"
  value       = aws_lb.bookshop_alb.zone_id
}

# EC2 Instance Outputs
output "frontend_instance_ids" {
  description = "IDs of the frontend instances"
  value       = aws_instance.frontend[*].id
}

output "backend_instance_ids" {
  description = "IDs of the backend instances"
  value       = aws_instance.backend[*].id
}

# RDS Database Outputs
output "rds_endpoint" {
  description = "Endpoint of the RDS database"
  value       = aws_db_instance.bookshop_db.endpoint
}

output "rds_database_name" {
  description = "Name of the RDS database"
  value       = aws_db_instance.bookshop_db.db_name
}