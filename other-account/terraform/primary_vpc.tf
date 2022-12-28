resource "aws_vpc" "shared_dev_vpc" {
  cidr_block = local.primary_vpc_cidr

  instance_tenancy                 = local.instance_tenancy
  enable_dns_hostnames             = local.enable_dns_hostnames
  enable_dns_support               = local.enable_dns_support
  assign_generated_ipv6_cidr_block = local.assign_generated_ipv6_cidr_block

  tags = merge(
    { "Name" = "${local.primary_vpc_name}",
      "flowlog" = "enable"
    },
    local.common_tags
  )
}

# Public subnet setup
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.shared_dev_vpc.id

  tags = merge(
    { "Name" = "${local.primary_igw_name}" },
    local.common_tags
  )
}


resource "aws_subnet" "public_alb_subnet" {
  count             = length(local.public_alb_subnet_list)
  vpc_id            = aws_vpc.shared_dev_vpc.id
  cidr_block        = local.public_alb_subnet_list[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = merge(
    {
      Name = try(
        local.public_alb_subnet_name[count.index],
        format("${local.primary_vpc_name}-public-alb-%s", element(local.availability_zones, count.index))
      )
    },
    local.common_tags
  )
}


resource "aws_route_table" "public_alb_rt" {
  vpc_id = aws_vpc.shared_dev_vpc.id
  tags = merge(
    {
      Name = local.public_alb_rtb_name
    },
    local.common_tags
  )
}

resource "aws_route_table_association" "public_alb_rt_assoc" {
  count          = length(local.public_alb_subnet_list)
  subnet_id      = element(aws_subnet.public_alb_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_alb_rt.id
}

resource "aws_route" "public_web_routes" {
  route_table_id         = aws_route_table.public_alb_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  timeouts {
    create = "5m"
  }
}

