data "aws_iam_policy_document" "dns_manager" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "dns_manager" {
  name               = "${aws_eks_cluster.eks.name}-dns-manager"
  assume_role_policy = data.aws_iam_policy_document.dns_manager.json
}

resource "aws_iam_policy" "dns_manager" {
  name = "dns_manager"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "route53:GetChange",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "route53:ListHostedZonesByName"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dns_manager" {
  policy_arn = aws_iam_policy.dns_manager.arn
  role       = aws_iam_role.dns_manager.name
}

resource "aws_eks_pod_identity_association" "dns_manager" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "cert-manager"
  service_account = "cert-manager"
  role_arn        = aws_iam_role.dns_manager.arn
}

# Pod identity for aws lb controller

data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "aws_lbc" {
  name               = "${aws_eks_cluster.eks.name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

resource "aws_iam_policy" "aws_lbc" {
  policy = file("./iam/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"    # service account set at helm_release aws_lbc
  role_arn        = aws_iam_role.aws_lbc.arn
}

# provide irsa role for external dns

module "external_dns_irsa" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name   = "${local.env}-${local.eks_name}-irsa-role-external-dns"

  attach_external_dns_policy = true
  external_dns_hosted_zone_arns   = [aws_route53_zone.xen_local.arn,data.aws_route53_zone.xen.arn]

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["network:external-dns"]
    }
  }

}
