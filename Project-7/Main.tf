# configuring network for Tenacity IT
resource "aws_vpc" "Prod_VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Prod_VPC"
  }
}

# creating public subnet
resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id            = aws_vpc.Prod_VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id            = aws_vpc.Prod_VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-pub-sub2"
  }
}

# creating public route table
resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.Prod_VPC.id

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# associate pubic subnet 1 to the route tables
resource "aws_route_table_association" "Prod_pub_subnet1_route_table_association" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# associate public subnet 2 to the route tables
resource "aws_route_table_association" "Prod_pub_subnet2_route_table_association" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# creating internet gateway
resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.Prod_VPC.id

  tags = {
    Name = "Prod-igw"
  }
}

# associating IGW to public route table
resource "aws_route" "Prod-igw-association" {
  gateway_id             = aws_internet_gateway.Prod-igw.id
  route_table_id         = aws_route_table.Prod-pub-route-table.id
  destination_cidr_block = "0.0.0.0/0"
}

# creating private subnet
resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id            = aws_vpc.Prod_VPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id            = aws_vpc.Prod_VPC.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-priv-sub2"
  }
}


# creating private route table
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.Prod_VPC.id

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# associate private subnet 1 to the route tables
resource "aws_route_table_association" "Prod_priv_subnet1_route_table_association" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

# associate private subnet 2 to the route tables
resource "aws_route_table_association" "Prod_priv_subnet2_route_table_association" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

# allocate elastic IP address 
resource "aws_eip" "eip_for_nat_gateway" {
  vpc      = true

    tags = {
    Name = "eip_for_nat_gateway"
  }
}

# creating NAT gateway
resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.eip_for_nat_gateway.id
  subnet_id     = aws_subnet.Prod-priv-sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
   }


# associating NAT gateway with private route table 
resource "aws_route" "Prod-Nat-association" {
  gateway_id             = aws_nat_gateway.Prod-Nat-gateway.id
  route_table_id         = aws_route_table.Prod-priv-route-table.id
  destination_cidr_block = "0.0.0.0/0"
}