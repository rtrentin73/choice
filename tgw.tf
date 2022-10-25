resource "aws_ec2_transit_gateway" "tgw" {
  amazon_side_asn             = var.amazon_side_asn
  transit_gateway_cidr_blocks = var.transit_gateway_cidr_blocks
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment" {
  for_each = var.vpcs
  subnet_ids = [
    element(module.vpc[each.value.vpc_name].private_subnets, 0),
    element(module.vpc[each.value.vpc_name].private_subnets, 1)
  ]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc[each.value.vpc_name].vpc_id
}