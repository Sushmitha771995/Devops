resource "aws_s3_bucket" "storage" {
  bucket = "s3-terraform "
  key = "sample/teraform.tfstate"
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myinstance" {
  ami = "ami-052ed3344670027b3"
  instance_type = "t2.micro"
}