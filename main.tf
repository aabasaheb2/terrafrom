provider "aws" {
  region = "us-west-2"  # Set the AWS region to us-west-2
}

# Security Group allowing SSH (port 22), HTTP (port 80), and HTTPS (port 443)
resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP, HTTPS, and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (can be restricted to your IP)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# EC2 Instance to host the Hello World HTML page
resource "aws_instance" "hello_world" {
  ami           = "ami-027951e78de46a00e"  # Use Amazon Linux 2 AMI for us-west-2
  instance_type = "t2.micro"                # Free tier eligible instance type
  security_groups = [aws_security_group.allow_http_ssh.name]
    tags = {
    Name = "HelloWorldInstance"
  }

  # User data to set up Apache HTTP server and serve a Hello World page
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              echo "Hello World!" > /var/www/html/index.html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "HTTP server started successfully!" >> /var/log/user_data.log
              EOF

  # Optionally, you can add a provisioner to wait for HTTP server startup
}

# Output the public IP of the EC2 instance
output "instance_ip" {
  value = aws_instance.hello_world.public_ip
}
