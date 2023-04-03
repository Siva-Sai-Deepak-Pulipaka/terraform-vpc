resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags, 

   { Name = "${var.env}-vpc"}
    
    )
}
# we are using merge function to combine tags in vars.tf and tags in terraform.tfvars 
