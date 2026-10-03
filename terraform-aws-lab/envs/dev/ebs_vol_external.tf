resource "aws_ebs_volume" "external_vol" {
  type              = "gp3"
  availability_zone = aws_instance.ec2.availability_zone
  size              = 2
  encrypted         = true
  tags = {
    "Name" = "${local.name_prefixes}-volume_external"
  }
}

resource "aws_volume_attachment" "external_vol_attach" {
  volume_id   = aws_ebs_volume.external_vol.id
  device_name = "/dev/xds"
  instance_id = aws_instance.ec2.id

}

resource "aws_ebs_snapshot" "external_vol_snapshot" {
  volume_id   = aws_ebs_volume.external_vol.id
  description = "${local.name_prefixes}-external_vol-snapshot for later use"
  tags = {
    "Name" = "${local.name_prefixes}-volume_external_snapshot"
  }
  depends_on = [aws_volume_attachment.external_vol_attach]

}