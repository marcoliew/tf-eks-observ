# output "prometheus_workspace_id" {
#   value = "${aws_prometheus_workspace.main.prometheus_endpoint}api/v1/remote_write"
# }

output "nameservers" {
  value = data.aws_route53_zone.xen.name_servers
}

output "dns_zone_id" {
  value = data.aws_route53_zone.xen.zone_id
}
