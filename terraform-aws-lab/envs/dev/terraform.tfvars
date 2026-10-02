region   = "us-east-1"
project  = "aws-tf-lab"
env      = "dev"
vpc_cidr = "10.0.0.0/16"
# azs      = ["us-east-1a", "us-east-1b"]

az_netnum_map_public = {
  "a" = {
    az     = "us-east-1a"
    netnum = 0
  }
  "b" = {
    az     = "us-east-1b"
    netnum = 1
  }
}
az_netnum_map_private = {

  "a" = {
    az     = "us-east-1a"
    netnum = 10
  }
  "b" = {
    az     = "us-east-1b"
    netnum = 11
  }
}
