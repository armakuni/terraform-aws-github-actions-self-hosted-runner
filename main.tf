resource "random_id" "webhook_secret" {
  count = var.enable == true ? 1 : 0

  byte_length = 20
}

module "vpc" {
  count = var.enable == true ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

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
  count = var.enable == true ? 1 : 0

  depends_on = [module.runners_zip[0], module.webhook_zip[0], module.syncer_zip[0]]
  source     = "philips-labs/github-runner/aws"
  version    = "6.0.0"

  aws_region                      = var.aws_region
  vpc_id                          = module.vpc[0].vpc_id
  subnet_ids                      = module.vpc[0].private_subnets
  create_service_linked_role_spot = true

  prefix = var.aws_resource_prefix

  github_app = {
    id             = var.github_app_id
    key_base64     = local.gh_key_pem_b64
    webhook_secret = random_id.webhook_secret[0].hex
  }

  enable_organization_runners = true

  lambda_s3_bucket      = local.aws_lambda_s3_bucket_name
  webhook_lambda_s3_key = local.aws_lambda_s3_webhook_key
  runners_lambda_s3_key = local.aws_lambda_s3_runners_key
  syncer_lambda_s3_key  = local.aws_lambda_s3_syncer_key

  runner_run_as         = var.runner_run_as
  enable_ssm_on_runners = true
  userdata_pre_install  = var.additional_install_script
  ami_owners            = [var.ami_owner_filter]

  block_device_mappings = [
    {
      device_name           = "/dev/sda1"
      delete_on_termination = true
      volume_type           = "gp3"
      volume_size           = 30
      encrypted             = true
      iops                  = null
      throughput            = null
      kms_key_id            = null
      snapshot_id           = null
    }
  ]



  logging_retention_in_days                   = 7
  enable_userdata                             = true
  enable_runner_workflow_job_labels_check_all = false
  userdata_template                           = "${path.module}/templates/userdata.sh"

  ami_filter = {
    name  = [var.ami_name_filter],
    state = ["available"]
  }

  runner_log_files = [
    {
      "log_group_name" : "syslog",
      "prefix_log_group" : true,
      "file_path" : "/var/log/syslog",
      "log_stream_name" : "{instance_id}"
    },
    {
      "log_group_name" : "user_data",
      "prefix_log_group" : true,
      "file_path" : "/var/log/user-data.log",
      "log_stream_name" : "{instance_id}/user_data"
    },
    {
      "log_group_name" : "runner",
      "prefix_log_group" : true,
      "file_path" : "/opt/actions-runner/_diag/Runner_**.log",
      "log_stream_name" : "{instance_id}/runner"
    }
  ]
}

resource "github_organization_webhook" "webhook" {
  count = var.enable == true ? 1 : 0

  events = [
    "workflow_job",
  ]
  configuration {
    url          = module.github_runner[0].webhook.endpoint
    content_type = "json"
    secret       = random_id.webhook_secret[0].hex
  }
}
