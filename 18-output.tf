# output "prometheus_workspace_id" {
#   value = "${aws_prometheus_workspace.main.prometheus_endpoint}api/v1/remote_write"
# }

output "nameservers" {
  value = aws_route53_zone.xen.name_servers
}
