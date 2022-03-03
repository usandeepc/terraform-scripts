resource "aws_vpc_peering_connection" "vpc-1-2" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = aws_vpc.main-2.id
  vpc_id        = aws_vpc.main-1.id
  auto_accept   = true
}


resource "aws_route" "vpc-1-2" {
  route_table_id            = aws_vpc.main-1.main_route_table_id
  destination_cidr_block    = aws_vpc.main-2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-1-2.id
}

resource "aws_route" "vpc-2-1" {
  route_table_id            = aws_vpc.main-2.main_route_table_id
  destination_cidr_block    = aws_vpc.main-1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-1-2.id
}
