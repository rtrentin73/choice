# Lookup requestor VPC so that we can reference the CIDR
data "aws_vpc" "requestor" {
    for_each = var.vpcs
  id    = each.value.key_name
}

# Lookup acceptor VPC so that we can reference the CIDR
data "aws_vpc" "acceptor" {
    for_each = var.vpcs
 id    = each.value.key_name
}

data "aws_route_tables" "requestor" {
  vpc_id = join("", data.aws_vpc.requestor.*.id)
}

data "aws_route_tables" "acceptor" {
  vpc_id = join("", data.aws_vpc.acceptor.*.id)
}

# Create routes from requestor to acceptor
resource "aws_route" "requestor" {
  count                     = length(distinct(sort(data.aws_route_tables.requestor.0.ids))) * length(data.aws_vpc.acceptor.0.cidr_block_associations)
  route_table_id            = element(distinct(sort(data.aws_route_tables.requestor.0.ids)), ceil(count.index / length(data.aws_vpc.acceptor.0.cidr_block_associations)))
  destination_cidr_block    = data.aws_vpc.acceptor.0.cidr_block_associations[count.index % length(data.aws_vpc.acceptor.0.cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = join("", aws_vpc_peering_connection.default.*.id)
  depends_on                = [data.aws_route_tables.requestor, aws_vpc_peering_connection.default]
}

# Create routes from acceptor to requestor
resource "aws_route" "acceptor" {
  count                     = length(distinct(sort(data.aws_route_tables.acceptor.0.ids))) * length(data.aws_vpc.requestor.0.cidr_block_associations)
  route_table_id            = element(distinct(sort(data.aws_route_tables.acceptor.0.ids)), ceil(count.index / length(data.aws_vpc.requestor.0.cidr_block_associations)))
  destination_cidr_block    = data.aws_vpc.requestor.0.cidr_block_associations[count.index % length(data.aws_vpc.requestor.0.cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = join("", aws_vpc_peering_connection.default.*.id)
  depends_on                = [data.aws_route_tables.acceptor, aws_vpc_peering_connection.default]
}