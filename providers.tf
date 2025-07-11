terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0 "
    }
  }
}


provider "github" {
  owner = var.github_organisation
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_install_id
    pem_file        = var.github_app_key
  }
}
