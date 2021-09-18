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

resource "aws_iam_policy" "eks_alb_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Service account Policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

resource "aws_iam_role" "eks_alb_role" {
  name = "${var.tf_run_name}-eks-alb-role"

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

resource "aws_iam_role_policy_attachment" "AmazonALBPolicyAttachment" {
  policy_arn = aws_iam_policy.eks_alb_policy.arn
  role       = aws_iam_role.eks_alb_role.name
}