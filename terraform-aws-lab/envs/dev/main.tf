# ------------------------- Custom vpc creation ----------------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefixes}-vpc"
  }
}

# ------------------------public-subnet--------------------------------------
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
# -----------------------private-subnet---------------------------------
resource "aws_subnet" "private_subnet" {
  for_each          = var.az_netnum_map_private
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = each.value.az
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.netnum)
  tags = {
    Name = "${local.name_prefixes}-private-subnet-${each.key}"
  }
}
# --------------------internet-gateways---------------------------------------
resource "aws_internet_gateway" "lab-main-gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${local.name_prefixes}-internet-gateway}"
  }
}


# --------------------public route creation-------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${local.name_prefixes}-public-rt"
  }

}

resource "aws_route" "route-to-ig" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.lab-main-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_rt_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id

}

# -------------------------private route part -----------------------------------

resource "aws_route_table" "private_rt" {
  for_each = aws_subnet.private_subnet
  vpc_id   = aws_vpc.main_vpc.id
  tags = {
    Name = "${local.name_prefixes}-private-rt${each.key}"
  }

}


resource "aws_route_table_association" "Private_rt_association" {

  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id # aws_route_table["a"].id

}

# ----------------------elastic ip-------------------------------------------------------


resource "aws_eip" "nat-gw-eip" {
  for_each = var.enable_nat ? aws_subnet.public_subnet : {}
  domain   = "vpc"
  tags = {
    Name = "${local.name_prefixes}-eip${each.key}"

  }
}

# ---------------------------Nat gateways]---------------------------
resource "aws_nat_gateway" "main_nat-gw" {
  for_each = var.enable_nat ? aws_subnet.public_subnet : {}

  allocation_id = aws_eip.nat-gw-eip[each.key].id
  subnet_id     = each.value.id

  tags = { Name = "${local.name_prefixes}-nat-${each.key}" }

  depends_on = [aws_internet_gateway.lab-main-gw]
}


# ---------------------private subnet route---------------------------------
resource "aws_route" "private-subner-nat" {
  for_each               = var.enable_nat ? aws_route_table.private_rt : {}
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main_nat-gw[each.key].id


}


# -------------------vpc endpoint for s3 -gateway -----------------------

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3_vpc_ep" {
  vpc_id            = aws_vpc.main_vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids   = [for rt in aws_route_table.private_rt : rt.id]
  tags              = { Name = "${local.name_prefixes}-vpc_endpoint_for_s3" }


}

