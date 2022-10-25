resource "aws_subnet" "tgw-attachment-subnet" {
  for_each   = toset(var.tgw_attachment_subnets_cidrs)
  vpc_id     = data.aviatrix_transit_gateway.avx-transit-gw.vpc_id
  cidr_block = each.value
  tags = {
    Name = "tgw-attachment-subnet"
  }
}

locals {
  tgw-attachment-subnet_list = [
    for subnets in aws_subnet.tgw-attachment-subnet : subnets.id
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-avx" {
  subnet_ids         = local.tgw-attachment-subnet_list
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.aviatrix_transit_gateway.avx-transit-gw.vpc_id
}

resource "aws_ec2_transit_gateway_connect" "tgw-connect-avx" {
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id
  transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-avx.id
}

resource "aws_route" "route-avx-tgw-cidr" {
  route_table_id         = data.aws_route_table.avx-tgw-route-table.route_table_id
  destination_cidr_block = element(var.transit_gateway_cidr_blocks, 0)
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_ec2_transit_gateway_connect_peer" "connect-avx-primary" {
  bgp_asn                       = data.aviatrix_transit_gateway.avx-transit-gw.local_as_number
  transit_gateway_address       = "10.10.0.1"
  peer_address                  = data.aviatrix_transit_gateway.avx-transit-gw.private_ip
  inside_cidr_blocks            = ["169.254.253.0/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.tgw-connect-avx.id
}

resource "aws_ec2_transit_gateway_connect_peer" "connect-avx-ha" {
  bgp_asn                       = data.aviatrix_transit_gateway.avx-transit-gw.local_as_number
  transit_gateway_address       = "10.10.0.2"
  peer_address                  = data.aviatrix_transit_gateway.avx-transit-gw.ha_private_ip
  inside_cidr_blocks            = ["169.254.254.0/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.tgw-connect-avx.id
}

resource "aviatrix_transit_external_device_conn" "avx-aws-connect" {
  vpc_id                   = data.aviatrix_transit_gateway.avx-transit-gw.vpc_id
  connection_name          = "avx-aws-connect"
  gw_name                  = data.aviatrix_transit_gateway.avx-transit-gw.gw_name
  connection_type          = "bgp"
  tunnel_protocol          = "GRE"
  bgp_local_as_num         = data.aviatrix_transit_gateway.avx-transit-gw.local_as_number
  bgp_remote_as_num        = var.amazon_side_asn
  remote_gateway_ip        = "10.10.0.1,10.10.0.2"
  direct_connect           = true
  ha_enabled               = false
  local_tunnel_cidr        = "169.254.251.1/29,169.254.252.1/29"
  remote_tunnel_cidr       = "169.254.251.2/29,169.254.252.2/29"
  enable_edge_segmentation = false
}