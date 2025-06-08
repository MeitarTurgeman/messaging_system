output "cluster_name" {
  value = module.eks.cluster_name
}
output "kubeconfig" {
  value = module.eks.kubeconfig
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "node_group_role_arn" {
  value = module.eks.node_group_iam_role_arn
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}