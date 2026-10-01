resource "aws_vpc" "main_vpc" {
  cidr_block=var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${local.name_prefixes}-vpc"
  }
}
resource "aws_subnet" "public_subnet" {
  count = length(var.azs)
  vpc_id = aws_vpc.main_vpc.id
  availability_zone = var.azs[count.index]
  cidr_block = cidrsubnet(var.vpc_cidr,8,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name_prefixes}-public-subnet-${var.azs[count.index]}"
  }
}

resource "aws_subnet" "private_subnet"{
    count = length(var.azs)
    vpc_id = aws_vpc.main_vpc.id
    availability_zone = var.azs[count.index]
    cidr_block=cidrsubnet(var.vpc_cidr,8,count.index + 10 )
    tags = {
      Name = "${local.name_prefixes}-private-subnet-${var.azs[count.index]}"
    }
}
