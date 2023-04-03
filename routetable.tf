# public route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = aws_internet_gateway.example.id
#   }

  for_each = var.public_subnets
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

# Public route table association
resource "aws_route_table_association" "public-association" {
  for_each = var.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.value["name"]].id
# subnet_id      = lookup(lookup(aws_subnet.public_subnets, each.value["name"], null), "id", null)     #this is also we can use to get subnet_id
  route_table_id = aws_route_table.public-route-table[each.value["name"]].id
}

# private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = aws_internet_gateway.example.id
#   }

  for_each = var.private_subnets
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

# Private route table association
resource "aws_route_table_association" "private-association" {
  for_each = var.private_subnets
  subnet_id      = aws_subnet.private_subnets[each.value["name"]].id
# subnet_id      = lookup(lookup(aws_subnet.private_subnets, each.value["name"], null), "id", null)     #this is also we can use to get subnet_id
  route_table_id = aws_route_table.private-route-table[each.value["name"]].id
}