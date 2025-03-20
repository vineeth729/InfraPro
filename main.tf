provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "royal_hotel_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "royal_hotel_subnet" {
  vpc_id            = vpc-06efda823a60a4e19
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "royal_hotel_sg" {
  vpc_id = vpc-06efda823a60a4e19

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "royal_hotel_key" {
  key_name   = "royal_hotel_key"
  public_key = file("~/.ssh/royal_hotel_key.pub")
}

resource "aws_instance" "developer_vm" {
  ami             = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04
  instance_type   = "t2.micro"
  subnet_id       = subnet-02146eda123716248
  security_groups = [sg-0c014604c15773030]
  key_name        = aws_key_pair.royal_hotel_key.key_name

  tags = {
    Name = "DeveloperVM"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Waiting for SSH to be ready'"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/royal_hotel_key")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory"
  }
}

output "developer_vm_ip" {
  value = aws_instance.developer_vm.public_ip
}
