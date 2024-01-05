
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "ap-northeast-1"
}

resource "aws_vpc" "v6-vpc" {
  assign_generated_ipv6_cidr_block = true
  tags = {
    "Name" = "v6-vpc"
  }
}

resource "aws_subnet" "v6-sub" {
  vpc_id = "${aws_vpc.v6-vpc.id}"
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block = cidrsubnet(aws_vpc.v6-vpc.ipv6_cidr_block, 4, 0)
  ipv6_native = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  tags = {
    "Name" = "v6-sub"
  }
}

resource "aws_internet_gateway" "v6-igw" {
  vpc_id = "${aws_vpc.v6-vpc.id}"
  tags = {
    "Name" = "v6-igw"
  }
}

resource "aws_route_table" "v6-route" {
  vpc_id = "${aws_vpc.v6-vpc.id}"

  tags = {
    Name = "v6-route"
  }
}

resource "aws_route" "v6-route-to-public-igw" {
  destination_ipv6_cidr_block = "::/0"
  route_table_id         = "${aws_route_table.v6-route.id}"
  gateway_id             = "${aws_internet_gateway.v6-igw.id}"
}

resource "aws_route_table_association" "v6-association" {
  subnet_id      = aws_subnet.v6-sub.id
  route_table_id = aws_route_table.v6-route.id
}

resource "aws_security_group" "v6-sg" {
  description = "v6-sg"
  egress = [
    {
      cidr_blocks = ["0.0.0.0/0",]
      description = ""
      from_port = 0
      ipv6_cidr_blocks = ["::/0",]
      prefix_list_ids = []
      protocol = "-1"
      security_groups = []
      self = false
      to_port = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = []
      description = ""
      from_port = 22
      ipv6_cidr_blocks = ["::/0",]
      prefix_list_ids = []
      protocol = "tcp"
      security_groups = []
      self = false
      to_port = 22
    },
    {
      cidr_blocks = []
      description = ""
      from_port = 8080
      ipv6_cidr_blocks = ["::/0",]
      prefix_list_ids = []
      protocol = "tcp"
      security_groups = []
      self = false
      to_port = 8080
    },
  ]
}

resource "aws_instance" "v6-ec2" {
  ami                     = "ami-0dfa284c9d7b2adad"
  instance_type           = "t3.nano"
  disable_api_termination = false
  key_name                = "v6"
  vpc_security_group_ids  = [aws_security_group.v6-sg.id]
  subnet_id               = aws_subnet.v6-sub.id
  tags = {
    Name = "v6-ec2"
  }
}

