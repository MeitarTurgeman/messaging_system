output "eks_cluster_name" { 
  value = module.eks.cluster_name
}
output "eks_cluster_endpoint" { 
  value = module.eks.cluster_endpoint 
}
output "rds_endpoint" { 
  value = aws_db_instance.postgres.endpoint 
}
output "ecr_repo_url" { 
  value = aws_ecr_repository.app.repository_url 
}
output "s3_bucket_name" {
  value = aws_s3_bucket.app_data.bucket 
}
output "alb_dns_name" { 
  value = aws_lb.alb.dns_name
}