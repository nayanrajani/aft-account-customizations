#------------------------------------------------------------------------------------------------------------------------------
# Shared Route 53 Settings
resource "aws_route53_zone" "<name>" {
  name          = local.private_r53_zone_name
  comment       = "Private hosted zone for AWS LZ in common services account for Shared Services accounts"
  force_destroy = false
  tags          = local.common_tags
  vpc {
    vpc_id     = aws_vpc.comsrv_vpc.id
    vpc_region = local.primary_region
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    aws_vpc.comsrv_vpc
  ]
}


# Authorize application vpcs to be associated with core private hosted zone
resource "aws_route53_vpc_association_authorization" "<name>" {
  count   = length(local.account_list)
  vpc_id  = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list[count.index]}/vpc_id"]
  zone_id = aws_route53_zone.shared_route53_zone.id
}

####

resource "aws_security_group" "<security_group_name>" {
  name        = "<security_group_name>"
  description = "Security group to be associated with r53 resolver"
  vpc_id      = aws_vpc.comsrv_vpc.id

  ingress {
    description = "DNS port"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = local.private_network_range
  }

  ingress {
    description = "DNS port"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = local.private_network_range
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

## Inbound Endpoints
resource "aws_route53_resolver_endpoint" "<inbound_resolver_name>" {
  name      = "<inbound_resolver_name>"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.sg_comsrv_resep_mum_01.id
  ]

  ip_address {
    subnet_id = "id" #sns-comsrv-resolver-mum-a01  #data.aws_subnet.private_subnet_aza.id   
  }

  ip_address {
    subnet_id = "id" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_azb.id  
  }

  tags = local.common_tags

  depends_on = [
    aws_security_group.sg_comsrv_resep_mum_01
  ]
}

resource "aws_route53_resolver_endpoint" "<outbound_resolver_name>" {
  name      = "<outbound_resolver_name>"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.sg_comsrv_resep_mum_01.id
  ]

  ip_address {
    subnet_id = "id" #sns-comsrv-resolver-mum-a01  #data.aws_subnet.private_subnet_aza.id
  }

  ip_address {
    subnet_id = "id" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_azb.id
  }

  tags = local.common_tags

  depends_on = [
    aws_security_group.sg_comsrv_resep_mum_01
  ]
}

resource "aws_route53_resolver_rule" "<<name>>" {
  domain_name          = local.rslr_rule_name
  name                 = "<<name>>"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.resolver_outbound_endpoint.id

  target_ip {
    ip   = aws_route53_resolver_endpoint.resolver_inbound_endpoint.ip_address.*.ip[0]
    port = 53
  }

  target_ip {
    ip   = aws_route53_resolver_endpoint.resolver_inbound_endpoint.ip_address.*.ip[1]
    port = 53
  }

  tags = local.common_tags

  depends_on = [
    aws_route53_resolver_endpoint.resolver_inbound_endpoint,
    aws_route53_resolver_endpoint.resolver_outbound_endpoint,
  ]
}

# aws_res_rule_01 sharing with private shared hosted zone accounts
resource "aws_ram_resource_share" "<resolver-rule-sharing_name>" {
  name                      = "<resolver-rule-sharing_name>"
  allow_external_principals = false
  tags                      = local.common_tags
  depends_on                = [aws_route53_resolver_rule.aws_res_rule_01]
}
resource "aws_ram_resource_association" "resolver-rule-shared_mum_assoc" {
  resource_arn       = aws_route53_resolver_rule.aws_res_rule_01.arn
  resource_share_arn = aws_ram_resource_share.resolver-rule-shared_mum.arn
}

resource "aws_ram_principal_association" "resolver_rule_aws_mm_cloud_ou" {
  count              = length(local.account_number_list)
  principal          = local.account_number_list[count.index]
  resource_share_arn = aws_ram_resource_share.resolver-rule-shared_mum.arn
}


#------------------------------------------------------------------------------------------------------------------------------
# Onprem Route 53 Settings
resource "aws_security_group" "sg_name" {
  name        = "sg_name"
  description = "Security group to be associated with r53 resolver"
  vpc_id      = aws_vpc.comsrv_vpc.id

  ingress {
    description = "DNS port"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = local.onprem_private_network_range
  }

  ingress {
    description = "DNS port"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = local.onprem_private_network_range
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_route53_resolver_endpoint" "onprem_outbound_resolver_name" {
  name      = "onprem_outbound_resolver_name"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.sg_onprem_comsrv_resep_mum_01.id
  ]

  ip_address {
    subnet_id = "id" #sns-comsrv-resolver-mum-a01  #data.aws_subnet.private_subnet_aza.id
  }

  ip_address {
    subnet_id = "id" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_azb.id
  }

  tags = local.common_tags

  depends_on = [
    aws_security_group.sg_onprem_comsrv_resep_mum_01
  ]
}

