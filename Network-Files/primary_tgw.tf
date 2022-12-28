module "transit_gateway" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.8.0" //version

  name        = local.tgw_name   // add name in locals.tf
  description = "Primary Transit Gateway shared with accounts in ap-south-1"

  create_tgw                             = true
  amazon_side_asn                        = local.tgw_aws_asn  //asn number of tgw
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
  enable_auto_accept_shared_attachments  = true
  enable_vpn_ecmp_support                = false
  ram_allow_external_principals          = false
  ram_principals                         = [local.root_ou_arn]   //Root ou arn
  ram_name                               = "<Name for the resource access manager>"

  tags = local.common_tags
}

resource "aws_ec2_transit_gateway_vpc_attachment" "network_vpc" {
  subnet_ids                                      = aws_subnet.private_subnet[*].id // referring to vpc subnet
  transit_gateway_id                              = module.transit_gateway.ec2_transit_gateway_id
  vpc_id                                          = aws_vpc.network_vpc.id     //vpc id
  appliance_mode_support                          = "enable"
  dns_support                                     = "enable"
  ipv6_support                                    = "disable"
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"
  tags = merge(
    { "Name" : "name" },
    local.common_tags
  )
}

resource "aws_ec2_transit_gateway_route_table" "vpn_tgw_rtb" {
  transit_gateway_id = module.transit_gateway.ec2_transit_gateway_id
  tags = merge(
    { "Name" : "name" },
    local.common_tags
  )
}


# Associate vpc to default tgw route table

resource "aws_ec2_transit_gateway_route" "route" {
  destination_cidr_block         = local.primary_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_vpc_id.id
  transit_gateway_route_table_id = module.transit_gateway.ec2_transit_gateway_route_table_id
}
