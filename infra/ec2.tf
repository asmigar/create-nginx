resource "terraform_data" "my_ip" {
  triggers_replace = timestamp()

  provisioner "local-exec" {
    command = "curl -4 ifconfig.me > /tmp/my_ip.txt"
  }
}

data "local_file" "my-ip" {
  filename = "/tmp/my_ip.txt"
  depends_on = [terraform_data.my_ip]
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.local_file.my-ip.content}/32"]
  }

  ingress {
    description = "nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  tags = {
    Name = "allow_ssh_nginx"
  }

  depends_on = [terraform_data.my_ip]
}

resource "aws_security_group" "priv_instance" {
  name        = "allow_ssh_backend"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  tags = {
    Name = "allow_ssh_backend"
  }

}



resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.shh_key_name
  public_key = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_openssh}' > ~/.ssh/${var.shh_key_name}.pem; chmod 400 ~/.ssh/${self.key_name}.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ~/.ssh/${self.key_name}.pem"
  }
}

resource "aws_instance" "nginx" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"

  tags = {
    Name = "master"
  }

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.this.key_name
  user_data              = <<-EOT
		#!/bin/bash
		yum install nginx python -y
        systemctl start nginx
		EOT
}

resource "aws_instance" "backend" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"

  tags = {
    Name = "backend"
  }

  vpc_security_group_ids = [aws_security_group.priv_instance.id]
  subnet_id              = aws_subnet.private.id
  key_name               = aws_key_pair.this.key_name
#  user_data              = <<-EOT
#		#!/bin/bash
#		yum install nginx python -y
#        systemctl start nginx
#		EOT
}

