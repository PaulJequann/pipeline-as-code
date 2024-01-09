resource "aws_eip" "nat_eip" {
  domain = "vpc"

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name   = "nat_eip_${var.project_name}"
    Author = var.author
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name   = "nat_gateway_${var.project_name}"
    Author = var.author
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name   = "private_rt_${var.project_name}"
    Author = var.author
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = var.private_subnet_count
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}