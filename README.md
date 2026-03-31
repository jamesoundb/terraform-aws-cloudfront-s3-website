# CloudFront S3 Website Module

This module creates a complete CloudFront distribution with ACM certificate, Route53 DNS records, and S3 origin integration.

## Features

- ACM certificate with automatic DNS validation
- CloudFront distribution with Origin Access Identity
- Route53 DNS records (root and www)
- HTTPS enforcement with customizable SSL/TLS settings
- Configurable cache behaviors
- Geographic restrictions
- IPv6 support

## Usage

```hcl
module "cloudfront_website" {
  source = "./modules/cloudfront-s3-website"

  domain_name                     = "example.com"
  subject_alternative_names       = ["*.example.com"]
  s3_bucket_regional_domain_name  = module.s3_website.bucket_regional_domain_name
  
  aliases             = ["example.com", "www.example.com"]
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  ordered_cache_behaviors = [
    {
      path_pattern           = "/static/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
      compress               = true
    }
  ]

  geo_restriction_type      = "whitelist"
  geo_restriction_locations = ["US", "CA", "GB", "DE"]

  tags = {
    Environment = "production"
  }
}
```

## CloudFront Price Classes

- `PriceClass_All` - All edge locations (best performance)
- `PriceClass_200` - Most edge locations, excluding the most expensive
- `PriceClass_100` - Only North America and Europe edge locations (lowest cost)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

**Note:** The ACM certificate must be created in the `us-east-1` region for CloudFront. Ensure your AWS provider is configured accordingly.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | Primary domain name | `string` | n/a | yes |
| s3_bucket_regional_domain_name | S3 bucket regional domain | `string` | n/a | yes |
| subject_alternative_names | SANs for certificate | `list(string)` | `[]` | no |
| aliases | CloudFront aliases (CNAMEs) | `list(string)` | `[]` | no |
| default_root_object | Default root object | `string` | `"index.html"` | no |
| is_ipv6_enabled | Enable IPv6 | `bool` | `true` | no |
| price_class | CloudFront price class | `string` | `"PriceClass_100"` | no |
| ordered_cache_behaviors | Custom cache behaviors | `list(object)` | `[]` | no |
| geo_restriction_type | Geo restriction type | `string` | `"none"` | no |
| geo_restriction_locations | Country codes for restriction | `list(string)` | `[]` | no |
| minimum_protocol_version | Minimum TLS version | `string` | `"TLSv1.2_2021"` | no |
| create_root_record | Create root domain record | `bool` | `true` | no |
| create_www_record | Create www subdomain record | `bool` | `true` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudfront_distribution_id | CloudFront distribution ID |
| cloudfront_domain_name | CloudFront domain name |
| certificate_arn | ACM certificate ARN |
| origin_access_identity_iam_arn | OAI IAM ARN for bucket policy |
| website_url | Primary website URL |

## Notes

- DNS validation for the ACM certificate may take several minutes
- CloudFront distribution deployment can take 15-20 minutes
- Ensure the Route53 hosted zone exists before applying this module
