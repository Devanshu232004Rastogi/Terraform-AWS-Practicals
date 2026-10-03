data "aws_ami" "latest_al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "privateKey" {
  algorithm = "ED25519"
}
resource "aws_key_pair" "pem_key" {
  key_name   = "${local.name_prefixes}_key"
  public_key = tls_private_key.privateKey.public_key_openssh
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.latest_al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.pem_key.key_name
  subnet_id              = aws_subnet.public_subnet["a"].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile_main.name

  associate_public_ip_address = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1

  }

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /opt/app && cd /opt/app
    echo "hello from $(hostname)" > index.html
    nohup python3 -m http.server 8080 &
  EOF

  user_data_replace_on_change = true

  tags = { Name = "${local.name_prefixes}-app-a" }
}