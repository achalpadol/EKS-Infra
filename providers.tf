
# AWS Provider
provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = var.COMMON_TAGS
  }
}

# Read the existing EKS cluster
data "aws_eks_cluster" "this" {
  name = var.EKS_CLUSTER_NAME
}

# Kubernetes Provider
provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.EKS_CLUSTER_NAME,
      "--region",
      var.AWS_REGION
    ]
  }
}

# Helm Provider (version 3 syntax)
provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.this.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        var.EKS_CLUSTER_NAME,
        "--region",
        var.AWS_REGION
      ]
    }
  }
}
