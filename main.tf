terraform{
	required_providers{
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.16"
		}
	}
	required_version = ">= 1.2.0"
}

provider "aws" {
        region = "ap-southeast-2"
        profile = "mihir.patel"
}

data "aws_vpc" "default" {
	default = true
}

resource "aws_security_group" "allow_all" {
	name = "allow_all"
	description = "Allow all traffic at the moment"
	vpc_id = data.aws_vpc.default.id
	ingress {
		description = "Allowing all inbound traffic"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		description = "Allowing all outbound traffic"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

variable "public_key" {
	type = string
	default = "~/.ssh/id_rsa.pub"
}
resource "aws_key_pair" "ssh_key"{
	key_name = "ec2"
	public_key = file(var.public_key)
}

resource "aws_spot_instance_request" "this" {
	ami = "ami-0b8d527345fdace59"
	key_name = aws_key_pair.ssh_key.key_name
	instance_type = "t3.micro"
	spot_price = "0.01"
	associate_public_ip_address = true
	wait_for_fulfillment = true
	tags = {
		Name = "srvr-1"
	}
	vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
}

output "aws_instances" {
	value = aws_spot_instance_request.this.public_ip
}
