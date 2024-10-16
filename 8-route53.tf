# resource "aws_route53_zone" "xen" {
#   name = local.domain_name
#   # lifecycle {
#   #   prevent_destroy = true
#   # }  
# }

data "aws_route53_zone" "xen" {
  name = local.domain_name
  #private_zone = true
}

resource "aws_route53_zone" "xen_local" {
  name = "xeniumsolution.local"
  vpc {
    vpc_id = data.aws_vpc.main.id
  }
}

resource "aws_route53_record" "alias_apex_record" {
  zone_id = data.aws_route53_zone.xen.zone_id # Replace with your zone ID
  name    = local.domain_name # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name                   = data.aws_lb.istio_nlb.dns_name #substr(data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].hostname,0,substr(data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].hostname,31,1)=="-"?31:32) #"k8s-ingress-external-7a4ba4b859-2e928abf1840765c.elb.ap-southeast-2.amazonaws.com"
    zone_id                = data.aws_lb.istio_nlb.zone_id 
    evaluate_target_health = false
  }
  
}


# resource "aws_route53_record" "dev-ns" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "dev.example.com"
#   type    = "NS"
#   ttl     = "30"
#   records = aws_route53_zone.dev.name_servers
# }

# resource "aws_acm_certificate" "xen" {
#   domain_name       = local.domain_name
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "*.${local.domain_name}"
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Define a CW alarm for certificate expiry for (30, 60, 90 days)
# resource "aws_cloudwatch_metric_alarm" "acm_days_to_expiry" {
#   # Iterate over the expiry thresholds
#   for_each = toset([30, 60, 90])

#   # Alarm name will vary based on the threshold value (30, 60, 90 days)
#   alarm_name = "ACM Certificate Expiry - ${each.value} Days (${aws_acm_certificate.xen.domain_name})"
  
#   namespace   = "AWS/CertificateManager"
#   metric_name = "DaysToExpiry"
  
#   # Set dimensions for the ACM certificate
#   dimensions = {
#     CertificateArn = aws_acm_certificate.xen.arn
#   }
  
#   comparison_operator = "LessThanThreshold"  # Trigger when the number of days is below the threshold
#   evaluation_periods  = 1                    # Evaluate once per period
#   period              = 86400                # Period of 1 day
#   statistic           = "Minimum"            # We are interested in the minimum value (i.e., lowest number of days to expiry)

#   # The threshold is based on the current value in the for_each loop (30, 60, or 90 days)
#   threshold = each.value
  
#   alarm_description = "This alarm monitors the ACM certificate's days to expiry and will trigger if it falls below ${each.value} days."

#   insufficient_data_actions = []  # Handle the state of insufficient data

#   # Set alarm and OK actions (e.g., notify via SNS)
#   ok_actions    = [aws_sns_topic.alarms.arn]
#   alarm_actions = [aws_sns_topic.alarms.arn]
# }

# resource "aws_route53_record" "valid" {
#   for_each = {
#     for dvo in aws_acm_certificate.xen.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#    # Skips the domain if it doesn't contain a wildcard
#     if length(regexall("\\*\\..+", dvo.domain_name)) > 0
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 30
#   type            = each.value.type
#   zone_id         = aws_route53_zone.xen.zone_id
# }


# resource "aws_route53_record" "alias_apex_record" {
#   zone_id = aws_route53_zone.xen.zone_id # Replace with your zone ID
#   name    = local.domain_name # Replace with your name/domain/subdomain
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname #"k8s-ingress-external-7a4ba4b859-2e928abf1840765c.elb.ap-southeast-2.amazonaws.com"
#     zone_id                = data.aws_lb.ingress_nginx.zone_id  #"ZCT6FZBF4DROD"
#     evaluate_target_health = false
#   }
  
# }

# resource "aws_route53_record" "alias_sub_record" {
#   zone_id = aws_route53_zone.xen.zone_id # Replace with your zone ID
#   name    = "sub.${local.domain_name}" # Replace with your name/domain/subdomain
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname #"k8s-ingress-external-7a4ba4b859-2e928abf1840765c.elb.ap-southeast-2.amazonaws.com"
#     zone_id                = data.aws_lb.ingress_nginx.zone_id  #"ZCT6FZBF4DROD"
#     evaluate_target_health = false
#   }
# }

# move to k8s external-dns

# resource "aws_route53_record" "alias_prometheus_record" {
#   zone_id = aws_route53_zone.xen.zone_id # Replace with your zone ID
#   name    = "prometheus.${local.domain_name}" # Replace with your name/domain/subdomain
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname #"k8s-ingress-external-7a4ba4b859-2e928abf1840765c.elb.ap-southeast-2.amazonaws.com"
#     zone_id                = data.aws_lb.ingress_nginx.zone_id  #"ZCT6FZBF4DROD"
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "alias_grafana_record" {
#   zone_id = aws_route53_zone.xen.zone_id # Replace with your zone ID
#   name    = "grafana.${local.domain_name}" # Replace with your name/domain/subdomain
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname #"k8s-ingress-external-7a4ba4b859-2e928abf1840765c.elb.ap-southeast-2.amazonaws.com"
#     zone_id                = data.aws_lb.ingress_nginx.zone_id  #"ZCT6FZBF4DROD"
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "alias_api_record" {
#   zone_id = aws_route53_zone.xen.zone_id # Replace with your zone ID
#   name    = "api.${local.domain_name}" # Replace with your name/domain/subdomain
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname #"k8s-ingress-external-7a4ba4b859-2e928abf1840765c.elb.ap-southeast-2.amazonaws.com"
#     zone_id                = data.aws_lb.ingress_nginx.zone_id  #"ZCT6FZBF4DROD"
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "alias_argocd_record" {
#   zone_id = aws_route53_zone.xen.zone_id # Replace with your zone ID
#   name    = "argocd.${local.domain_name}" # Replace with your name/domain/subdomain
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname #"k8s-ingress-external-7a4ba4b859-2e928abf1840765c.elb.ap-southeast-2.amazonaws.com"
#     zone_id                = data.aws_lb.ingress_nginx.zone_id  #"ZCT6FZBF4DROD"
#     evaluate_target_health = false
#   }
# }