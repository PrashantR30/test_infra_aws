#### VPC Definition

resource "aws_vpc" "VPC" {
    cidr_block           = var.cidr_block   
    enable_dns_support   = true
    enable_dns_hostnames = true
  
    tags = {
        realm   = "Prashant-Test-Env"
    }
}


# IGW 
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    realm = "Prashant-Test-Env"
  }
}

# Elastic IP for Nat
resource "aws_eip" "NAT_EIP" {
  count = length(var.public_subnet_cidr_blocks)
  
  vpc = true
  # depends_on = [ aws_internet_gateway[count.index].IGW ]
}


# NAT
resource "aws_nat_gateway" "NAT" {
  count = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.NAT_EIP[count.index].id
  subnet_id     = aws_subnet.Public_Subnets[count.index].id
}



# Public Subnets
resource "aws_subnet" "Public_Subnets" {
    count = length(var.public_subnet_cidr_blocks)

    vpc_id                  = aws_vpc.VPC.id
    cidr_block              = var.public_subnet_cidr_blocks[count.index]
    availability_zone       = var.availability_zones[count.index]
    map_public_ip_on_launch = true
    tags = {
        realm   = "Prashant-Test-Env"
    }
}


# Private Subnets 
resource "aws_subnet" "Private_Subnets" {
    count = length(var.public_subnet_cidr_blocks)

    vpc_id                  = aws_vpc.VPC.id
    cidr_block              = var.private_subnet_cidr_blocks[count.index]
    availability_zone       = var.availability_zones[count.index] # add overide (if not defined then take all)
    map_public_ip_on_launch = false
    tags = {
        realm   = "Prashant-Test-Env"
    }
}

# Routing Table for Public Subnets
resource "aws_route_table" "Public_Route_table" {
  vpc_id = aws_vpc.VPC.id
}

# Routing Table for Private Subnets
resource "aws_route_table" "Private_Route_table" {
  vpc_id = aws_vpc.VPC.id
}


resource "aws_route" "Public_Internet_Gateway" {
  count = length(var.public_subnet_cidr_blocks)

  route_table_id         = aws_route_table.Public_Route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW.id

}

resource "aws_route" "Private_Internet_Gateway" {
  count = length(var.public_subnet_cidr_blocks)

  route_table_id         = aws_route_table.Private_Route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NAT[count.index].id
}


# Public Route Association
resource "aws_route_table_association" "Public_Route_table_Association" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.Public_Subnets[count.index].id
  route_table_id = aws_route_table.Public_Route_table.id
}

# Private Route Association
resource "aws_route_table_association" "Private_Route_table_Association" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.Private_Subnets[count.index].id
  route_table_id = aws_route_table.Private_Route_table.id
}


