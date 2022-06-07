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

resource "aws_spot_instance_request" "app_server" {
  ami                    = "ami-0c777ba9e7c011e04" //ubuntu-bionic-18.04-amd64-server-20220411
  instance_type          = "t2.micro"
  key_name               = "tf-aws"
  vpc_security_group_ids = [aws_security_group.main.id]
  wait_for_fulfillment   = "true"
  spot_type              = "one-time"

  tags = {
    Name = "tf-log4j-aws-poc_app_instance"
  }


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
/  Security Group
/
*/
resource "aws_security_group" "main" {
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
      description      = "tomcat in"
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


/*
*
*  AWS Waf section but maybe costy
*  SQLi and XXS protection only.
*/

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
