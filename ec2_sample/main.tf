provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_instance" "terratest" {
  ami                    = "ami-0078a04747667d409"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-042a99c3d08a3e999"
  tags = {
    Name = "helloterra"
  }
}