resource "aws_lb_listener_certificate" "this" {
  listener_arn    = local.region.public_load_balancer.https_listener.arn
  certificate_arn = module.ssl_certificate.this.arn
}
