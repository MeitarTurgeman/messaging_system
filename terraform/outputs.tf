output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_username" {
  value = aws_db_instance.postgres.username
}