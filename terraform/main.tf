# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"
  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  eks_managed_node_group_defaults = { ami_type = "AL2_x86_64" }
  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_capacity
      max_size       = 4
      min_size       = 1
      instance_types = [var.node_instance_type]
      name           = "main"
    }
  }
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  tags = { Environment = "dev", Terraform = "true" }
}

#RDS
resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-rds-sg"
  description = "Allow DB access from EKS nodes"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    description = "Postgres from EKS nodes"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.cluster_name}-rds-sg" }
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${var.cluster_name}-postgres-subnet-group"
  subnet_ids = module.vpc.private_subnets
  tags = { Name = "${var.cluster_name}-postgres-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.cluster_name}-postgres"
  engine                  = "postgres"
  engine_version          = "15.6"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = var.rds_db_name
  username                = var.rds_username
  password                = var.rds_password
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  tags = { Environment = "dev", Terraform = "true" }
}

# Application Load Balancer
resource "aws_security_group" "alb" {
  name   = "${var.cluster_name}-alb-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.cluster_name}-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "alb_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ECR (Elastic Container Registry)
resource "aws_ecr_repository" "app" {
  name                 = "${var.cluster_name}-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# S3 Bucket
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.cluster_name}-bucket"
  force_destroy = true
  tags = {
    Name        = "${var.cluster_name}-bucket"
    Environment = "dev"
  }
}

# Route 53
resource "aws_route53_zone" "main" {
  name = var.route53_zone_name
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app"
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}