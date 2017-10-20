# Author: John Williams
# Site: https://github.com/40aujohnwilliams/vpc
# Simple VPC Module Outputs

output "vpc" {
  value = "${aws_vpc.mod.id}"
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}
