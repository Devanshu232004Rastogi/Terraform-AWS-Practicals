output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

# output "public_subnet_ids" {
#   value = aws_subnet.public_subnet[*].id
# }
# output "private_subnetids" {
#   value = aws_subnet.private_subnet[*].id
# }


output "public_subnetids" {
  value = {
    for k, s in aws_subnet.public_subnet :
  k => s.id }
}
output "private_subnetids" {
  value = {
    for k, s in aws_subnet.private_subnet :
  k => s.id }
}


output "gw_id" {
  value = aws_internet_gateway.lab-main-gw.id
}

output "public_rt_id" {
  value = aws_route_table.public_rt.id
}
output "private_rt_id" {
  value = {
    for k, rt in aws_route_table.private_rt : k => rt.id
  }
}

output "nat_public_ips" {
  value = { for k, e in aws_eip.nat-gw-eip : k => e.public_ip }
}

output "security_group_id" {
  value = {
    alb_sg_id = aws_security_group.alb_sg.id
    app_sg_id = aws_security_group.app_sg.id
    db_sg_id  = aws_security_group.db_sg.id


  }
}

output "nacls_id" {
  value = {
    public_nacl_id  = aws_network_acl.public_nacl.id
    private_nacl_id = aws_network_acl.private_nacl.id
  }
}
# output "flow_log_group" { value = aws_cloudwatch_log_group.vpc_flow_log_grp.name }

output "s3_endpoint_id" { value = aws_vpc_endpoint.s3_vpc_ep.id }

output "ec2_instance_profile" { value = aws_iam_instance_profile.instance_profile_main.name }

output "ec2_id" { value = aws_instance.ec2.id }
output "ec2_private_ip" { value = aws_instance.ec2.private_ip }
output "ami_used" { value = data.aws_ami.latest_al2023.id }

output "ssh_private_key" {
  value     = tls_private_key.privateKey.public_key_openssh
  sensitive = true
}

output "external_vol" { value = aws_ebs_volume.external_vol.id }
output "snapshot_id" { value = aws_ebs_snapshot.external_vol_snapshot.id }