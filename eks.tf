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

data "tls_certificate" "eks_oidc_cert" {
  url        = aws_eks_cluster.aws_eks_cluster.identity.0.oidc.0.issuer
  depends_on = [aws_eks_cluster.aws_eks_cluster]
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = concat([data.tls_certificate.eks_oidc_cert.certificates.0.sha1_fingerprint], var.oidc_thumbprint_list)
  url             = aws_eks_cluster.aws_eks_cluster.identity.0.oidc.0.issuer
  depends_on      = [data.tls_certificate.eks_oidc_cert]
  tags = {
    Name = "${var.tf_run_name}-eks-cluster-oidc-provider"
  }
}




resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.tf_run_name}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_iam_role" "eks_nodes_role" {
  name = "${var.tf_run_name}-eks-node-group-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}
