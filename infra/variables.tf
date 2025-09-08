variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy resources in"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
}

variable "allowed_account_id" {
  description = "AWS Account ID allowed to access the S3 bucket"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Default to a smaller instance type
}

variable "project_tag" {
  description = "The project tag to apply to resources"
  type        = string
  default     = "fencoder"
}