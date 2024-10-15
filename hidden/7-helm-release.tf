resource "helm_release" "kube-prometheus-stack" {
  name = "ps"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "62.7.0"
  create_namespace = true
  #values = [file("${path.module}/values/kube-prometheus-stack.yaml")]

  values = [
      <<-EOT
          commonLabels:
            prometheus: selected
          grafana:
            enabled: true
            adminPassword: abc123
            defaultDashboardsTimezone: AEST
          prometheus:
            serviceAccount:
              name: ${local.amp_remotewrite_irsa}
              annotations:
                eks.amazonaws.com/role-arn: ${aws_iam_role.amp_remotewrite.arn}
            prometheusSpec:
              remoteWrite:
                - url: "${aws_prometheus_workspace.main.prometheus_endpoint}api/v1/remote_write"
              serviceMonitorSelectorNilUsesHelmValues: false
              podMonitorSelector:
                matchLabels:
                  prometheus: selected
              podMonitorNamespaceSelector:
                matchLabels:
                  monitoring: prometheus
              serviceMonitorSelector:
                matchLabels:
                  prometheus: selected
          kubeStateMetrics:
            enabled: true
          kube-state-metrics:
            prometheus:
              monitor:
                enabled: true
                additionalLabels:
                  prometheus: selected
      EOT
  ]
  # #ser

  # set {
  #   name  = "prometheus.prometheusSpec.remoteWrite[0].url"
  #   value = "${aws_prometheus_workspace.main.prometheus_endpoint}api/v1/remote_write"
  # }
  # set {
  #   name  = "prometheus.serviceAccount"
  #   value = local.amp_remotewrite_irsa
  # }
  # set {
  #   name  = "prometheus.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.amp_remotewrite.arn
  # }

  # set {
  #   name  = "prometheus.prometheusSpec.remoteWrite.sigv4.region"
  #   value = local.region
  # }



  # set {
  #   name  = "remote_write.bearer_token"
  #   value = aws_iam_openid_connect_provider.eks.url
  # }

}

# Grafana default password
# admin:prom-operator



