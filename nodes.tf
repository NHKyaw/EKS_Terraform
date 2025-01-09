resource "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_name}-noderole"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com" #EC2 for worker nodes
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks-cni-policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" #Layer 3 Action from API server to Nodes
}

resource "aws_iam_role_policy_attachment" "eks-ecr-readonly-policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "general" #"memory optimized node-group","cpu-optimized node-group"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  update_config { #Rolling update
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-policy,
    aws_iam_role_policy_attachment.eks-cni-policy,
    aws_iam_role_policy_attachment.eks-ecr-readonly-policy,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size] #When we deploy cluster autoscaler,
    #it will manage the desired auto-scaling-gp which will conflict with the terraform state
  }
}