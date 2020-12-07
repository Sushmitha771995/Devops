terraform {
 backend "s3" {}
  bucket = "s3-terraform"
  key = "sample/terraform.tfstate"
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myinstance" {
  ami = "ami-052ed3344670027b3"
  instance_type = "t2.micro"
}