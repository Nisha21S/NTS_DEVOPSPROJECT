#VPC
resource "aws_vpc" "nishamain" {
  cidr_block       = "172.31.12.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "VPC-nisha"
    Purpose = "terrafrom using Jenkins"
  }
}

#SUBNET_Public
resource "aws_subnet" "Subnet_Public" {
  vpc_id = aws_vpc.nishamain.id
  cidr_block = "172.31.12.0/25"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch ="true"
  tags = {
    "Name" = "Nisha_Public_subnet1"
    "Owner" = "Nisha"
    "Purpose" = "devops_project"
  }
}


# # SUBNET_Private
# resource "aws_subnet" "Subnet_Private" {
#   vpc_id = aws_vpc.nishamain.id
#   cidr_block = "172.31.12.128/25"
#   availability_zone = "ap-south-1a"
#   tags = {
#     "Name" = "Nisha_Private_subnet1"
#     "Owner" = "Nisha"
#     "Purpose" = "devops_project"
#   }
# }

# INTERNET GATEWAY FOR VPC  
resource "aws_internet_gateway" "Nisha-IGW1" {
  vpc_id = aws_vpc.nishamain.id
  tags = {
    "Name" = "NISHAIGW"
    "Owner" = "Nisha"
    "Purpose" = "devops_project"
  } 
}


#routetable public

resource "aws_route_table" "Nisha-Route_Public" {
  vpc_id = aws_vpc.nishamain.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Nisha-IGW1.id
  }
  tags = {
    "Name" = "Nisha route public"
    "Owner" = "Nisha"
    "Purpose" = "devops_project"
  }
}

# ROUTE TABLE ASSOCIATION WITH SUBNET CREATED

resource "aws_route_table_association" "nisha_public" {
  subnet_id = aws_subnet.Subnet_Public.id
  route_table_id = aws_route_table.Nisha-Route_Public.id
}

resource "aws_route" "route_publicNS" {

  route_table_id              = aws_route_table.Nisha-Route_Public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.Nisha-IGW1.id

}



# #route table private
# resource "aws_route_table" "Nisha-Route_Private" {
#   vpc_id = aws_vpc.nishamain.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.Nisha-IGW1.id
#   }
#   tags = {
#     "Name" = "Nisha route private"
#     "Owner" = "Nisha"
#     "Purpose" = "devops_project"
#   }
# }



# resource "aws_route_table_association" "nisha_private" {
#   subnet_id = aws_subnet.Subnet_Private.id
#   route_table_id = aws_route_table.Nisha-Route_Private.id
# }

# CREATING SECURITY GROUP TO ALLOW PORT 22,80,443
resource "aws_security_group" "Nisha-SG" {
  name = "Nisha-SG-WebTraffic"
  description = "For allowing inbound web traffic"
  vpc_id = aws_vpc.nishamain.id
  tags = {
    "Name" = "Nisha-SG"
    "Owner" = "Nisha" 
    "Purpose" = "devops_project"
  }
  ingress  {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# EC2 SPOT INSTANCE 
resource "aws_spot_instance_request" "nisha_spot1" {
  ami                    = "ami-079b5e5b3971bd10d"
  # security_groups = aws_security_group.Nisha-SG.id
  spot_price             = "0.016"
  instance_type          = "t2.micro"
  spot_type              = "one-time"
  wait_for_fulfillment   = "true"
  key_name               = "nishaskey"
  security_groups = ["${aws_security_group.Nisha-SG.id}"]
  subnet_id = "${aws_subnet.Subnet_Public.id}"
  #  subnet_id             = aws_subnet.Subnet_Public.id
    tags = {
    Name = "ec2_spotinstance"
  }
}

output "instance_ip_pub" {

    value = aws_spot_instance_request.nisha_spot1.public_ip

   

  }



#  # EC2 SPOT INSTANCE  private 
# resource "aws_spot_instance_request" "nisha_spot2" {
#   ami                    = "ami-079b5e5b3971bd10d"
#   spot_price             = "0.016"
#   instance_type          = "t2.micro"
#   spot_type              = "one-time"
#   key_name               = "nishaskey"
#     tags = {
#     Name = "ec2_spotinstance"
  
#   }
#  }