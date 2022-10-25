#resource "aws_route" "vpc-peering-routes-on-prem" {
#  route_table_id         = data.aws_route_tables.vpc-route-table
##  destination_cidr_block = "172.31.0.0/24"
 # transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
#}