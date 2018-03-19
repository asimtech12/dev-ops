provider "aws" {
  region                   = "us-east-1"
  access_key = "xxxxxxxxxx"
  secret_key = "vvvvvvvvvvvvv"
}
# Create VPC 
resource "aws_vpc" "vpc_tutorial1" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = false
    enable_dns_hostnames = false
    tags = {
       Name = "TestVPC"
   }
}
# Create 1 public subnet in VPC
resource "aws_subnet" "public_subnet_us-east-1b" {
  vpc_id                  = "${aws_vpc.vpc_tutorial1.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
  	Name =  "Subnet az 1b"
  }
}
# Create 1/2 private subnet in VPC
resource "aws_subnet" "private_1_subnet_us-east-1b" {
  vpc_id                  = "${aws_vpc.vpc_tutorial1.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
  	Name =  "Subnet private 1 az 1b"
  }
}
# Create 2/2 private subnet in VPC
resource "aws_subnet" "private_2_subnet_us-east-1b" {
  vpc_id                  = "${aws_vpc.vpc_tutorial1.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
  	Name =  "Subnet private 2 az 1b"
  }
}
# Create InternetGateway 
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_tutorial1.id}"
  tags {
        Name = "InternetGateway"
    }
}
#Create route to the internet
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_tutorial1.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}
# Create Elastic IP (EIP)
resource "aws_eip" "tuto_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}
# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.tuto_eip.id}"
    subnet_id = "${aws_subnet.private_1_subnet_us-east-1b.id}"
    depends_on = ["aws_internet_gateway.gw"]
}
#Create private route table and the route to the internet 
#This will allow all traffics from the private subnets to the internet through the NAT Gateway (Network Address Translation) 
resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_tutorial1.id}"
 
    tags {
        Name = "Private route table"
    }
}

resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}
#Create Route Table Associations
#we will now associate our subnets to the different route tables
# Associate subnet public_subnet_us-east-1b to public route table
resource "aws_route_table_association" "public_subnet_us-east-1b_association" {
    subnet_id = "${aws_subnet.public_subnet_us-east-1b.id}"
    route_table_id = "${aws_vpc.vpc_tutorial1.main_route_table_id}"
}
 
# Associate subnet private_1_subnet_us-east-1b to private route table
resource "aws_route_table_association" "pr_1_subnet_us-east-1b_association" {
    subnet_id = "${aws_subnet.private_1_subnet_us-east-1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}
 
# Associate subnet private_2_subnet_us-east-1b to private route table
resource "aws_route_table_association" "pr_2_subnet_us-east-1b_association" {
    subnet_id = "${aws_subnet.private_2_subnet_us-east-1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}