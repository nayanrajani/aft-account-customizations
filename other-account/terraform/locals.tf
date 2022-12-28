locals {
  account_name       = "<account-name>"
  primary_vpc_name   = "<vpc-name>"
  primary_region     = "<zone-name>"
  availability_zones = ["${local.primary_region}a", "${local.primary_region}b"]

  # Primary VPC CIDR
  primary_vpc_cidr = "<vpc_cidr>"

  # Private TGW subnet list, name and route table
  private_tgw_subnet_list = ["<tgw-subnet-cidr>", "<tgw-subnet-cidr>"]
  private_tgw_subnet_name = ["<tgw-subnet-name>", "<tgw-subnet-name>"]
  private_tgw_rtb_name    = "<tgw-rt-name>"

  # Public subnet list, name and route table FOR ALB
  public_alb_subnet_list = ["<public_subnet_list>", "<public_subnet_list>"]
  public_alb_subnet_name = ["<public_subnet_name>", "<public_subnet_name>"]
  public_alb_rtb_name    = "<public_rt_list>"


  network_account_id = module.aft_account_list.param_name_values["${local.ssm_parameter_path_account_list}<account-name>"]
  network_tgw_id     = data.aws_ec2_transit_gateway.primary_network_tgw.id
  shared_subnet_list = [
    "subnet-arn",
    "subnet-arn",
    "subnet-arn",
    "subnet-arn",
    "subnet-arn",
    "subnet-arn",
    "subnet-arn",
    "subnet-arn"
  ]
  sharing_dev_account_list = ["<account-number>", "<account-number>"]


  # vpc cidr for sg_comsrv_endpoint, which want to use vpc endpoints for session manager
  shared_dev_vpc_cidr     = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}<Account-name>/vpc_cidr"]
  shared_prd_vpc_cidr     = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}<Account-name>/vpc_cidr"]
  shared_uat_vpc_cidr     = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}<Account-name>/vpc_cidr"]
  network_vpc_cidr        = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}<Account-name>/vpc_cidr"]

 # Shared-Route 53 Settings
  private_r53_zone_name = "<zone-name>"
  private_network_range = ["<private_network_cidr>", "<private_network_cidr>"]
  onprem_private_network_range = [ "<private_onprem_cidr>", "<private_onprem_cidr>"]
  account_list = ["<Account-name>", "<Account-name>", "<Account-name>"]

  #----Account Number list contain shared and dev accounts number
  account_number_list = ["<Account-no>","<Account-no>","<Account-no>", "<Account-no>","<Account-no>"] 
  rslr_rule_name = "<rule-name>"
  rslr_onprem_rule_name = "<onprem_rule_name>"

  # DEV-Route 53 Settings
  private_r53_zone_name_dev = "<zone-name>"
  account_list_dev = ["<Account-name>", "<Account-name>"]

  # ssm.ap-south-1.amazonaws.com Endpoint route 53 setting
  private_r53_zone_ssm_endpoint = "<endpoint-service>"
  account_list_endpoint = ["<Account-name>", "<Account-name>", "<Account-name>"]
 
  primary_igw_name           = "<public_igw-name>"
  public_nat_rt_name         = "<name>"
  private_tgw_rt_name        = "<name>"
  private_fw_rt_name         = "<name>"
  tgw_attachment_name        = "<name>"

  appliance_mode_support     = "enable"
  tgw_default_rt_association = false
  tgw_default_rt_propagation = false

  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  common_tags = {
    key           = "value"
  }

  ssm_parameter_path              = "/mm/aft/account_customization/output/"
  ssm_parameter_path_org_id       = "/mm/static/master/org-id"
  ssm_parameter_path_account_list = "/mm/aft/account_id/"

  # export outputs of type string
  export_output = {
    vpc_id            = aws_vpc.shared_dev_vpc.id
    vpc_cidr          = aws_vpc.shared_dev_vpc.cidr_block
    tgw_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_network.id
  }
  # export outputs of type list
  export_list_output = {

  }
}
