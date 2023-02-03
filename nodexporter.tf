terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "node-exporter" {

  ami                    = "ami-0ab0629dba5ae551d"
  instance_type          = "t2.micro"
  key_name               = "node_key"
  vpc_security_group_ids = ["sg-0e484e9078bf57be3"]
  subnet_id              = "subnet-0e0185734c018daee"

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    password = ""
    private_key = file("node_key.pem")
  }

  provisioner "file" {
    source = "node_exporter.sh"
    destination = "/tmp/node_exporter.sh"
  }

  user_data = <<EOF
  #! /bin/bash
  echo "Initializing node exporter installation......"
  sudo chmod +x /tmp/node_exporter.sh
  echo "Installing node exporter......."
  sudo /tmp/node_exporter.sh
EOF

  tags = {
  prometheus = "node-exporter"
  }
}