resource "aws_route53_resolver_rule" "<name>" {
  domain_name          = local.rslr_onprem_rule_name
  name                 = "<name>"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.resolver_onprem_outbound_endpoint.id

  target_ip {
    ip = "ip"
  }
  target_ip {
    ip = "ip"
  }
  target_ip {
    ip = "ip"
  }

  tags = local.common_tags

}

# onprem_res_rule_01 sharing with private shared accounts
resource "aws_ram_resource_share" "<name>" {
  name                      = "<name>"
  allow_external_principals = false
  tags                      = local.common_tags
  depends_on                = [aws_route53_resolver_rule.onprem_res_rule_01]
}
resource "aws_ram_resource_association" "resolver-rule-onprem_mum_assoc" {
  resource_arn       = aws_route53_resolver_rule.onprem_res_rule_01.arn
  resource_share_arn = aws_ram_resource_share.<name>.arn
}

resource "aws_ram_principal_association" "resolver_rule_aws_mm_cloud_onprem" {
  count              = length(local.account_number_list)
  principal          = local.account_number_list[count.index]
  resource_share_arn = aws_ram_resource_share.<name>.arn
}

#------------------------------------------------------------------------------------------------------------------------------
# Dev Route 53 Settings

resource "aws_route53_zone" "<name>" {
  name          = local.private_r53_zone_name_dev
  comment       = "Private hosted zone for AWS LZ in common services account for dev accounts"
  force_destroy = false
  tags          = local.common_tags
  vpc {
    vpc_id     = aws_vpc.comsrv_vpc.id
    vpc_region = local.primary_region
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    aws_vpc.comsrv_vpc
  ]
}


#-----------------------------------------------------------------------------------------------------------------------------------------
# ssm vpc endpoint route 53 setting

resource "aws_route53_zone" "<name>" {

  name          = local.private_r53_zone_ssm_endpoint
  comment       = "Private hosted zone for AWS LZ in common services account for all accounts"
  force_destroy = false
  tags          = local.common_tags
  vpc {
    vpc_id     = aws_vpc.comsrv_vpc.id
    vpc_region = local.primary_region
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    aws_vpc.comsrv_vpc
  ]
}

# Authorize application vpcs to be associated with core private hosted zone
resource "aws_route53_vpc_association_authorization" "private_amazon_r53_zone_ssm_endpoint" {
  count   = length(local.account_list_endpoint)
  vpc_id  = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list_endpoint[count.index]}/vpc_id"]
  zone_id = aws_route53_zone.ssm_endpoint_route53_zone.id
}


#-----------------------------------------------------------------------------------------------------
# VPC Endpoint Security Group Creation for ssm, ssmmessages and ec2messages

resource "aws_security_group" "<name>" {
  name        = "<name>"
  description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
  vpc_id      = aws_vpc.comsrv_vpc.id

  ingress {
    description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.primary_vpc_cidr]
  }

  ingress {
    description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.shared_dev_vpc_cidr]
  }

  ingress {
    description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.shared_prd_vpc_cidr]
  }

  ingress {
    description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.shared_uat_vpc_cidr]
  }

  ingress {
    description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.network_vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.common_tags

}

#-------------------------------------------------------------------------------------------------------
# SSM Endpoint creation for SSM
resource "aws_vpc_endpoint" "<name>" {
  vpc_id            = aws_vpc.comsrv_vpc.id
  service_name      = "com.amazonaws.ap-south-1.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.allow_endpoints.id,
  ]

  subnet_ids          = [data.aws_subnet.private_subnet_aza.id, data.aws_subnet.private_subnet_azb.id]
  private_dns_enabled = false

  depends_on = [
    aws_security_group.allow_endpoints
  ]

  tags = merge(
    { "Name" : "ssm_endpoint_service" }
  )
}


#----------------------------------------------------------------------------------------------------------------------
#Commit to create the ssm Record
resource "aws_route53_record" "private_r53_ssm_a_record" {
  zone_id = aws_route53_zone.ssm_endpoint_route53_zone.id
  name    = local.private_r53_zone_ssm_endpoint
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.ssm_endpoint_service.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.ssm_endpoint_service.dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }

  depends_on = [
    aws_vpc_endpoint.ssm_endpoint_service
  ]
}

