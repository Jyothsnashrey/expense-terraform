resource "aws_security_group" "main" {
  name        = "${local.name}-alb-sg"
  description = "${local.name}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"            #ALL protocols
    cidr_blocks = var.sg_cidr_blocks
    description = "SSH"#public
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"            #ALL protocols
    cidr_blocks = var.sg_cidr_blocks
    description = "HTTPS"#public
  }

  egress {   #outbound rules
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name}-sg"
  }
}

resource "aws_lb" "main" {
  name               = local.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.subnets

  tags = {
   Name =  local.name
  }
}


