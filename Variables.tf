#This file allows you to customize the region and database credentials without changing the main code
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  default     = "obelion"
}

variable "db_username" {
  description = "Username for the RDS instance"
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
  default     = "obelion123"  # In production, iwill use secret maneger 
}

