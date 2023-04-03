resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags, 

   { Name = "${var.env}-vpc"}
    
    )
}
# we are using merge function to combine tags in vars.tf and tags in terraform.tfvars 

# Peering
resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id   = data.aws_caller_identity.account.account_id
  peer_vpc_id     = var.default_vpc_id
  vpc_id          = aws_vpc.main.id
  auto_accept     = true       #it is my account so im giving approval to accept request
  tags = merge(
    var.tags,
    { Name = "${var.env}-peer" }
  )
}

# internet gateway
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

