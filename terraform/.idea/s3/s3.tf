  terraform {
    backend "s3" {
      bucket = "my-bucket-6754"
      key    = "statesample/terraform.tf"
      region = "us-east-1"
    }
  }

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myinstance" {
  ami = "ami-052ed3344670027b3"
 instance_type = "t2.micro"
}