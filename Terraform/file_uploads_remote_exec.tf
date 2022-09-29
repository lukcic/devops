resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "example" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name

  provisioner "file" { # must be inside instance resource
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /opt/script.sh",
      "sudo /tmp/script.sh"
    ]
  }

  connection { # optional
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"                 # https://github.com/wardviaene/terraform-course/blob/master/demo-2b/windows-instance.tf
    user = var.INSTANCE_USERNAME # password is used in Windows instances (course lecture 17)
    # password = "${var.instance_password"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
}