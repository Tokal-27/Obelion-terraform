provider "aws" {
  region = var.aws_region
}

# VPC & Networking

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" #Creates a large network space (65k IPs)
  enable_dns_hostnames = true #Public instances get friendly URL names (not just IP numbers)
  enable_dns_support   = true # enables AWS Route 53 Resolver

  tags = {Name = "${var.project_name}-vpc"}
}

resource "aws_internet_gateway" "igw" { # Gives your VPC internet access
  vpc_id = aws_vpc.main.id
  tags = {Name = "${var.project_name}-igw"} #igw = internet gateway
}

# Public Subnet (For Frontend & Backend)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24" #256 IPs
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true #Auto-assign public IPs to instances launched here

  tags = { Name = "${var.project_name}-public-subnet"}
}

# Private Subnet 1 (For RDS )
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-private-subnet-1"
  }
}

# Private Subnet 2 (For RDS - AWS RDS requires subnets in at least 2 AZs)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {Name = "${var.project_name}-private-subnet-2"}
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# Security Group for EC2 (Frontend) - Public Access
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress { # Allow SSH from anywhere
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Not secure for production
  }

  ingress { # Allow HTTP from anywhere
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Allow all outbound traffic
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS - Private Access ONLY from Web SG
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL access only from Web SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from Web Layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# EC2 Instances

# Data source to get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter { # Ensure we get only HVM AMIs (standard)
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# A - Backend Machine
resource "aws_instance" "backend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # 1 vCPU, 1 GB RAM
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # 8 GB Disk (Default for this AMI, but explicit here)
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "Backend-Machine"
  }
}

# B - Frontend Machine
resource "aws_instance" "frontend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # 1 vCPU, 1 GB RAM
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # 8 GB Disk
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "Frontend-Machine"
  }
}

# Database (RDS)
# DB Subnet Group (RDS requires this to specify which subnets to use)
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

# C - MySQL Community Version 8 RDS
resource "aws_db_instance" "default" {
  identifier           = "${var.project_name}-db"
  allocated_storage    = 20 # Minimum storage for RDS
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Lowest available current-gen plan
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  
  # Networking
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false # No internet exposure

  skip_final_snapshot    = false #Take snapshot when deleting the DB instance   
}