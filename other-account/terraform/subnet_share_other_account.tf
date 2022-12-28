#-----------------------------------------------------------------------------------------------------
# Share subnet with  Account
resource "aws_ram_resource_share" "shared_dev_subnet_sharing" {
  name                      = "ram_shared_dev_subnet_sharing_mum_01"
  allow_external_principals = false
  tags                      = local.common_tags
}
resource "aws_ram_resource_association" "shared_dev_subnet_assoc" {
  count              = length(local.shared_subnet_list)
  resource_arn       = local.shared_subnet_list[count.index]
  resource_share_arn = aws_ram_resource_share.shared_dev_subnet_sharing.arn
}


resource "aws_ram_principal_association" "sharing_dev_principal" {
  count              = length(local.sharing_dev_account_list)
  principal          = local.sharing_dev_account_list[count.index]
  resource_share_arn = aws_ram_resource_share.shared_dev_subnet_sharing.arn
}
