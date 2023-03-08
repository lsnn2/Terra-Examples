resource "aws_key_pair" "jenkins-key" {
  key_name   = "jenkinskey"
  public_key = file("id_rsa.pub")
}

resource "aws_instance" "jenkins-inst" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.jenkins-pub-1.id
  key_name               = aws_key_pair.jenkins-key.key_name
  vpc_security_group_ids = [aws_security_group.dove_stack_sg.id]
  tags = {
    Name    = "Jenkins-instance"
    Project = "Jenkins"
  }

  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/web.sh"
      , "sudo /tmp/web.sh"
    ]

  }

  connection {
    user        = var.USER
    private_key = file("id_rsa")
    host        = self.public_ip
  }
}
resource "aws_ebs_volume" "vol_4_dove" {
  availability_zone = var.ZONE1
  size              = 3
  tags = {
    Name = "extr-vol-4-dove"
  }
}
resource "aws_volume_attachment" "atch_vol_dove" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.vol_4_dove.id
  instance_id = aws_instance.jenkins-inst.id
}


output "PublicIP" {
  value = aws_instance.jenkins-inst.public_ip
}

output "PrivateIP" {
  value = aws_instance.jenkins-inst.private_ip
}