terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "tf-log4j-aws-poc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-log4j-aws-poc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-log4j-aws-poc"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf-log4j-aws-poc"
  }
}

// important to add; this one to add route to subnet
resource "aws_route" "r" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


/*
*
*  Instance 1: Vulnerable Server
*
*/

resource "aws_spot_instance_request" "appserver" {
  ami                         = "ami-0c777ba9e7c011e04"
  instance_type               = "t2.micro"
  key_name                    = "tf-aws"
  spot_type                   = "one-time"
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.pc.id]
  private_ip                  = "10.0.0.51"

  tags = {
    Name = "tf-log4j-aws-poc_appserver"
  }

  wait_for_fulfillment = "true"

  connection { //provisioner "remote-exec"
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    //private_key = file("../terraform-aws")
    private_key = file("../tf-aws.pem")
    timeout     = "2m"
  }


  user_data = templatefile("linux.sh.tftpl", { name = var.user_name })

} //aws_instance

/*
*
* Instance 2: Proxy Server
*
*/

resource "aws_spot_instance_request" "nginx_server" {
  ami                         = "ami-0c777ba9e7c011e04"
  instance_type               = "t2.micro"
  key_name                    = "tf-aws"
  spot_type                   = "one-time"
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.pc.id]
  private_ip                  = "10.0.0.50"

  tags = {
    Name = "tf-log4j-aws-poc_nginx_server"
  }

  wait_for_fulfillment = "true"

  connection { //provisioner "remote-exec"
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    //private_key = file("../terraform-aws")
    private_key = file("../tf-aws.pem")
    timeout     = "2m"
  }


  provisioner "file" {
    source      = "../conf/default"
    destination = "/tmp/default"
  }


  user_data = templatefile("modsecurity-vm.tftpl", { name = var.user_name })



  /*
  provisioner "remote-exec" {
    inline = [
      
    ]
   
  }
  */

} //aws_instance


/*
*  
* Security Group
*
*/

resource "aws_security_group" "pc" {
  vpc_id = aws_vpc.main.id
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = "ssh in"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = "public web access"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["10.0.0.0/16", ]
      description      = "from proxy to vuln server"
      from_port        = 8080
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 8080
    }

  ]

} // security_group

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

} // security_group


/*
*
*  Waf code but costy
*
resource "aws_waf_xss_match_set" "xss_match_set" {
  name = "xss_match_set"

  xss_match_tuples {
    text_transformation = "NONE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuples {
    text_transformation = "NONE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_waf_sql_injection_match_set" "sql_injection_match_set" {
  name = "tf-sql_injection_match_set"

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

*/

