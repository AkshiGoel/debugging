provider "aws" {
   region  = "ap-south-1"
   profile ="myakshiprof"
}

resource "aws-instance" "akshiinstance" {
ami="ami-07a8c73a650069cf3"
instance_type="t2.micro"
key_name="teraKey"
secutiry_groups=["launch-wizard-1"]


 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/lk/Desktop/teraKey.pem")
    host     = aws_instance.akshiinstance.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

tags={
Name="terraOS"
}
}

output  "myoutaz" {
	value = aws_instance.akshiinstance.availability_zone
}

output  "my_public_ip" {
	value = aws_instance.akshiinstance.public_ip
}


resource "aws_ebs_volume" "akshiebs" {
  availability_zone = aws_instance.akshiinstance.availability_zone
  size              = 1
  tags = {
    Name = "terraEBS"
  }
}

resource "aws_volume_attachment" "akshiebsattach" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.akshiebs.id}"
  instance_id = "${aws_instance.akshiinstance.id}"
  force_detach = true
}

output "myos_ip" {
  value = aws_instance.akshiinstance.public_ip
}


resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.akshiinstance.public_ip} > publicip.txt"
  	}
}


resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.akshiebsattach,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/lk/Desktop/teraKey.pem")
    host     = aws_instance.akshiinstance.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/AkshiGoel/forTerra.git /var/www/html/"
    ]
  }
}


resource "aws_s3_bucket" "akshis3" {
  bucket = "terraBucket"
  acl    = "public-read"
  source = "https://github.com/AkshiGoel/forTerra/tree/master/screenshots/"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}