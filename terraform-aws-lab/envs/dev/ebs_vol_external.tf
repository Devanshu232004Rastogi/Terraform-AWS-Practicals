resource "aws_ebs_volume" "external_vol" {
  type              = "gp3"
  availability_zone = aws_instance.ec2.availability_zone
  size              = 2
  encrypted         = true
  tags = {
    "Name" = "${local.name_prefixes}-volume_external"
    Backup = "daily"

  }
}

resource "aws_volume_attachment" "external_vol_attach" {
  volume_id   = aws_ebs_volume.external_vol.id
  device_name = "/dev/sdf"
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


# -----------------------DLM--------------------------------

resource "aws_dlm_lifecycle_policy" "name" {
  description        = "creating for auto snapshot"
  execution_role_arn = aws_iam_role.ebs_dlm_role.arn
  state              = "ENABLED"
  policy_details {
    resource_types = ["VOLUME"]
    target_tags = {
      Backup = "daily"

    }
    schedule {
      name = "daily_snaphot_backup"
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times = ["03:00"]
      }
      retain_rule {
        count = 7
      }

      tags_to_add = { SnapshotCreator = "DLM" }
      copy_tags   = true
    }
  }
}