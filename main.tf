terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}



resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "My-Vpc"
  }
}



resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "MY-VPC-PUB-SUB"
  }
}



resource "aws_subnet" "Prisub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "MY-VPC-PRI-SUB"
  }
}



resource "aws_internet_gateway" "tigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "MY-VPC-IGW"
  }
}



resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tigw.id
  }

  tags = {
    Name = "MY-VPC-PUB-RT"
  }
}



resource "aws_route_table_association" "pubrtasso" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}



resource "aws_eip" "myeip" {
  domain   = "vpc"
}



resource "aws_nat_gateway" "tnat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "MY-VPC-NAT"
  }
}




resource "aws_route_table" "prirt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tnat.id
  }

  tags = {
    Name = "MY-VPC-PRI-RT"
  }
}



resource "aws_route_table_association" "prirtasso" {
  subnet_id      = aws_subnet.Prisub.id
  route_table_id = aws_route_table.prirt.id
}



resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "MY-VPC-SG"
  }
}



resource "aws_vpc_security_group_ingress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = aws_vpc.myvpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 10000
}
 



resource "aws_instance" "jumpbox" {
  ami           = "ami-0449c34f967dbf18a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pubsub.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name      = "terraform-awskeypair"
  associate_public_ip_address = true
}  



