resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags, 

   { Name = "${var.env}-vpc"}
    
    )
}
# we are using merge function to combine tags in vars.tf and tags in terraform.tfvars 

# internet gateway
# As we already know that internet gateway is for public subnets only
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    { Name = "${var.env}-igw" }
  )
}
# Elastic ip creation for NAT purpose
resource "aws_eip" "nat" {
  for_each = var.public_subnets
  vpc      = true
}
# NAT gateway
resource "aws_nat_gateway" "nat-gateways" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.nat[each.value["name"]].id
  subnet_id     = aws_subnet.public_subnets[each.value["name"]].id

  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )


}

