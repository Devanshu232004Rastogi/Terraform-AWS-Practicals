output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

# output "public_subnet_ids" {
#   value = aws_subnet.public_subnet[*].id
# }
# output "private_subnetids" {
#   value = aws_subnet.private_subnet[*].id
# }


output "private_subnetids" {
value = {  
    for k, s in aws_subnet.private_subnet :
        k=> s.id }
}
