provider "aws" {
  region  = us-east-1
  aws_access_key_id = "AKIAWNXXXJECEBULJNP4"
  aws_secret_access_key = "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"
}
resource "aws_instance" "myinstance" {
  ami = "ami-052ed3344670027b3"
  instance_type = "t2.micro"
  }
output "public_ip" {
  value = "aws_instance.myinstance.public_ip"
}