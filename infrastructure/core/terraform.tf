terraform {
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "scfm_core.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}

data "terraform_remote_state" "core_infrastructure" {
  backend = "s3"

  config = {
    bucket = "infrastructure.somleng.org"
    key    = "core.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "somleng_core_infrastructure" {
  backend = "s3"

  config = {
    bucket = "infrastructure.somleng.org"
    key    = "twilreapi_core.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  region = var.aws_region
}
