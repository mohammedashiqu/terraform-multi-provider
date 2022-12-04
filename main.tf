resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "helloworld"
  }
}
resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/25"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-terraform"
  }
}
resource "aws_security_group" "ssh" {
  name = "security-group"
  description = "security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "terraform route table"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}
resource "aws_instance" "ec2" {
  ami = "ami-0b0dcb5067f052a63"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet.id
  key_name = aws_key_pair.sshkey.id
  security_groups = [aws_security_group.ssh.id]
  lifecycle {
    create_before_destroy = true
  }
  provisioner "remote-exec" {
    inline = ["sudo yum install httpd -y",
              "sudo systemctl start httpd",
              "echo a=${aws_instance.ec2.public_ip} >> /home/ec2-user/file.sh",
              "ashiq=${aws_instance.ec2.public_ip}",
              "sudo chmod 777 /home/ec2-user/file.sh"
    ]
  }
  connection {
    type = "ssh"
    host = aws_instance.ec2.public_ip
    user = "ec2-user"
    private_key = file ("C:/Users/ashiq/.ssh/id_rsa")
  }
  tags = {
    Name = "ec2-instance"
  }
}
resource "aws_route_table_association" "route-table-association" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.subnet.id
}
resource "aws_route" "route" {
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_key_pair" "sshkey" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwPY1VpBixvIJCIUMNz9pvT687FNPAa8hAw3t239SOfYAsy1lgRYyh2YF6ey7pMmo+u0TSSGFRMlqoolFoZNClFujMI31v3aUrhC+l4ppfGDuKNeaVztEkpAlh5ARN01aLyYtOSia/tZSvRl1BcVAWIEWsgbYhi/JFrMVhTBMYkvvK8uHKiJc0RRodCSJeCnCY7Bqa7TU3qMNA0h8lE4gSmvVSsel9tNPf16qnQjRGQS9Hn5FFPvccjP3DVihTq3ee3uxfSJ4/gABSDur8KIDMRU0CjbkUk/KnKDYUecMuKoYdPvV1hiKWI9YljqUxQDSSCMFNlMOrLwZNU35+nCTJH3hC2aaQb9/BAlKP2Xxyquk3am+ZHRINev1zjcmcDtLOvXtYOtY5e9P7drgQ9chFvoB3geNGIdvhU2/nHei7YNA26z4uc8qPL/9H1+MDJORLy9U06JZVRBOC36OmtjGKSx6R5HT2aezM7OmHljk00qKAcY9neLo6xAne9tWrs7c= ashiq@INBook_X1"
}
output "ec2-ip" {
  value = aws_instance.ec2.public_ip
}