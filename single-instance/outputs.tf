/*
output "vpc_id" {
  value = "${aws_vpc.app_server.id}"
}

output "subnet_cidr" {
  value = "${aws_subnet.app_server.cidr_block}"
}
*/


output "public_ip" {
  value = aws_spot_instance_request.app_server.public_ip
}

output "public_dns" {
  value = aws_spot_instance_request.app_server.public_dns
}