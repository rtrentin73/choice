resource "aviatrix_spoke_gateway" "spoke_gateway" {
  for_each                          = var.vpcs
  cloud_type                        = 1
  account_name                      = var.account
  gw_name                           = each.value.vpc_name
  vpc_id                            = module.vpc[each.value.vpc_name].vpc_id
  vpc_reg                           = data.aws_region.aws_region-current.name
  gw_size                           = var.gw_size
  ha_gw_size                        = var.gw_size
  subnet                            = element(slice(cidrsubnets(each.value.vpc_cidr, 4, 4, 4, 4, 4, 4), 4, 5), 0)
  single_ip_snat                    = false
  manage_transit_gateway_attachment = false
  ha_subnet                         = element(slice(cidrsubnets(each.value.vpc_cidr, 4, 4, 4, 4, 4, 4), 5, 6), 0)
}