provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.aws_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.aws_eks_cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.aws_eks_cluster.name]
      command     = "aws"
    }
  }
}


resource "helm_release" "lb-controller" {
  name       = "aws-lb-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb-controller-iam-role.arn
  }
  set {
    name  = "clusterName"
    value = aws_eks_cluster.aws_eks_cluster.name
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}