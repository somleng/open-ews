resource "aws_route53domains_registered_domain" "this" {
  domain_name = "open-ews.org"
}

resource "aws_route53_zone" "this" {
  name = "open-ews.org."
}
