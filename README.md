# AWS Github Actions Self Hosted Runner

This module allows you to provision a self hosted runner which scales to
0 when not in use.

It is designed to be a "It just works" wrapper for debian based amis
around that fantastic Philips Labs
[terraform-aws-github-runner](https://github.com/philips-labs/terraform-aws-github-runner)
module.

To get started, you need to create an organisation level GitHub App.
This is a one time process and you can follow the [GitHub
documentation](https://docs.github.com/en/developers/apps/creating-a-github-app)
to do this.

The app should be installed into your organisation and you should have
the following permissions in it:

- **Repository permissions**
  - Administration: Read & write
  - Checks: Read
  - Metadata: Read-only
  - Actions: Read-only
- **Organization permissions**
  - Self-hosted runners: Read & write
  - Webhooks: Read & write

You will need the:

- App ID
- App Install ID (you can find this in the URL when viewing the app in
  the GitHub UI)
- App Private Key (you can download this from GitHub App page, keep it
  in PEM format)

Note, to use this worker for public repositories, you will need to
enable "Allow public repositories" in the GitHub runner groups section.
You can find this in the organisation settings under actions, runner
groups, then clicking on the default group.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.30.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.4.0  |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.30.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_download_lambda"></a> [download\_lambda](#module\_download\_lambda) | philips-labs/github-runner/aws//modules/download-lambda | 5.5.1 |
| <a name="module_github_runner"></a> [github\_runner](#module\_github\_runner) | philips-labs/github-runner/aws | 5.5.1 |
| <a name="module_runners_zip"></a> [runners\_zip](#module\_runners\_zip) | terraform-aws-modules/s3-bucket/aws//modules/object | 3.15.1 |
| <a name="module_s3_bucket_lambda_sources"></a> [s3\_bucket\_lambda\_sources](#module\_s3\_bucket\_lambda\_sources) | terraform-aws-modules/s3-bucket/aws | 3.15.1 |
| <a name="module_syncer_zip"></a> [syncer\_zip](#module\_syncer\_zip) | terraform-aws-modules/s3-bucket/aws//modules/object | 3.15.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.4.0 |
| <a name="module_webhook_zip"></a> [webhook\_zip](#module\_webhook\_zip) | terraform-aws-modules/s3-bucket/aws//modules/object | 3.15.1 |

## Resources

| Name | Type |
|------|------|
| [github_organization_webhook.webhook](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_webhook) | resource |
| [random_id.webhook_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_install_script"></a> [additional\_install\_script](#input\_additional\_install\_script) | A script that will be executed before setup of the runner, this can be used to install additional software, or configure the runner in some way | `string` | `""` | no |
| <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter) | The name filter to use when searching for the AMI to use for the runner | `string` | `"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"` | no |
| <a name="input_ami_owner_filter"></a> [ami\_owner\_filter](#input\_ami\_owner\_filter) | The owner filter to use when searching for the AMI to use for the runner. The default is canonicals account | `string` | `"099720109477"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_resource_prefix"></a> [aws\_resource\_prefix](#input\_aws\_resource\_prefix) | Prefix for all resources | `string` | `"gh-act"` | no |
| <a name="input_aws_vpc_cidr"></a> [aws\_vpc\_cidr](#input\_aws\_vpc\_cidr) | The cidr for the VPC that the runners run in, must have at enough blocks available with a subnet in each Availability Zone, for example 10.68.0.0/16, with a newbits of 8 and a azs\_count of 3 will result in 6 subnets being provisioned in the ranges of 10.68.1.0/24, 10.68.2.0/24, and 10.68.3.0/24 in the private subnet and 10.68.4.0/24, 10.68.5.0/24, and 10.68.6.0/24 in the public subnet, with one private and one public per availability zone. Note the "/24" here, 16+8 == 24, you may also choose different ranges with less tidy ip blocks | <pre>object({<br>    cidr      = string<br>    newbits   = number<br>    azs_count = number<br>  })</pre> | <pre>{<br>  "azs_count": 3,<br>  "cidr": "10.68.0.0/16",<br>  "newbits": 8<br>}</pre> | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Disable or enable everything in this module | `bool` | `true` | no |
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | This is ID from App in developer settings | `string` | n/a | yes |
| <a name="input_github_app_install_id"></a> [github\_app\_install\_id](#input\_github\_app\_install\_id) | You can find this in the URL when viewing the installed app in the GitHub UI | `string` | n/a | yes |
| <a name="input_github_app_key"></a> [github\_app\_key](#input\_github\_app\_key) | The private key of the GitHub App. PEM formatted. | `string` | n/a | yes |
| <a name="input_github_organisation"></a> [github\_organisation](#input\_github\_organisation) | The github organisation to use | `string` | n/a | yes |
| <a name="input_runner_run_as"></a> [runner\_run\_as](#input\_runner\_run\_as) | The user to run things as on the host, defaults to ubuntu, as this is the username on the ubuntu AMI, however if you might want to change it to whatever you use, perhaps ec2-user | `string` | `"ubuntu"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
