# Provider configuration for AWS in the us-east-1 region
provider "aws" {
  region = "us-east-1"
}

# Create security groups for MEAN stack
resource "aws_security_group" "mean-sg" {
  name        = "mean-sg"
  description = "Security group for MEAN stack"
  vpc_id      = "xxxxxx"

  # Ingress rules for SSH and HTTP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # This ingress block allows incoming traffic on port 80 using TCP protocol from any IP address (0.0.0.0/0).
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for MongoDB
resource "aws_security_group" "mongodb-sg" {
  name        = "mongodb-sg"
  description = "Security group for MongoDB"
  vpc_id      = "xxxxxx"

  # Ingress rules for SSH and MongoDB
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # This ingress rule allows incoming traffic on port 27017 using TCP protocol from any IP address.
  # It is open to all IP addresses (0.0.0.0/0).
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for load balancer
resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Security group for load balancer"
  vpc_id      = "xxxxxx"

  # Ingress rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create network interface for MongoDB instance
resource "aws_network_interface" "mongodb_network_interface" {
  subnet_id       = "xxxxxx"
  private_ips     = ["172.31.16.15"]
  security_groups = [aws_security_group.mongodb-sg.id]
}

# Create MongoDB instance
resource "aws_instance" "mongodb_instance" {
  ami           = "xxxxxx"
  instance_type = "t2.micro"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mongodb_network_interface.id
  }

  key_name = "actividad2unir"

  tags = {
    Name = "mongodb"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./actividad2unir.pem")
    timeout     = "2m"
    host        = self.public_dns
  }

  provisioner "file" {
    source      = "./mongodb.sh"
    destination = "/tmp/mongodb.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "ls -la",
      "chmod +x /tmp/mongodb.sh",
      "/tmp/mongodb.sh",
    ]
  }
}

# Create 2 MEAN stack instances
resource "aws_instance" "mean_instance" {
  count                  = 2
  ami                    = "xxxxxx"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mean-sg.id]
  key_name               = "actividad2unir"

  tags = {
    Name = "nodejsapp-${count.index + 1}" }

  depends_on = [aws_instance.mongodb_instance]

}

# Create load balancer
resource "aws_lb" "lb" {
  name               = "mean-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = ["xxxxx", "xxxxx"]

  tags = {
    Name = "mean-lb"
  }
}

# Create target group for load balancer
resource "aws_lb_target_group" "app_target_group" {
  name     = "mean-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "xxxxxx"

  tags = {
    Name = "mean-app-target-group"
  }
}

# Attach instances to target group
resource "aws_lb_target_group_attachment" "mean_target_group_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.mean_instance[count.index].id
  port             = 80
}


# Create listener for load balancer
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    type             = "forward"
  }
}
