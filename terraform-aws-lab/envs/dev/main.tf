resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefixes}-vpc"
  }
}
resource "aws_subnet" "public_subnet" {
  for_each                = var.az_netnum_map_public
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = each.value.az
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value.netnum)
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name_prefixes}-public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each          = var.az_netnum_map_private
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = each.value.az
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.netnum)
  tags = {
    Name = "${local.name_prefixes}-private-subnet-${each.key}"
  }
}
