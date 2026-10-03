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