resource "aws_eks_cluster" "eks" {
  name = "${local.env}-${local.eks_name}"

  access_config {
    authentication_mode = "API" #The value is "API", which means the authentication will use the Kubernetes API
    #Session between terraform user and EKS cluster

    bootstrap_cluster_creator_admin_permissions = true #Use kubectl with admin_permission
  }

  role_arn = aws_iam_role.eks.arn
  version  = local.eks_version

  vpc_config {

    #endpoint indicate where your worker node would deploy
    endpoint_private_access = false #if in prod -> true is recommend
    endpoint_public_access  = true  #dev and tester need to test 

    subnet_ids = [
      aws_subnet.private_zone1.id,
      aws_subnet.private_zone2.id
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks,
  ]
}

resource "aws_iam_role" "eks" {
  name = "${local.env}-${local.eks_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}