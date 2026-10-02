
#---------------------- ALB Security group ---------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefixes}-alb-sg"
  vpc_id      = aws_vpc.main_vpc.id
  description = "secuity-grp for app tier"
  tags        = { Name = "${local.name_prefixes}-alb-sg" }

} #---------------------- APP Security group ---------------------------------------------------

resource "aws_security_group" "app_sg" {
  name        = "${local.name_prefixes}-app-sg"
  vpc_id      = aws_vpc.main_vpc.id
  description = "secuity-grp for app tier"
  tags        = { Name = "${local.name_prefixes}-app-sg" }

}

#---------------------- DB Security group ---------------------------------------------------

resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefixes}-db-sg"
  vpc_id      = aws_vpc.main_vpc.id
  description = "secuity-grp for app tier"
  tags        = { Name = "${local.name_prefixes}-db-sg" }

}

#---------------------- ALB Security group  Ingress Rule HTTP---------------------------------------------------


resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80

}

#---------------------- ALB Security group  Ingress Rule HTTPS---------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

}

#---------------------- ALB Security group  EGRESS/Outbound Rule for ALB-> APP ---------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "alb_to_app_outbound" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}


#---------------------- APP Security group  Ingress Rule ---------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "app_inbound_alb" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port

}

#---------------------- APP Security group  EGRESS/Outbound Rule for APP -> Internet  ---------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "app_to_internet_outbound" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" #like,,,,it is used to tell protocol allow any tcp/udp/icmp
}




#---------------------- DB Security group  Ingress Rule ---------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "db_app_inbound" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port

}
# -------------------------------NACLs---------------------------


# --------------------------Public Nacl --------------------------------------

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${local.name_prefixes}-public-nacl"
  }

}

# --------------------------Public Nacl Association--------------------------------------

resource "aws_network_acl_association" "public_nacl_assocaiation" {
  for_each       = aws_subnet.public_subnet
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = each.value.id
}

# --------------------------Public Nacl rules--------------------------------------

resource "aws_network_acl_rule" "public_nacl_rules" {
  for_each       = local.public_nacl_rules
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = each.value.num
  egress         = each.value.egress
  from_port      = each.value.from
  to_port        = each.value.to
  protocol       = "tcp"
  cidr_block     = each.value.cidr
  rule_action    = "allow"

}


# --------------------------Private Nacl --------------------------------------

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${local.name_prefixes}-private-nacl"
  }

}

# --------------------------Private Nacl Association--------------------------------------

resource "aws_network_acl_association" "private_nacl_assocaiation" {
  for_each       = aws_subnet.private_subnet
  network_acl_id = aws_network_acl.private_nacl.id
  subnet_id      = each.value.id
}

# --------------------------Private Nacl rules--------------------------------------
resource "aws_network_acl_rule" "private_nacl_rules" {
  for_each       = local.private_nacl_rules
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = each.value.num
  egress         = each.value.egress
  from_port      = each.value.from
  to_port        = each.value.to
  protocol       = "tcp"
  cidr_block     = each.value.cidr
  rule_action    = "allow"

}