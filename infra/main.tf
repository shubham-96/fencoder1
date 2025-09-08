resource "aws_s3_bucket" "video_bucket" {
  bucket = var.bucket_name
  tags = {
    Project = var.project_tag
  }
}

resource "aws_instance" "fencoder_instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.my_key.key_name
  subnet_id = data.aws_subnet.ec2_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = file("${path.module}/../bin/mount-ebs.sh")

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "one-time" 
      instance_interruption_behavior = "terminate"
      # max_price = "0.20" # Optional: Uncomment to cap hourly cost
    }
  }
  tags = {
    Project = var.project_tag
    Name    = "fencoder-instance"
  }
}

resource "aws_ebs_volume" "fencoder_volume" {
  availability_zone = data.aws_subnet.ec2_subnet.availability_zone
  size              = 50 # in GB
  type              = "gp3"
  tags = {
    Project = var.project_tag
    Name    = "fencoder-volume"
  }
}

resource "aws_key_pair" "my_key" {
  key_name = "my_ec2_key"
  public_key = file("~/.ssh/my_ec2_key.pub")
}

resource "aws_security_group" "ec2_sg" {
  name = "fencoder-ec2-sg"
  description = "Allow SSH & outbound S3 instances"
  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Project = var.project_tag
  }
}

resource "aws_volume_attachment" "ec2_ebs_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.fencoder_volume.id
  instance_id = aws_instance.fencoder_instance.id
  force_detach = true
  depends_on = [aws_instance.fencoder_instance]
}

output "instance_id" {
  value = aws_instance.fencoder_instance.id
  description = "ID of the EC2 instance"
}

output "instance_public_dns" {
  value = aws_instance.fencoder_instance.public_dns
  description = "Public IP address of the EC2 instance"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.video_bucket.bucket
  description = "Name of the S3 bucket"
}