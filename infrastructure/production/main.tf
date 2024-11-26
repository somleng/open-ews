module "scfm" {
  source = "../modules/scfm"

  app_identifier        = "scfm"
  subdomain             = "scfm"
  cdn_subdomain         = "cdn-scfm"
  audio_subdomain       = "audio"
  app_environment       = "production"
  global_accelerator    = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  region                = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  app_image             = data.terraform_remote_state.core.outputs.app_ecr_repository.this.repository_url
  rds_cluster           = data.terraform_remote_state.core.outputs.rds_cluster
  aws_region            = var.aws_region
  route53_zone          = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  internal_route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org
  cdn_certificate       = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  uploads_bucket        = "uploads.somleng.org"
  audio_bucket          = "audio.somleng.org"
  audio_bucket_cname    = "audio.somleng.org"
  db_name               = "scfm"
  worker_min_tasks      = 1
  worker_max_tasks      = 10

  redis_security_group = data.terraform_remote_state.core.outputs.redis_security_group.id
  redis_url            = "redis://${data.terraform_remote_state.core.outputs.elasticache_redis_endpoint}/10"

}
