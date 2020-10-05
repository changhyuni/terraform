provider "aws" {
  region = "ap-northeast-2" 
}

resource "aws_instance" "web" {
  ami = "ami-0a93a08544874b3b7"
  instance_type = "t2.micro"
  key_name = "changman.pem"
  count = "${var.instance_count}"
  tags = {
      Name = "myweb-${count.index + 1}"
  }
}
