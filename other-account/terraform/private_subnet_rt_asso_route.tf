#-----------------------------------------------------------------------------------------------------------------
# Private subnet setup for transit gateway attachment
resource "aws_subnet" "private_tgw_subnet" {
  count             = length(local.private_tgw_subnet_list)
  vpc_id            = aws_vpc.shared_dev_vpc.id
  cidr_block        = local.private_tgw_subnet_list[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = merge(
    {
      Name = try(
        local.private_tgw_subnet_name[count.index],
        format("${local.primary_vpc_name}-private-tgw-%s", element(local.availability_zones, count.index))
      )
    },
    local.common_tags
  )
}

resource "aws_route_table" "private_tgw_rt" {
  vpc_id = aws_vpc.shared_dev_vpc.id
  tags = merge(
    {
      Name = local.private_tgw_rtb_name
    },
    local.common_tags
  )
}

resource "aws_route_table_association" "private_tgw_rt_assoc" {
  count          = length(local.private_tgw_subnet_list)
  subnet_id      = element(aws_subnet.private_tgw_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_tgw_rt.id
}

resource "aws_route" "private_tgw_subnet_egress" {
  route_table_id         = aws_route_table.private_tgw_rt.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.primary_network_tgw.id

  timeouts {
    create = "5m"
  }
}

#-----------------------------------------------------------------------------------------------------------------
