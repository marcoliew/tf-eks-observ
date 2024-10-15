# resource "null_resource" "script1" {
#   # provisioner "local-exec" {
#   #   command = "echo this is $ZONE_ID "
#   #   #interpreter = ["sh"]
#   #   environment = {
#   #     ZONE_ID = aws_route53_zone.xen.zone_id
#   #   }      

# # kubectl create -f ingress.yaml -n ${NGINXDEMO_NS:-"default"}

#   provisioner "local-exec" {
#     #command = "aws eks update-kubeconfig --name ${local.env}-${local.eks_name} --user-alias installadmin"
#     command = <<-EOT
#       kubectl apply -f app/cert/8-issuer-production.yaml
#     EOT  
#     #interpreter = ["sh"]
#     # environment = {
#     #   ZONE_ID = aws_route53_zone.xen.zone_id
#     # }    
#   }

# }

# # command = <<-EOT
# #   exec "command1"
# #   exec "command2"
# # EOT
