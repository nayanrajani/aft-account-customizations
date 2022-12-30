resource "aws_route53_zone_association" "ec2messages_private_r53_zone_association" {
  vpc_id  = aws_vpc.shared_dev_vpc.id
  zone_id = "<zone_id>"
}

#---------------------------------------------------------------------------------------------
#FOR MULTIPLE ZONE ASSOCIATION RUN BELOW TF INTO INDIVIDUAL ACCOUNT FILE

module "vpc_endpoint_info" {
  providers                    = { aws = aws.aft_management_account_admin }
  source                       = "../../modules/ssm_parameter_by_path/"
  ssm_parameter_path           = local.vpc_endpoint_ssm_parameter_path
  ssm_parameter_path_recursive = true
}



resource "aws_route53_zone_association" "name" {
  count          = length(local.names_of_asso_service)
  vpc_id         = aws_vpc.nameofvpc.id
  zone_id        = module.vpc_endpoint_info.param_name_values[join("", [local.vpc_endpoint_ssm_parameter_path, local.names_of_asso_service[count.index]])]
}