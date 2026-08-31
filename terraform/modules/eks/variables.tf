variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs for the EKS cluster control plane (public + private)"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnet IDs for the EKS node group (private only)"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small"
}

variable "jenkins_role_arn" {
  type        = string
  description = "ARN of the Jenkins IAM role, for EKS access entry"
}

variable "admin_cidr" {
  type        = string
  description = "Admin's IP for restricted access to the EKS API endpoint"
}
