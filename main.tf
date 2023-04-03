resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags, 

   { Name = "${var.env}-vpc"}
    
    )
}
# we are using merge function to combine tags in vars.tf and tags in terraform.tfvars 
# public route table

# public subnets
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main.id

  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
  
}

# private subnets
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.main.id

  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
  
}
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

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
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id

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