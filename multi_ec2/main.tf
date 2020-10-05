provider "aws" {
  region = "ap-northeast-2" 
}

resource "aws_key_pair" "ansible" {
  key_name = "ansible"
  public_key = file("./oooo.pub")
}

resource "aws_instance" "web" {
  associate_public_ip_address = "true"
  ami = "ami-0a93a08544874b3b7"
  instance_type = "t2.micro"
  key_name = aws_key_pair.oooo.key_name
  subnet_id = "subnet-01a485fe30c67204e"
  count = "${var.instance_count}"
  tags = {
      Name = "myweb-${count.index + 1}"
  }
}
