
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.tf_run_name}-vpc"
  }
}

resource "aws_subnet" "pvt-subnet-01" {
  cidr_block        = var.pvt-subnet-01-cidr
  availability_zone = "${var.region}a"
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name"                            = "${var.tf_run_name}-pvt-subnet-01"
    "kubernetes.io/role/internal-elb" = 1
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_subnet" "pvt-subnet-02" {
  cidr_block        = var.pvt-subnet-02-cidr
  availability_zone = "${var.region}b"
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name"                            = "${var.tf_run_name}-pvt-subnet-02"
    "kubernetes.io/role/internal-elb" = 1
  }
  depends_on = [
    aws_vpc.main,
  ]

}

resource "aws_subnet" "pvt-subnet-03" {
  cidr_block        = var.pvt-subnet-03-cidr
  availability_zone = "${var.region}c"
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name"                            = "${var.tf_run_name}-pvt-subnet-03"
    "kubernetes.io/role/internal-elb" = 1
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_subnet" "pub-subnet-01" {
  cidr_block        = var.pub-subnet-01-cidr
  availability_zone = "${var.region}a"
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name"                   = "${var.tf_run_name}-pub-subnet-01"
    "kubernetes.io/role/elb" = 1
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_subnet" "pub-subnet-02" {
  cidr_block        = var.pub-subnet-02-cidr
  availability_zone = "${var.region}b"
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name"                   = "${var.tf_run_name}-pub-subnet-02"
    "kubernetes.io/role/elb" = 1
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_subnet" "pub-subnet-03" {
  cidr_block        = var.pub-subnet-03-cidr
  availability_zone = "${var.region}c"
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name"                   = "${var.tf_run_name}-pub-subnet-03"
    "kubernetes.io/role/elb" = 1
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_eip" "natgw-eip" {

  tags = {
    "Name" = "${var.tf_run_name}-VPC-NATGW-eip"
  }

}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tf_run_name}-VPC-igw"
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw-eip.id
  subnet_id     = aws_subnet.pub-subnet-01.id

  tags = {
    Name = "${var.tf_run_name}-NAT-GW"
  }
  depends_on = [
    aws_vpc.main,
    aws_eip.natgw-eip,
  ]

}

resource "aws_route_table" "pvt_route_table-01" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tf_run_name}-Pvt-Route-Table-01"
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_route_table" "pub_route_table-01" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tf_run_name}-Pub-Route-Table-01"
  }
  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_route" "pvt-route-1" {
  route_table_id         = aws_route_table.pvt_route_table-01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
  depends_on             = [aws_route_table.pvt_route_table-01, aws_nat_gateway.natgw]
}

resource "aws_route" "pub-route-1" {
  route_table_id         = aws_route_table.pub_route_table-01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.pub_route_table-01, aws_internet_gateway.igw]
}

resource "aws_route_table_association" "pvt-rta-01" {
  subnet_id      = aws_subnet.pvt-subnet-01.id
  route_table_id = aws_route_table.pvt_route_table-01.id
  depends_on     = [aws_subnet.pvt-subnet-01, aws_route_table.pvt_route_table-01]
}

resource "aws_route_table_association" "pvt-rta-02" {
  subnet_id      = aws_subnet.pvt-subnet-02.id
  route_table_id = aws_route_table.pvt_route_table-01.id
  depends_on     = [aws_subnet.pvt-subnet-02, aws_route_table.pvt_route_table-01]
}

resource "aws_route_table_association" "pvt-rta-03" {
  subnet_id      = aws_subnet.pvt-subnet-03.id
  route_table_id = aws_route_table.pvt_route_table-01.id
  depends_on     = [aws_subnet.pvt-subnet-03, aws_route_table.pvt_route_table-01]
}

resource "aws_route_table_association" "pub-rta-01" {
  subnet_id      = aws_subnet.pub-subnet-01.id
  route_table_id = aws_route_table.pub_route_table-01.id
  depends_on     = [aws_subnet.pub-subnet-01, aws_route_table.pub_route_table-01]
}

resource "aws_route_table_association" "pub-rta-02" {
  subnet_id      = aws_subnet.pub-subnet-02.id
  route_table_id = aws_route_table.pub_route_table-01.id
  depends_on     = [aws_subnet.pub-subnet-01, aws_route_table.pub_route_table-01]
}

resource "aws_route_table_association" "pub-rta-03" {
  subnet_id      = aws_subnet.pub-subnet-03.id
  route_table_id = aws_route_table.pub_route_table-01.id
  depends_on     = [aws_subnet.pub-subnet-01, aws_route_table.pub_route_table-01]
}


resource "aws_security_group" "eks-cluster-sg" {
  name        = "${var.tf_run_name}-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.tf_run_name}-cluster-sg"
  }
  depends_on = [
    aws_vpc.main,
  ]
}



