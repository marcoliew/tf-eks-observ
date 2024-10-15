# data "aws_availability_zones" "available" {state = "available"}
# data "aws_caller_identity" "current" {}

# Retrieve aws NLB public hostname and add DNS record in route 53 hossted zone resolving to it.

data "kubernetes_service" "istio_ingress" {
  #count = module.eks_blueprints_addons.ingress_nginx?1:0
  metadata {
    name = helm_release.gateway.name # "${helm_release.external_nginx.metadata[0].name}-ingress-nginx-controller"
    namespace = helm_release.gateway.namespace
  }
}

# # For output NLB name

data "aws_lb" "istio_nlb" {
  #count = kubernetes_service.ingress-nginx[0]?1:0
  name = substr(data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].hostname,0,substr(data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].hostname,31,1)=="-"?31:32)
  #name = "${local.env}-${local.eks_name}-external-ingress"
  #depends_on = [module.eks_blueprints_addons]
}

output "nlb" {
  value = data.aws_lb.istio_nlb.name  #substr(data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].hostname,0,substr(data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].hostname,31,1)=="-"?31:32)
}


# Retrieve aws NLB public hostname and add DNS record in route 53 hossted zone resolving to it.

# data "kubernetes_service" "ingress-nginx" {
#   metadata {
#     name = "${helm_release.external_nginx.metadata[0].name}-ingress-nginx-controller"
#     namespace = helm_release.external_nginx.metadata[0].namespace
#   }
# }

# # # For output NLB name

# data "aws_lb" "ingress_nginx" {
#   name = substr(data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname,0,31)
#   depends_on = [helm_release.external_nginx]
# }