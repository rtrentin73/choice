locals {
  list_of_vpcs = [
    for x in var.vpcs : x.vpc_cidr
  ]

  connections = flatten([
    for vpc in local.list_of_vpcs : [
      for peer_vpc in slice(local.list_of_vpcs, index(local.list_of_vpcs, vpc) + 1, length(local.list_of_vpcs)) : {
        vpc1 = vpc
        vpc2 = peer_vpc
      }
    ]
  ])

  connections_map = {
    for connection in local.connections : "${connection.vpc1}:${connection.vpc2}" => connection
  }
}

data "aws_vpc" "list_of_vpcs" {
  for_each   = toset(local.list_of_vpcs)
  cidr_block = each.value
  depends_on = [module.vpc]
}

resource "aws_vpc_peering_connection" "peering" {
  for_each    = local.connections_map
  peer_vpc_id = data.aws_vpc.list_of_vpcs[each.value.vpc1].id
  vpc_id      = data.aws_vpc.list_of_vpcs[each.value.vpc2].id
  auto_accept = true
}