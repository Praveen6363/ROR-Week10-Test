provider "aws" {
  region = "us-east-2"
  secret_key = "4UR1tOW8LxZkUJbXEd4vEfemKFeN5C1h4Ku3d13t"
  access_key = "AKIA377XDWIH6YP3JKJJ"
}



resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "14.9"
  instance_class       = "db.t3.micro"
  db_name              = "postgres"
  username             = "postgres"
  password             = "03050305"
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
}


resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_internet_gateway" "example"{
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "ex-ig"
  }
}

resource "aws_route_table" "public"{
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}


resource "aws_route_table_association" "example"{
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
  
  
}

resource "aws_autoscaling_group" "example" {
  name = "example-asg"
  launch_configuration = aws_launch_configuration.example.name
   min_size = 2
  max_size = 5
  desired_capacity = 2
  vpc_zone_identifier = [aws_subnet.public.id]
}

resource "aws_launch_configuration" "example" {
  name = "example-launch-config"
  image_id = "ami-0e83be366243f524a"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.example.id]
  associate_public_ip_address = true
}



resource "aws_security_group" "example" {
  name_prefix = "example-sg"
  description = "week10"
  vpc_id = aws_vpc.example.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

resource "aws_lb" "ror"{
  name = "ror-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.example.id]
  subnets = [aws_subnet.public.id,aws_subnet.private.id]
  enable_http2 = true
}

resource "aws_lb_target_group" "example" {
  name_prefix = "tg-ex"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.example.id
}

resource "aws_lb_listener" "example"{
  load_balancer_arn = aws_lb.ror.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code = "200"
      }
  }
}


}


