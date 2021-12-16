# Role needed for codepipeline to connect to source and deploy
resource "aws_iam_role" "deploy_from_codepipeline_to_s3" {
  name = "deploy_from_codepipeline_to_s3_tes"

  assume_role_policy  = data.aws_iam_policy_document.instance-assume-role-policy.json
  path                = "/service-role/"
  managed_policy_arns = [aws_iam_policy.policy.arn]

}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

# Policy for codepipeline to have access to s3 bucket and codestar
resource "aws_iam_policy" "policy" {
  name        = "Deploy-static-website-to-s3"
  description = "Policy gives resource permission to write and read s3 and push to it "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.s3-website-bucket}/*",
          "arn:aws:s3:::${var.s3-artifact-bucket}/*"
          ],
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : ["codestar-connections:UseConnection"],
        "Resource" : [
          "arn:aws:codestar-connections:${var.aws-region}:${var.aws-account}:connection/*"
        ]
      }
    ]
  })
}

# Policy needed by cloudfront
data "aws_iam_policy_document" "s3policy" {
  statement {
    actions = ["s3:GetObject"]

    resources = [
      aws_s3_bucket.static_web_bucket.arn,
      "${aws_s3_bucket.static_web_bucket.arn}/*"
    ]

    #Granting permission to origin access identiy
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}
