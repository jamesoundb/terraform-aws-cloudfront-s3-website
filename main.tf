locals {
  s3_origin_id = var.s3_origin_id
}

# ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Route53 Zone Data Source
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# Route53 Records for Certificate Validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = var.oai_comment
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.cloudfront_comment
  default_root_object = var.default_root_object
  aliases             = var.aliases
  price_class         = var.price_class
  web_acl_id          = var.enable_waf_rate_limiting ? aws_wafv2_web_acl.rate_limit[0].arn : null

  origin {
    domain_name = var.s3_bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = var.default_allowed_methods
    cached_methods         = var.default_cached_methods
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.default_min_ttl
    default_ttl            = var.default_default_ttl
    max_ttl                = var.default_max_ttl

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      target_origin_id       = local.s3_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      min_ttl                = ordered_cache_behavior.value.min_ttl
      default_ttl            = ordered_cache_behavior.value.default_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl
      compress               = coalesce(ordered_cache_behavior.value.compress, true)

      forwarded_values {
        query_string = coalesce(ordered_cache_behavior.value.query_string, false)
        headers      = coalesce(ordered_cache_behavior.value.headers, [])

        cookies {
          forward = "none"
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = var.ssl_support_method
    minimum_protocol_version = var.minimum_protocol_version
  }

  tags = var.tags
}

# Route53 Records for Domain
resource "aws_route53_record" "root" {
  count = var.create_root_record ? 1 : 0

  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

resource "aws_route53_record" "www" {
  count = var.create_www_record ? 1 : 0

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

# WAF v2 Rate Limiting
resource "aws_wafv2_web_acl" "rate_limit" {
  count = var.enable_waf_rate_limiting ? 1 : 0

  name        = "${replace(var.domain_name, ".", "-")}-rate-limit"
  description = "Rate limiting for ${var.domain_name}"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${replace(var.domain_name, ".", "-")}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${replace(var.domain_name, ".", "-")}-waf"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}
