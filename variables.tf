# Author: John Williams
# Site: https://github.com/40aujohnwilliams/vpc
# Simple VPC Module Variables

variable "name" {
  description = "Name of the VPC - used to name/tag all resources in VPC"
  default     = ""
}

variable "cidr_block" {
  description = "CIDR block for the VPC - eg 10.0.0.0/16"
  default     = ""
}

# Note: azs, public_subnets, and private_subnets are closely related.
#       length(azs) == length(public_subnets) === length(private_subnets)

variable "azs" {
  description = "List of availability zones in the region"
  default = []
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks - must be same length as azs"
  default = []
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks - must be same length as azs"
  default = []
}
