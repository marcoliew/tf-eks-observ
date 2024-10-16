resource "helm_release" "kube-prometheus-stack" {
  name = "ps"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  #version    = "62.7.0"
  create_namespace = true
  values = [file("${path.module}/values/kube-prometheus-stack.yaml")]
  depends_on = [aws_eks_node_group.spot]
}

resource "helm_release" "kiali" {
  name = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = "monitoring"
  #version    = "62.7.0"
  #values = [file("${path.module}/values/kube-prometheus-stack.yaml")]
  set {
    name  = "auth.strategy"
    value = "anonymous"
  }  
  depends_on = [helm_release.kube-prometheus-stack]
}


# resource "helm_release" "external-dns" {
#   name = "external-dns"
#   repository       = "https://kubernetes-sigs.github.io/external-dns/"
#   chart            = "external-dns"
#   namespace        = "aws-network"
#   create_namespace = true
#   version          = "1.15.0"
#   values = [file("${path.module}/values/external-dns.yaml")]
#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.external_dns_irsa.iam_role_arn 
#   }
#   depends_on = [aws_eks_node_group.spot]
# }

resource "helm_release" "istio_base" {
  name = "my-istio-base-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true
  #version          = "1.17.1"

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }

  depends_on = [aws_eks_node_group.spot]
}

resource "helm_release" "istiod" {
  name = "my-istiod-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  #version          = "1.17.1"   # 1.23.2

  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }

  set {
    name  = "meshConfig.ingressService"
    value = "istio-gateway"
  }

  set {
    name  = "meshConfig.ingressSelector"
    value = "gateway"
  }

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "gateway" {
  name = "gateway"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-system"
  create_namespace = true
  #version          = "1.17.1"

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"  # Change to "classic" for Classic Load Balancer
  }

  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
  #   value = "true" 
  # }

  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
  #   value = "tcp"  # Optional: specify the backend protocol if needed
  # }

  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
  #   value = "ip"  # Optional: specify the backend protocol if needed
  # }

}


resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  #version    = "1.7.2"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = false
  }

  depends_on = [aws_eks_node_group.spot]
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.15.3"

  set {
    name  = "installCRDs"
    value = "true"
  }

    # Optional: Used for the DNS-01 challenge.
  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }

  # Optional: Used for the DNS-01 challenge.
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.dns_manager.arn
  }

  # provisioner "local-exec" {
  #   command = "cat app/3-example/8-issuer-production.yaml | envsubst | kubectl apply -f-"
  #   #interpreter = ["PowerShell", "-Command"]
  #   environment = {
  #     ZONE_ID = aws_route53_zone.xen.zone_id
  #   }    
  #   # working_dir = "${path.module}"
  # }

  depends_on = [aws_eks_node_group.spot]
}

# resource "helm_release" "metrics_server" {  # moved to  addon.tf
#   name = "metrics-server"

#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"
#   version    = "3.12.1"

#   values = [file("${path.module}/values/metrics-server.yaml")]

#   depends_on = [aws_eks_node_group.spot]
# }


# resource "helm_release" "cluster_autoscaler" {
#   name = "autoscaler"

#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   version    = "9.37.0"

#   set {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"
#   }

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = aws_eks_cluster.eks.name
#   }

#   # MUST be updated to match your region 
#   set {
#     name  = "awsRegion"
#     value = "ap-southeast-2"
#   }

#   depends_on = [helm_release.metrics_server]
# }
