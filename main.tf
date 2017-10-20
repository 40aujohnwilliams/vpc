# Author: John Williams
# Site: https://github.com/40aujohnwilliams/vpc
# Simple VPC Module

#-------------------------------------------------------------------------------
# VPC

resource "aws_vpc" "mod" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name      = "${var.name} VPC"
    terraform = true
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.mod.id}"

  tags {
    Name      = "${var.name} Main RT"
    terraform = true
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = "${aws_vpc.mod.id}"
  route_table_id = "${aws_route_table.main.id}"
}

#-------------------------------------------------------------------------------
# Public subnets and dependencies

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.mod.id}"
  count  = "${length(var.public_subnets)}"

  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${var.azs[count.index]}"
  map_public_ip_on_launch = true
  tags {
    Name      = "${format("%s %s Public Subnet", var.name, var.azs[count.index])}"
    terraform = true
  }
}

resource "aws_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"

  tags {
    Name      = "${var.name} IGW"
    terraform = true
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.mod.id}"

  tags {
    Name      = "${var.name} Public RT"
    terraform = true
  }
}

resource "aws_route" "igw" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod.id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

#-------------------------------------------------------------------------------
# Private subnets and dependencies
# One NAT GW and route table per private subnet.

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.mod.id}"
  count  = "${length(var.private_subnets)}"

  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  tags {
    Name      = "${format("%s %s Private Subnet", var.name, var.azs[count.index])}"
    terraform = true
  }
}

resource "aws_eip" "nat" {
  count = "${length(var.private_subnets)}"

  vpc = true
}

resource "aws_nat_gateway" "mod" {
  count = "${length(var.public_subnets)}"

  allocation_id = "${aws_eip.nat.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"

  depends_on = ["aws_internet_gateway.mod"]
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.mod.id}"
  count = "${length(var.private_subnets)}"

  tags {
    Name      = "${var.name} ${var.azs[count.index]} Private RT"
    terraform = true
  }
}

resource "aws_route" "nat" {
  count = "${length(var.private_subnets)}"

  route_table_id         = "${aws_route_table.private.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.mod.*.id[count.index]}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"

  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}
