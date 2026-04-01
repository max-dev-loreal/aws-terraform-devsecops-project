#nat-a
resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags = {
    Name    = "nat-eip-a"
    Project = local.project
  }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "nat-a"
    Project = local.project
  }
}
#nat-a/

#nat-b
resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags = {
    Name    = "nat-eip-b"
    Project = local.project
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name    = "nat-b"
    Project = local.project
  }
}
#nat-b/

#public_rt
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "public-rt"
    Project = local.project
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}
#public_rt/

#private_rt_a
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "private-rt-a"
    Project = local.project
  }
}

resource "aws_route" "private_route_a" {
  route_table_id         = aws_route_table.private_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt_a.id
}
#private_rt_a/

#private_rt_b
resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "private-rt-b"
    Project = local.project
  }
}

resource "aws_route" "private_route_b" {
  route_table_id         = aws_route_table.private_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt_b.id
}
#private_rt_b/

#vpc_endpoint_s3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_rt_a.id,
    aws_route_table.private_rt_b.id
  ]
}
#vpc_endpoint_s3/

#vpc_endpoint_secrets
resource "aws_vpc_endpoint" "secrets" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-north-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.private_sg.id
  ]
}
#vpc_endpoint_secrets/