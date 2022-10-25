#resource "aviatrix_spoke_transit_attachment" "spoke_attachment" {
#  for_each = var.vpcs
#  spoke_gw_name   = each.value.vpc_name
#  transit_gw_name = data.aviatrix_transit_gateway.avx-transit-gw.gw_name
#}