# Creating S3 bucket for static website
resource "aws_s3_bucket" "static_web_bucket" {
  bucket = var.s3-website-bucket
  acl    = "public-read"

  force_destroy = true
  # Bucket policy to allow public access
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3-website-bucket}/*"
            ]
        }
    ]
  }
  POLICY


  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}

# Creating Bucket for codepipeline artifact
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3-artifact-bucket
  acl    = "private"
  force_destroy = true
}

## Creating connection
## Leaving this here in case I have time to figure out the connection part
#resource "aws_codestarconnections_connection" "connection" {
#  name          = "connection"
#  provider_type = "GitHub"
#}


# Creating Codepipeline resources
resource "aws_codepipeline" "codepipeline" {
  name     = "DeploysStaticWebsiteToS3FromGithub"
  role_arn = aws_iam_role.deploy_from_codepipeline_to_s3.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn        = var.codestar-connections-arn
        FullRepositoryId     = "${var.github-organization}/${var.github-repository}"
        BranchName           = var.github-branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["source_output"]
      version         = "1"
      region          = var.aws-region
      configuration = {
        BucketName: var.s3-website-bucket
        Extract  : "true"
      }
    }
  }
}

# Cloudfront distribution resources
resource "aws_cloudfront_distribution" "cloudfront-s3" {
  enabled             = true
  default_root_object = "index.html" #This points to our index.html in the s3 bucket

  origin {
    domain_name = aws_s3_bucket.static_web_bucket.bucket_regional_domain_name  # points to the original name of our website s3 bucket
    origin_id   = aws_s3_bucket.static_web_bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path #resource created for this, new resource that allows our cloudfront resource, Also a connection to s3 bucket
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.static_web_bucket.bucket_regional_domain_name #Origin idenity for origin ID
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers      = []
      query_string = true

      cookies {
        forward = "all"
      }
    }
    min_ttl = 1800
    default_ttl = 1800  # 30 minutes converted to seconds
    max_ttl = 1800

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  #This ensures my website uses TLS and makes sure the website is secure when accessing through HTTPS
  viewer_certificate {
    cloudfront_default_certificate = true #Cloud front Default Certificate
    ssl_support_method     = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

}

#resource created for this, new resource that allows our cloudfront resource, Also a connection to s3 bucket
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for static website"
}

#This creates a policy to allow - Sets a policy that would define policy for CloudFront to access s3
resource "aws_s3_bucket_policy" "s3policy" {
  bucket = aws_s3_bucket.static_web_bucket.id
  policy = data.aws_iam_policy_document.s3policy.json
}
