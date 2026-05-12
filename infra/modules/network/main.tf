resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.azs[0]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-subnet-a"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.azs[1]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-subnet-b"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.azs[0]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-subnet-a"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.azs[1]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-subnet-b"
  })
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidrs[0]
  availability_zone = var.azs[0]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnet-a"
  })
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidrs[1]
  availability_zone = var.azs[1]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnet-b"
  })
}

resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-nat-eip-a" })
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-nat-eip-b" })
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  tags          = merge(var.tags, { Name = "${var.name_prefix}-nat-a" })
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
  tags          = merge(var.tags, { Name = "${var.name_prefix}-nat-b" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-public-rt" })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-private-rt-a" })
}

resource "aws_route" "private_a_default" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-private-rt-b" })
}

resource "aws_route" "private_b_default" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id,
  ]
}

resource "aws_flow_log" "this" {
  vpc_id                   = aws_vpc.this.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpc_flow.arn
  iam_role_arn             = aws_iam_role.flow_logs.arn
  max_aggregation_interval = 60
}

resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/aws/vpc/${var.name_prefix}-flowlogs"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs" {
  name = "${var.name_prefix}-flowlogs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.name_prefix}-flowlogs-policy"
  role = aws_iam_role.flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"]
      Resource = "*"
    }]
  })
}
