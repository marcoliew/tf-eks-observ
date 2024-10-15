
resource "aws_cloudwatch_log_group" "amp" {
  name = "${aws_eks_cluster.eks.name}-amp-lg"
  retention_in_days = 3
}

resource "aws_prometheus_workspace" "main" {
  alias       = "${aws_eks_cluster.eks.name}-amp-workspace"
  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.amp.arn}:*"
  }
}


# Create a policy that allows pushing metrics to AMP
data "aws_iam_policy_document" "amp_write_policy" {
  statement {
    actions = [
      "aps:RemoteWrite",
    ]
    resources = [
      aws_prometheus_workspace.main.arn,
    ]
  }
}

resource "aws_iam_role_policy" "eks_cluster_prometheus_policy" {
  name   = "${local.env}-${local.eks_name}-prometheus-remotewrite-policy"
  role   = aws_iam_role.eks.id
  policy = data.aws_iam_policy_document.amp_write_policy.json
}

resource "aws_iam_role" "amp_remotewrite" {
  name = "${local.env}-${local.eks_name}-amp-remotewrite-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${aws_iam_openid_connect_provider.eks.arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:monitoring:${local.amp_remotewrite_irsa}"
                }
            }
        }
    ]
}
POLICY
}
