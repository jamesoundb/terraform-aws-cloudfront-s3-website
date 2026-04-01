output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront Route 53 zone ID"
  value       = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "origin_access_identity_path" {
  description = "CloudFront access identity path for S3 bucket policy"
  value       = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
}

output "origin_access_identity_iam_arn" {
  description = "IAM ARN of the CloudFront origin access identity"
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "website_url" {
  description = "Primary website URL"
  value       = "https://${var.domain_name}"
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF v2 Web ACL (null if WAF not enabled)"
  value       = var.enable_waf_rate_limiting ? aws_wafv2_web_acl.rate_limit[0].arn : null
}
