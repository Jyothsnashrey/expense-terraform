resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-${var.project_name}-vpc"
  }
}
resource    "aws_subnet" "main" {
  count      = length(var.subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.subnets_cidr, count.index )
  availability_zone = element(var.az, count.index)  #this created the subnets in the required zones.

  tags = {
    Name = "subnet-${count.index}"
  }
}

resource "aws_vpc_peering_connection" "main" {
  vpc_id       = aws_vpc.main.id
  peer_vpc_id  = data.aws_vpc.default.id
  auto_accept =  true
  tags = {
    name = "${var.env}-vpc-with-default-vpc"
  }
}

resource "aws_route" "main" {
  route_table_id            = aws_vpc.main.main_route_table_id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
resource "aws_route" "default-vpc" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

data "aws_ami" "example" {
  most_recent = true
  name_regex = "centos-8-DevOps-practice"
  owners = ["973714476881"]
}
resource "aws_security_group" "test" {
  name        = "test"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 0                     #allports
    to_port          = 0
    protocol         = "-1"             #ALL protocols
    cidr_blocks      = ["0.0.0.0/0"]            #public
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
    Name = "allow_tls"
  }
}


resource "aws_instance" "test"{
        ami           = data.aws_ami.example.image_id
        instance_type = "t3.micro"
        subnet_id     = aws_subnet.main[0].id
        vpc_security_groups_ids = [aws_security_group.test.id]
}

