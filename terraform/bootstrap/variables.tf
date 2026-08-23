variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type    = string
  default = "eks-project-tfstate-203637463799"
}

variable "lock_table_name" {
  type    = string
  default = "eks-project-tfstate-lock"
}