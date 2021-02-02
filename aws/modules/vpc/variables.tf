variable "project" {
  description = "Project Name"
  default     = "Prashant-Sample-Project"
}

variable "environment" {
  description = "Dev, Staging, Production"
  default     = "Dev"
}

variable "tags" {
  type        = map(string)
  description = "Optional Tags"
  default     = {}
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  type        = list
  description = "List of availability zones"
}

variable "ingressCIDRblock" {
    type = list
}

variable "egressCIDRblock" {
    type = list
}
