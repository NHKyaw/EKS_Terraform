#Before Creating NAT_GW,Highly recommend to create EIP ahead.
resource "aws_eip" "for_nat" {
  domain = "vpc" #Indication this EIP is used in VPC

  tags = {
    Name = "${local.env}-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.for_nat.id
  subnet_id     = aws_subnet.public_zone1.id

  tags = {
    Name = "${local.env}-nat"
  }
  depends_on = [aws_internet_gateway.gw] #If no IGW,there is no NAT_GW
}
