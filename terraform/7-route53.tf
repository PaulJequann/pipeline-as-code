// Requires a hosted zone to be created in Route53.

data "aws_route53_zone" "main" {
  name         = var.root_domain_name
  private_zone = false
}

# resource "aws_route53_zone" "main" {
#   name = var.root_domain_name
# }

resource "aws_route53_record" "bastion" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "bastion.${var.root_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.bastion.public_ip]
}

resource "aws_route53_record" "jenkins_master" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "jenkins.${var.root_domain_name}"
  type    = "A"
  alias {
    name                   = aws_elb.jenkins_elb.dns_name
    zone_id                = aws_elb.jenkins_elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "main" {
  domain_name       = var.root_domain_name
  validation_method = "DNS"

  subject_alternative_names = ["*.${var.root_domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_dns" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }

    if contains(concat([aws_acm_certificate.main.domain_name], tolist(aws_acm_certificate.main.subject_alternative_names)), "*.${dvo.domain_name}") == false
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  #   zone_id         = data.aws_route53_zone.main[each.key].zone_id
  zone_id = data.aws_route53_zone.main.zone_id
}

# resource "aws_route53_record" "cert_dns" {
#   allow_overwrite = true
#   name            = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_name
#   records         = [tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_value]
#   type            = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_type
#   zone_id         = aws_route53_zone.main.zone_id
#   ttl             = 60
# }

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_dns : record.fqdn]
}