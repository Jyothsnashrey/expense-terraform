resource "aws_security_group" "main" {
  name        = "${local.name}-sg"
  description = "${local.name}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22                   #ssh port
    to_port     = 22
    protocol    = "tcp"            #ALL protocols
    cidr_blocks = var.bastion_cidrs
    description = "SSH"#public
  }

    ingress {
      from_port        = var.app_port                   #application port
      to_port          = var.app_port
      protocol         = "tcp"            #ALL protocols
      cidr_blocks      = var.sg_cidr_blocks
      description      = "APPPORT"#public



  }
  egress {   #outbound rulesa
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



resource "aws_launch_template" "main" {
  name_prefix   = "${local.name}-lt"
  image_id      = data.aws_ami.centos8.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    service_name = var.component
    env       = var.env
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }
}


resource "aws_autoscaling_group" "main" {
  name = "${local.name}-asg"
  desired_capacity    = var.instance_capacity
  max_size            = var.instance_capacity  # we shall fine tune after autoscaling
  min_size            = var.instance_capacity
  vpc_zone_identifier =  var.vpc_zone_identifier
  target_group_arns = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true  # for each instance you provide the tag.
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${local.name}-tg"
  port     = var.app_port      #if frontend 80 or 8080 for backend
  protocol = "HTTP"
  vpc_id   =  var.vpc_id


  health_check {
    path = "/health"
    healthy_threshold = 2 # how many times you want to check the health
    unhealthy_threshold = 2
    interval = 5  #frequency of time you want to check it will check very 5 secs id target is good or bad this will be more responsive
    timeout = 2 # timeout for health check
  }
}


resource "aws_iam_role" "main" {
  name               = "${local.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "parameter-store"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "GetParameter",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource": concat([
            "arn:aws:kms:us-east-1:046694289523:key/61697761-0640-4796-8fb9-1e709acec556",
            "arn:aws:ssm:us-east-1:046694289523:parameter/${var.env}.${var.project_name}.${var.component}.*"
          ],var.parameters) # by doing this we are concatinate 2 lists and backend will get an extra parameter while frontend will not have.
        },
        {
          "Sid": "DescribeAllParameters",
          "Effect": "Allow",
          "Action": "ssm:DescribeParameters",
          "Resource": "*"
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "main" {
  name = "${local.name}-role"
  role = aws_iam_role.main.name
}

