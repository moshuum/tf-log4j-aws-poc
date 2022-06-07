
/*output "vpc_id" {
  value = "${aws_vpc.tf_aws_log4j_poc.id}"
}

output "subnet_cidr" {
  value = "${aws_subnet.my_subnet.cidr_block}"
}*/



output "public_ip" {
  value = aws_spot_instance_request.nginx_server.public_ip
}

output "public_dns" {
  value = aws_spot_instance_request.nginx_server.public_dns
}