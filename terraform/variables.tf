variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "eks-project"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "jenkins_ssh_public_key" {
  description = "SSH public key for Jenkins EC2 access"
  type        = string
}

variable "admin_cidr" {
  type        = string
  description = "Admin's IP for restricted access to Jenkins SSH/UI and the EKS API endpoint"
}
