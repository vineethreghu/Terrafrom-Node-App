# the terraform documentaion can be found by just searching "terraform aws s3 bucket resource"

resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "nodejs-bucket-123"

  tags = {
    Name        = "Node Js Terraform bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "tf_s3_object" {
  bucket = aws_s3_bucket.tf_s3_bucket.bucket
  for_each = fileset("../public/images", "**")
  key    = "images/${each.key}"
  source = "../public/images/${each.key}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
}