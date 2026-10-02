locals {
  name_prefixes = "${var.project}-${var.env}"
}
locals {
  public_nacl_rules = {
    in_http      = { egress = false, num = 100, from = 80, to = 80, cidr = "0.0.0.0/0" }
    in_https     = { egress = false, num = 110, from = 443, to = 443, cidr = "0.0.0.0/0" }
    in_ephemeral = { egress = false, num = 120, from = 1024, to = 65535, cidr = "0.0.0.0/0" }
    out_http     = { egress = true, num = 100, from = 80, to = 80, cidr = "0.0.0.0/0" }
    out_https    = { egress = true, num = 110, from = 443, to = 443, cidr = "0.0.0.0/0" }
    out_ephem    = { egress = true, num = 120, from = 1024, to = 65535, cidr = "0.0.0.0/0" }
    out_app      = { egress = true, num = 130, from = 8080, to = 8080, cidr = var.vpc_cidr }
  }

  private_nacl_rules = {
    in_app       = { egress = false, num = 100, from = 8080, to = 8080, cidr = var.vpc_cidr }
    in_db        = { egress = false, num = 110, from = 3306, to = 3306, cidr = var.vpc_cidr }
    in_ephemeral = { egress = false, num = 120, from = 1024, to = 65535, cidr = "0.0.0.0/0" }
    out_https    = { egress = true, num = 100, from = 443, to = 443, cidr = "0.0.0.0/0" }
    out_http     = { egress = true, num = 110, from = 80, to = 80, cidr = "0.0.0.0/0" }
    out_ephem    = { egress = true, num = 120, from = 1024, to = 65535, cidr = var.vpc_cidr }
    out_db       = { egress = true, num = 130, from = 3306, to = 3306, cidr = var.vpc_cidr }
  }
}
