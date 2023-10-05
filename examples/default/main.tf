module "runner" {
  source                = "../../"
  aws_region            = var.aws_region
  github_app_id         = var.github_app_id
  github_app_install_id = var.github_app_install_id
  github_app_key        = sensitive(var.github_app_key)
  github_organisation   = var.github_organisation
}

