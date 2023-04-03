# public route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id       #internet gateway is present in main.tf
  }
  
  route {
    cidr_block = data.aws_vpc.default-vpc.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id      #this route is for default vpc
  }

  for_each          = var.public_subnets
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

# Public route table association
resource "aws_route_table_association" "public-association" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.value["name"]].id
# subnet_id      = lookup(lookup(aws_subnet.public_subnets, each.value["name"], null), "id", null)     #this is also we can use to get subnet_id
  route_table_id = aws_route_table.public-route-table[each.value["name"]].id
}

# private route table
resource "aws_route_table" "private-route-table" {
  vpc_id        = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateways["public-${split("-", each.value["name"])[1]}"].id       #we want to refer map values (public-az1, public-az2) so we are using split function to find common one ie, public
  }

  route {
    cidr_block = data.aws_vpc.default-vpc.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  for_each      = var.private_subnets
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

# Private route table association
resource "aws_route_table_association" "private-association" {
  for_each       = var.private_subnets
  # subnet_id    = aws_subnet.private_subnets[each.value["name"]].id
 subnet_id       = lookup(lookup(aws_subnet.private_subnets, each.value["name"], null), "id", null)     #this is also we can use to get subnet_id
  route_table_id = aws_route_table.private-route-table[each.value["name"]].id
}

# route to the default vpc in order to work peering
resource "aws_route" "route" {
  route_table_id = var.default_route_table
  destination_cidr_block = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}