provider "aws" {
  region = "eu-north-1"
}

resource "aws_key_pair" "voluntree_key" {
  key_name   = "voluntree-key"
  public_key = file("voluntree-key.pub")  # Ensure this file exists
}

resource "aws_security_group" "allow_all" {
  name        = "voluntree-sg"
  description = "Allow all traffic for testing"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "voluntree_backend" {
  ami                         = "ami-04542995864e26699"  # Ubuntu 22.04
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.voluntree_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  tags = {
    Name = "voluntree-backend"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nodejs npm postgresql",
      "node -v",
      "npm -v",
      "psql --version"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("voluntree-key.pem")
      host        = self.public_ip
    }
  }
}
