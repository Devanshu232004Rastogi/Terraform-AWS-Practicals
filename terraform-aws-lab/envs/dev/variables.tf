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
variable "azs" {
  type = list(string)
}

