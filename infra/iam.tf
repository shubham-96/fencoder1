resource "aws_s3_bucket_policy" "video_bucket_policy" {
  bucket = aws_s3_bucket.video_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowAdamAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.allowed_account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.video_bucket.arn}/*",
          aws_s3_bucket.video_bucket.arn
        ]
      }
    ]
  }) 
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "ec2-s3-access-policy"
  role = aws_iam_role.ec2_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.video_bucket.arn}/*",
          aws_s3_bucket.video_bucket.arn
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-access-profile"
  role = aws_iam_role.ec2_s3_role.name
}