module "ssl_certificate" {
  source = "../modules/ssl_certificate"

  domain_name               = "open-ews.org"
  subject_alternative_names = ["*.open-ews.org"]
  route53_zone              = aws_route53_zone.this
}
