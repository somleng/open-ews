resource "aws_lb_listener_certificate" "this" {
  listener_arn    = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region.public_load_balancer.https_listener.arn
  certificate_arn = module.ssl_certificate.this.arn
}
