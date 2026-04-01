#vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-vpc"
  })
}
#vpc/

#subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-public-subnet-a"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-public-subnet-b"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-north-1a"
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-private-subnet-a"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-north-1b"
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-private-subnet-b"
  })
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "eu-north-1a"
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-db-subnet-a"
  })
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "eu-north-1b"
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-db-subnet-b"
  })
}
#subnets/

#internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-igw"
  })
}
#internet_gateway/