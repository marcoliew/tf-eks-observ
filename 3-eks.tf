resource "aws_iam_role" "eks" {
  name = "${local.env}-${local.eks_name}-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}



# Repeat for additional clusters...


resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-${local.eks_name}"
  version  = local.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = [data.aws_subnet.subnet_1.id,data.aws_subnet.subnet_2.id]

  }

  access_config {
    authentication_mode                         = "API" # API_AND_CONFIG_MAP
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Enable control plane logging
  enabled_cluster_log_types  = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  depends_on = [aws_iam_role_policy_attachment.eks]
}

