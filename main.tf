resource "random_id" "webhook_secret" {
  byte_length = 20
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.aws_resource_prefix}-vpc"
  cidr = var.aws_vpc_cidr.cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr.cidr, var.aws_vpc_cidr.newbits, k)]
  public_subnets = [
    for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr.cidr, var.aws_vpc_cidr.newbits, var.aws_vpc_cidr.azs_count + k)
  ]

  enable_dns_hostnames    = true
  enable_nat_gateway      = true
  map_public_ip_on_launch = false
  single_nat_gateway      = true
}


module "github_runner" {
  depends_on = [module.runners_zip, module.webhook_zip, module.syncer_zip]
  source     = "philips-labs/github-runner/aws"
  version    = "4.4.1"

  aws_region                      = var.aws_region
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  create_service_linked_role_spot = true

  prefix = var.aws_resource_prefix

  github_app = {
    id             = var.github_app_id
    key_base64     = local.gh_key_pem_b64
    webhook_secret = random_id.webhook_secret.hex
  }

  enable_organization_runners = true

  lambda_s3_bucket      = local.aws_lambda_s3_bucket_name
  webhook_lambda_s3_key = local.aws_lambda_s3_webhook_key
  runners_lambda_s3_key = local.aws_lambda_s3_runners_key
  syncer_lambda_s3_key  = local.aws_lambda_s3_syncer_key

  userdata_template = var.userdata_template
  ami_owners        = [var.ami_owner_filter]

  ami_filter = {
    name  = [var.ami_name_filter],
    state = ["available"]
  }
}

resource "github_organization_webhook" "webhook" {
  events = [
    "workflow_job",
  ]
  configuration {
    url          = module.github_runner.webhook["endpoint"]
    content_type = "json"
    secret       = random_id.webhook_secret.hex
  }
}
