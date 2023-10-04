module "download_lambda" {
  source  = "philips-labs/github-runner/aws//modules/download-lambda"
  version = "4.4.1"

  lambdas = [
    {
      name = "webhook"
      tag  = "v4.4.1"
    },
    {
      name = "runners"
      tag  = "v4.4.1"
    },
    {
      name = "runner-binaries-syncer"
      tag  = "v4.4.1"
    }
  ]
}


module "s3_bucket_lambda_sources" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = local.aws_lambda_s3_bucket_name

  force_destroy = true
}


module "webhook_zip" {
  depends_on = [module.download_lambda, module.s3_bucket_lambda_sources]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version    = "3.15.1"

  bucket       = module.s3_bucket_lambda_sources.s3_bucket_id
  key          = local.aws_lambda_s3_webhook_key
  content_type = "application/zip"

  file_source = module.download_lambda.files[0]
}

module "runners_zip" {
  depends_on = [module.download_lambda]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version    = "3.15.1"

  bucket       = module.s3_bucket_lambda_sources.s3_bucket_id
  key          = local.aws_lambda_s3_runners_key
  content_type = "application/zip"

  file_source = module.download_lambda.files[1]
}

module "syncer_zip" {
  depends_on = [module.download_lambda]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version    = "3.15.1"

  bucket       = module.s3_bucket_lambda_sources.s3_bucket_id
  key          = local.aws_lambda_s3_syncer_key
  content_type = "application/zip"

  file_source = module.download_lambda.files[2]
}
