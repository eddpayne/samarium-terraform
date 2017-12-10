resource "aws_key_pair" "adminkey1" {
  key_name   = "adminkey1"
  public_key = "${var.admin_ssh_key}"
}

resource "aws_instance" "puppypic1" {
  ami                = "ami-8fd760f6"
  instance_type      = "t2.micro"
  key_name           = "adminkey1"
  availability_zone  = "${data.aws_availability_zones.available.names[0]}"
  security_groups    = [ "${aws_security_group.puppypic-access.name}" ]
  root_block_device {
    volume_size = "30"
  }

  tags {
    Name = "puppypic1"
  }
 
  provisioner "file" {
    source      = "files/postinstall.sh"
    destination = "/tmp/postinstall.sh"
    connection {
      user      = "ubuntu"
    }
  }

  provisioner "remote-exec" {
    inline = [ "sudo /bin/bash /tmp/postinstall.sh",
               "sudo salt-call state.highstate" ]
    connection {
      user      = "ubuntu"
    }
  }
}

resource "aws_eip" "puppypic-ip" {
  instance = "${aws_instance.puppypic1.id}"
}

resource "aws_security_group" "puppypic-access" {
  name        = "puppypic-access"
  description = "Public and Admin access to the PuppyPic application"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.admin_networks}"
    description = "SSH access from admin networks"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Public HTTP access"
  }
 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Public HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

output "ip" {
  value = "${aws_eip.puppypic-ip.public_ip}"
}
