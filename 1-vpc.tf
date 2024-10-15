data "aws_vpc" "main" {
  default = true
}

data "aws_region" "current" {}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnet" "subnet_1" {
  id = data.aws_subnets.main.ids[0]
}

data "aws_subnet" "subnet_2" {
  id = data.aws_subnets.main.ids[1]
}



# resource "aws_nat_gateway" "example" {
#   connectivity_type = "private"
#   subnet_id         = data.aws_subnet.example.id
# }

resource "aws_internet_gateway" "gw" {
  vpc_id = data.aws_vpc.main.id
}



data "aws_route_table" "selected" {
  vpc_id = data.aws_vpc.main.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = data.aws_subnet.subnet_1.id
  route_table_id = data.aws_route_table.selected.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = data.aws_subnet.subnet_2.id
  route_table_id = data.aws_route_table.selected.id
}

resource "aws_route" "vpc_igw" {
  #count = var.create_amqp_routes ? 1 : 0

  route_table_id            = data.aws_route_table.selected.id
  destination_cidr_block    = "0.0.0.0/0"
  #nat_gateway_id            = aws_nat_gateway.example.id
  gateway_id                = aws_internet_gateway.gw.id

  # timeouts {
  #   create = "5m"
  # }
}

# setup ssm endpoint for private subnet only access

# Create VPC Endpoint for SSM
# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id       = data.aws_vpc.main.id
#   service_name = "com.amazonaws.${data.aws_region.current.name}.ssm"
#   vpc_endpoint_type = "Interface"

#   # Enable the endpoint for private subnets
#   subnet_ids   = [data.aws_subnet.example.id]  # Replace with your private subnet IDs

#   # Add security groups if needed
#   security_group_ids = [aws_security_group.ssm_access.id]  # Create a security group for SSM access if necessary
# }

# # Create a security group for SSM access (optional)
# resource "aws_security_group" "ssm_access" {
#   name        = "ssm-access"
#   description = "Allow SSM access"
#   vpc_id      = data.aws_vpc.main.id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]  # Adjust according to your security requirements
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

# # Create another VPC Endpoint for SSM messages
# resource "aws_vpc_endpoint" "ssm_messages" {
#   vpc_id       = data.aws_vpc.main.id
#   service_name = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
#    vpc_endpoint_type = "Interface"

#   # Enable the endpoint for private subnets  data "aws_subnets" "example
#   subnet_ids   = [data.aws_subnet.example.id]   # Replace with your private subnet IDs

#   # Add security groups if needed
#   security_group_ids = [aws_security_group.ssm_access.id]  # Use the same SG as above
# }



# resource "aws_vpc_endpoint" "ec2_messages" {
#   vpc_id       = data.aws_vpc.main.id
#   service_name = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
#    vpc_endpoint_type = "Interface"

#   # Enable the endpoint for private subnets  data "aws_subnets" "example
#   subnet_ids   = [data.aws_subnet.example.id]  # Replace with your private subnet IDs

#   # Add security groups if needed
#   security_group_ids = [aws_security_group.ssm_access.id]  # Use the same SG as above
# }


# output "name" {
#   value = data.aws_subnets.example.ids[0]
# }