# First, define the AWS Security Group resource
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins"
  # Add your security group rules here
   ingress = [
    for port in[ 22,80,443,8080,9000,9090,9100,3000,8081 ] : {
        description = "inbound rules"
        from_port = port
        to_port = port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    }
  ]
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "Jenkins" {
  ami                       = "ami-0287a05f0ef0e9d9a"
  instance_type             = "t2.large"
  key_name                  = "paraspahwa"
  vpc_security_group_ids    = [aws_security_group.jenkins-sg.id]
  user_data = templatefile("./install.sh",{})

  tags = {
    Name = "Jenkins-sonarqube"
  }
  root_block_device {
    volume_size = 30
  }
}

resource "aws_instance" "Nexus" {
  ami                       = "ami-0287a05f0ef0e9d9a"
  instance_type             = "t2.medium"
  key_name                  = "paraspahwa"
  vpc_security_group_ids    = [aws_security_group.jenkins-sg.id]

  tags = {
    Name = "nexus"
  }
  root_block_device {
    volume_size = 20
  }
}