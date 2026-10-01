variable "region" {
  type = string
}
variable "project" {
  type = string
}
variable "env" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
# variable "azs" {
#   type = list(string)
# }

variable "az_netnum_map_public" {
  type = map(object({
    az     = string
    netnum = number
  }))
}
variable "az_netnum_map_private" {
  type = map(object({
    az     = string
    netnum = number
  }))
}

