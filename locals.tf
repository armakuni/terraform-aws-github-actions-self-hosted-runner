locals {
  aws_lambda_s3_bucket_name = "${var.aws_resource_prefix}-lambda-sources"
  aws_lambda_s3_syncer_key  = "runner-binaries-syncer.zip"
  aws_lambda_s3_runners_key = "runners.zip"
  aws_lambda_s3_webhook_key = "webhook.zip"

  az_count       = var.aws_vpc_cidr.azs_count
  azs            = slice(data.aws_availability_zones.available.names, 0, local.az_count)
  gh_key_pem_b64 = sensitive(base64encode(var.github_app_key))
}
