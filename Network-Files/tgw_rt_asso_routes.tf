
# add below code into the primary_tgw.tf
# search and replace name_of_table with your table name

#-------------------------------------------------------------------------------------------------------
# Route Table
resource "aws_ec2_transit_gateway_route_table" "name_of_table" {
   transit_gateway_id = module.transit_gateway.ec2_transit_gateway_id
   tags = merge(
     { "Name" : "name_of_table" },
     local.common_tags
   )
}

# Associate name_of_table route table
resource "aws_ec2_transit_gateway_route_table_association" "tgw_shared_dev_nonprd_vpc" {
   transit_gateway_attachment_id  = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}<account-name>/tgw_attachment_id"]
   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.name_of_table.id
   depends_on = [
     module.transit_gateway
   ]
}

resource "aws_ec2_transit_gateway_route" "comsrv_vpc_route" {
   destination_cidr_block         = local.comsrv_vpc_cidr
   transit_gateway_attachment_id  = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}<account-name>/tgw_attachment_id"]
   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.name_of_table.id
 }
#----------------------------------------------------------------
