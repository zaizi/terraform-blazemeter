
provider "aws" {
    profile =  var.aws_profile
    region = var.aws_region
}


resource "aws_instance" "jmeter_master" {
 ami = var.ec2_ami
 instance_type = var.instance_type
 availability_zone = var.aws_az
 vpc_security_group_ids = [aws_security_group.jmeter.id]
 key_name = "my-key"

 

  provisioner "file" {
    source      = "userdata.sh"
    destination = "~/userdata.sh"
  }

  provisioner "file" {
    source      = "test.yaml"
    destination = "~/test.yaml"
  }

  provisioner "file" {
    source      = "test.jmx"
    destination = "~/test.jmx"
  }


  provisioner "file" {
    source      = "test1.yaml"
    destination = "~/test1.yaml"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x userdata.sh && ./userdata.sh",
    ]
  }


  connection {
    type = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host = aws_instance.jmeter_master.public_ip
  } 


  tags = {
    Name = "jmeter-master"
  }

}


resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = "${file("mykey.pub")}"
}


resource "aws_security_group" "jmeter" {
  name = "jmeter-master-sg"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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





#################outputs###############
output "instance_ip_addr" {
  value = aws_instance.jmeter_master.public_ip
}

output "DNS" {
  value = aws_instance.jmeter_master.public_dns
}
