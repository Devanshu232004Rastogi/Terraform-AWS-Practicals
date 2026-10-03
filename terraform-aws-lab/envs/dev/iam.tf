data "aws_iam_policy_document" "ec2_role_trust_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ec2_s3_role" {
  name               = "${local.name_prefixes}-ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_trust_doc.json
}

resource "aws_iam_policy_attachment" "ec2_aws_managed" {
  name       = "aws_managed_ssm_policy"
  roles      = [aws_iam_role.ec2_s3_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

data "aws_iam_policy_document" "custom_s3_policy_doc" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.project}-${var.env}-app-bucket",
      "arn:aws:s3:::${var.project}-${var.env}-app-bucket/*",
    ]
  }
}

resource "aws_iam_policy" "s3_custom_for_ec2" {
  name   = "${local.name_prefixes}-s3_custom_policy"
  policy = data.aws_iam_policy_document.custom_s3_policy_doc.json
}
resource "aws_iam_policy_attachment" "s3_policy_role_attach" {
  name       = "${local.name_prefixes}-s3_ec2_attachment"
  policy_arn = aws_iam_policy.s3_custom_for_ec2.arn
  roles      = [aws_iam_role.ec2_s3_role.name]
}

resource "aws_iam_instance_profile" "instance_profile_main" {
  role = aws_iam_role.ec2_s3_role.name
  name = "${local.name_prefixes}-ec2_iam_profile"
}


# -------------------iam related DLM--------------------------------------------

data "aws_iam_policy_document" "trust_policy_dlm" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_dlm_role" {
  name               = "${local.name_prefixes}-dlm_role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_dlm.json
}


data "aws_iam_policy_document" "permission_policy_dlm" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*::snapshot/*"]
  }
}

resource "aws_iam_role_policy" "dlm_role_policy" {
  name   = "${local.name_prefixes}-dlm_role_policy"
  role   = aws_iam_role.ebs_dlm_role.id
  policy = data.aws_iam_policy_document.permission_policy_dlm.json

}

