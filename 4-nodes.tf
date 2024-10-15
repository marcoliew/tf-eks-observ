resource "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_name}-eks-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# This policy now includes AssumeRoleForPodIdentity for the Pod Identity Agent
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}


# resource "aws_iam_role_policy_attachment" "aws_service_role_eks_nodegroup" {
#   policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSServiceRoleForAmazonEKSNodegroup"
#   role       = aws_iam_role.nodes.name
# }


resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.nodes.name  # Replace with your worker node role
}

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = local.eks_version
  node_group_name = "${local.capacity_type}-CAP"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [data.aws_subnet.subnet_1.id,data.aws_subnet.subnet_2.id]

  capacity_type  = local.capacity_type
  instance_types = [local.instance_type] # 	t3a.medium

  scaling_config {
    desired_size = local.desired_size
    max_size     = local.max_size
    min_size     = local.min_size
  }

  update_config {
    max_unavailable = 1
    # max_unavailable_percentage = 50 # Percentage of nodes that can be unavailable during an update
    # min_healthy_percent = 50 # Minimum percentage of healthy nodes to maintain during an update
  }

  labels = {
    role = local.capacity_type # "spot"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  tags = {
    "Name"           = "${aws_eks_cluster.eks.name}-node"
    "instance-type"  = local.capacity_type #"spot"
    "eks-cluster"    = aws_eks_cluster.eks.name
  }

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}


# placeholder of fargate

# resource "aws_eks_fargate_profile" "fargate" {
#   cluster_name = aws_eks_cluster.eks.name
#   fargate_profile_name = "${local.env}-fargate-profile"
#   pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn

#   subnet_ids = module.vpc.private_subnets

#   selector {
#     namespace = "fargate-namespace"

#     labels = {
#       environment = "dev"
#     }
#   }

#   depends_on = [aws_eks_cluster.eks]
# }

# place holder for self-managed node pool

# resource "aws_autoscaling_group" "self_managed_asg" {
#   desired_capacity     = local.desired_size
#   max_size             = local.max_size
#   min_size             = local.min_size
#   vpc_zone_identifier  = module.vpc.private_subnets
#   launch_configuration = aws_launch_configuration.self_managed_lc.id
#   target_group_arns    = [] # Add your target groups if needed

#   tag {
#     key                 = "Name"
#     value               = "${local.env}-self-managed-node"
#     propagate_at_launch = true
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [aws_eks_cluster.eks]
# }

# resource "aws_launch_configuration" "self_managed_lc" {
#   name_prefix          = "${local.env}-self-managed-lc-"
#   image_id             = data.aws_ami.eks_worker.image_id
#   instance_type        = local.instance_type # Example: "t3.medium"
#   iam_instance_profile = aws_iam_instance_profile.nodes.name
#   key_name             = var.ssh_key_name

#   user_data = base64encode(templatefile("${path.module}/userdata.sh", {
#     cluster_name = aws_eks_cluster.eks.name
#   }))

#   security_groups = [module.vpc.security_group_id]

#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
#     aws_iam_role_policy_attachment.amazon_eks_cni_policy,
#     aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
#   ]
# }

# data "aws_ami" "eks_worker" {
#   most_recent = true
#   owners      = ["602401143452"] # Amazon EKS AMI owner ID

#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-*"]
#   }
# }
