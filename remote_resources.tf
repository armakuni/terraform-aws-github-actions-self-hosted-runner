module "download_lambda" {
  count = var.enable == true ? 1 : 0

  source  = "philips-labs/github-runner/aws//modules/download-lambda"
  version = "6.1.2"

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
  count = var.enable == true ? 1 : 0

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = local.aws_lambda_s3_bucket_name

  force_destroy = true
}


module "webhook_zip" {
  count = var.enable == true ? 1 : 0

  depends_on = [module.download_lambda[0], module.s3_bucket_lambda_sources[0]]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version    = "4.6.0"

  bucket       = module.s3_bucket_lambda_sources[0].s3_bucket_id
  key          = local.aws_lambda_s3_webhook_key
  content_type = "application/zip"

  file_source = module.download_lambda[0].files[0]
}

module "runners_zip" {
  count = var.enable == true ? 1 : 0

  depends_on = [module.download_lambda[0]]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version    = "4.6.0"

  bucket       = module.s3_bucket_lambda_sources[0].s3_bucket_id
  key          = local.aws_lambda_s3_runners_key
  content_type = "application/zip"

  file_source = module.download_lambda[0].files[1]
}

module "syncer_zip" {
  count = var.enable == true ? 1 : 0

  depends_on = [module.download_lambda[0]]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version    = "4.6.0"

  bucket       = module.s3_bucket_lambda_sources[0].s3_bucket_id
  key          = local.aws_lambda_s3_syncer_key
  content_type = "application/zip"

  file_source = module.download_lambda[0].files[2]
}
