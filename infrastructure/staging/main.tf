module "scfm" {
  source = "../modules/scfm"

  app_identifier        = "open-ews-staging"
  subdomain             = "scfm-staging"
  cdn_subdomain         = "cdn-scfm-staging"
  audio_subdomain       = "audio-staging"
  app_environment       = "staging"
  global_accelerator    = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  region                = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  app_image             = data.terraform_remote_state.core.outputs.app_ecr_repository.this.repository_url
  rds_cluster           = data.terraform_remote_state.core.outputs.rds_cluster
  aws_region            = var.aws_region
  route53_zone          = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  internal_route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org
  cdn_certificate       = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  uploads_bucket        = "uploads-staging.open-ews.org"
  audio_bucket          = "audio-staging.open-ews.org"
  audio_bucket_cname    = "audio-staging.somleng.org"
  db_name               = "open_ews_staging"
  worker_min_tasks      = 1
  worker_max_tasks      = 1
}
