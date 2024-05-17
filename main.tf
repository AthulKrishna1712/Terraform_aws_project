resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr-block
}

resource "aws_subnet" "sub_1" {
  vpc_id                  = aws_vpc.myvpc.id
  availability_zone       = var.availability-zone
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub_2" {
  vpc_id                  = aws_vpc.myvpc.id
  availability_zone       = var.availability-zone
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub_1
  route_table_id = aws_route_table.rt
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub_1.id
  route_table_id = aws_route_table.rt
}

resource "aws_security_group" "sg" {
  name_prefix = "web-sg"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

resource "aws_s3_bucket" "my_s3" {
  bucket = "athulterraform2024"
}


resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.my_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access" {
  bucket = aws_s3_bucket.my_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_public_access,
  ]

  bucket = aws_s3_bucket.my_s3.id
  acl    = "public-read"
}

# module "ec2_instances" {
#   source = "terraform-aws-modules/ec2-instance/aws"

#   for_each = {
#     "webserver1" = aws_subnet.sub_1,
#     "webserver2" = aws_subnet.sub_2
#   }

#   name                   = "instance-${each.key}"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.web_sg.vpc_id]
#   subnet_id              = each.value
#   ami                    = "ami-0f58b397bc5c1f2e8"
# }

resource "aws_instance" "webserver1" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.vpc_id]
  subnet_id              = aws_subnet.sub_1.id
  user_data              = base64decode(file("userdata1.sh"))

  tags = {
    Name = "webserver1"
  }
}

resource "aws_instance" "webserver2" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.vpc_id]
  subnet_id              = aws_subnet.sub_2.id
  user_data              = base64decode(file("userdata2.sh"))

  tags = {
    Name = "webserver2"
  }
}

resource "aws_lb" "alb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.sub_1, aws_subnet.sub_2]

  tags = {
    Name = "My_alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "mytargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tg_attach1" {
  target_group_arn = aws_lb_target_group.tg.id
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attach2" {
  target_group_arn = aws_lb_target_group.tg.id
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.id
  port              = 80
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "loadbalancerdns" {
  value = aws_lb.alb.dns_name
}