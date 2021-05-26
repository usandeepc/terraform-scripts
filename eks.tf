resource "aws_eks_cluster" "aws_eks_cluster" {
  name     = "${var.tf_run_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.pvt-subnet-01.id, aws_subnet.pvt-subnet-02.id, aws_subnet.pvt-subnet-03.id, aws_subnet.pub-subnet-01.id, aws_subnet.pub-subnet-02.id, aws_subnet.pub-subnet-03.id]
  }

  tags = {
    Name = "${var.tf_run_name}-eks-cluster"
  }
  depends_on = [aws_route_table_association.pub-rta-03]

}
