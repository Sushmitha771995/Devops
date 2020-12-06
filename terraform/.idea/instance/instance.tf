resource "aws_instance" "myinstance" {
  ami = "ami-052ed3344670027b3"
  instance_type = "t2.micro"
  }
output "public_ip" {
  value = "aws_instance.myinstance.public_ip"
}