locals {
  account_name       = "<account-name>"
  primary_vpc_name   = "<primary-vpc-name>"
  primary_region     = "<primary-region>"
  availability_zones = ["${local.primary_region}a", "${local.primary_region}b"]

  primary_vpc_cidr        = "<primary_vpc_cidr>"

  # to fetch via ssm 
  xyz_account_vpc_cidr     = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}<account-name>/vpc_cidr"]

  
  mitc_s2s_route = "<vpn cidr>"  //if require to create new vpn an its route
  mrv_s2s_route = "<vpn cidr>"  //if require to create new vpn an its route

  mrv_tgw_attachment_id   = "<attachment-id>"
  mitc_tgw_attachment_id  = "<attachment-id>"
  dx_pri_attachment_id    = "<attachment-id>"
  dx_sec_attachment_id    = "<attachment-id>"

  private_subnet_list     = ["<cidr_1>", "<cidr_2>"]
  private_subnet_name     = ["<subnet_name_1>", "<subnet_name_2>"]
  private_subnet_rtb_name = ["<rt_name_1>", "<rt_name_1>"]

  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tgw_name          = "<tgw_name_1>"
  tgw_aws_asn       = tgw_asn_number //add number here only
  root_ou_arn       = "arn:aws:organizations::${module.aft_account_list.param_name_values["${local.ssm_parameter_path_account_list}<master-account-name>"]}:organization/${data.aws_ssm_parameter.master_org_id.value}"

  common_tags = {
    tag-key           = "<tag-value>"
    tag-key           = "<tag-value>"
    tag-key           = "<tag-value>"
  }

  ssm_parameter_path              = "/mm/aft/account_customization/output/"
  ssm_parameter_path_org_id       = "/mm/static/master/org-id"
  ssm_parameter_path_account_list = "/mm/aft/account_id/"

  # export outputs of type string
  export_output = {
    vpc_id            = aws_vpc.network_vpc.id
    vpc_cidr          = aws_vpc.network_vpc.cidr_block
    tgw_id            = module.transit_gateway.ec2_transit_gateway_id
    tgw_attachment_id = aws_ec2_transit_gateway_vpc_attachment.network_vpc.id
  }
  # export outputs of type list
  export_list_output = {

  }
}