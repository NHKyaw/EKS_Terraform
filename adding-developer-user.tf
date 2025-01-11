#For AWS Side
resource "aws_iam_user" "developer-eks" {
  name = "developer"
}
resource "aws_iam_policy" "DevPolicy" {
  name = "AWSEKSDeveloperPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "developer-eks-attachment" {
  name       = "AWSEKSDeveloperpolicyAddachment""
  users      = aws_iam_user.developer-eks.name
  policy_arn = aws_iam_policy.DevPolicy.arn
}


#For K8s Side
resource "aws_eks_access_entry" "example" {
  cluster_name      = aws_eks_cluster.example.name
  principal_arn     = aws_iam_user.developer-eks.arn
  kubernetes_groups = ["my-viewer-gp"]
}