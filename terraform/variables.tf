variable "aws_region"        { 
    default = "eu-central-1" 
}
variable "cluster_name"      { 
    default = "messaging-system" 
}
variable "vpc_cidr"          { 
    default = "10.0.0.0/16" 
}
variable "node_instance_type" { 
    default = "t3.medium" 
}
variable "desired_capacity"  { 
    default = 2 
}
variable "rds_db_name"       {}
variable "rds_username"      {}
variable "rds_password"      {}
variable "route53_zone_name" { 
    default = "yourdomain.com" 
}