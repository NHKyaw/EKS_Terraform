resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true #For Further Req
  enable_dns_hostnames = true #For Further Req
  tags = {
    Name = "${local.env}-main"
  }
}