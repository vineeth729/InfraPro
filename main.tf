provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "dev_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "dev_sg" {
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "deployer" {
  key_name   = "royal_hotel_key"
  public_key = file("~/.ssh/royal_hotel_key.pub")
}

resource "aws_instance" "dev_vm" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.dev_subnet.id
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.dev_sg.name]

  tags = {
    Name = "RoyalHotel-DevVM"
  }
}

output "public_ip" {
  value = aws_instance.dev_vm.public_ip
}
