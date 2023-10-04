# AWS Github Actions Self Hosted Runner

This module allows you to provision a self hosted runner which scales to 0 when not in use.

It is designed to be a "It just works" wrapper around that fantastic  Philips Labs [terraform-aws-github-runner](https://github.com/philips-labs/terraform-aws-github-runner) module.

To get started, you need to create an organisation level GitHub App. This is a one time process and you can follow the [GitHub documentation](https://docs.github.com/en/developers/apps/creating-a-github-app) to do this.

The app should be installed into your organisation and you should have the following permissions in it:

- **Repository permissions**
  - Administration: Read & write
  - Checks: Read
  - Metadata: Read-only
  - Actions: Read-only
- **Organization permissions**
  - Self-hosted runners: Read & write
  - Webhooks: Read & write

You will need the:
* App ID
* App Install ID (you can find this in the URL when viewing the app in the GitHub UI)
* App Private Key (you can download this from the GitHub, keep it in PEM format)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_thumbprint"></a> [github\_thumbprint](#input\_github\_thumbprint) | GitHub OpenID TLS certificate thumbprint (the default is the current value) | `string` | `"6938fd4d98bab03faadb97b34396831e3780aea1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
<!-- END_TF_DOCS -->
