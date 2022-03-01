data "aws_caller_identity" "current" {}


resource "aws_iam_policy" "lb-controller-policy" {
  name        = "${aws_eks_cluster.aws_eks_cluster.name}-alb-management"
  description = "Permissions that are required to manage AWS Application Load Balancers."
  policy      = file("iam_policy.json")
}


data "aws_iam_policy_document" "eks_oidc_assume_role" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.k8s_namespace}:aws-load-balancer-controller"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}


resource "aws_iam_role" "lb-controller-iam-role" {
  name        = "${aws_eks_cluster.aws_eks_cluster.name}-alb-ingress-controller"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."

  tags = {
    Name = "${var.tf_run_name}-eks-cluster-iam-role"
  }

  force_detach_policies = true

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role.json
}



resource "aws_iam_role_policy_attachment" "lb-controller-role-policy-attachment" {
  policy_arn = aws_iam_policy.lb-controller-policy.arn
  role       = aws_iam_role.lb-controller-iam-role.name
}