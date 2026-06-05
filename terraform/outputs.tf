output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = module.ec2.jenkins_public_ip
}

output "ecr_backend_url" {
  description = "ECR URL for the backend image"
  value       = module.ecr.backend_repository_url
}

output "ecr_frontend_url" {
  description = "ECR URL for the frontend image"
  value       = module.ecr.frontend_repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}
