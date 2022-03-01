resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.aws_eks_cluster.name
  node_group_name = "${var.tf_run_name}-eks-nodegroup"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = [aws_subnet.pvt-subnet-01.id, aws_subnet.pvt-subnet-02.id, aws_subnet.pvt-subnet-03.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  capacity_type = "SPOT"

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.aws_eks_cluster,
  ]

  tags = {
    Name = "${var.tf_run_name}-eks-cluster-oidc-provider"
  }
}
