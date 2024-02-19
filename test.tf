resource "aws_vpc_security_group_ingress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = aws_vpc.myvpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_instance" "instance2" {
  ami           = "ami-0449c34f967dbf18a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.prisub.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name      = "terraform-awskeypair"
  
}  