variable "domain_name" {
  description = "Primary domain name for the website"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the ACM certificate"
  type        = list(string)
  default     = []
}

variable "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  type        = string
}

variable "s3_origin_id" {
  description = "Origin ID for the S3 bucket"
  type        = string
  default     = "s3-origin"
}

variable "oai_comment" {
  description = "Comment for the CloudFront Origin Access Identity"
  type        = string
  default     = "OAI for S3 bucket"
}

variable "cloudfront_comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = "Managed by Terraform"
}

variable "default_root_object" {
  description = "Default root object for the CloudFront distribution"
  type        = string
  default     = "index.html"
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) for the distribution"
  type        = list(string)
  default     = []
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "default_allowed_methods" {
  description = "Allowed methods for the default cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "default_cached_methods" {
  description = "Cached methods for the default cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_protocol_policy" {
  description = "Viewer protocol policy"
  type        = string
  default     = "redirect-to-https"
}

variable "default_min_ttl" {
  description = "Minimum TTL for default cache behavior"
  type        = number
  default     = 0
}

variable "default_default_ttl" {
  description = "Default TTL for default cache behavior"
  type        = number
  default     = 3600
}

variable "default_max_ttl" {
  description = "Maximum TTL for default cache behavior"
  type        = number
  default     = 86400
}

variable "ordered_cache_behaviors" {
  description = "Ordered cache behaviors for the distribution"
  type = list(object({
    path_pattern           = string
    allowed_methods        = list(string)
    cached_methods         = list(string)
    viewer_protocol_policy = string
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
    compress               = optional(bool)
    query_string           = optional(bool)
    headers                = optional(list(string))
  }))
  default = []
}

variable "geo_restriction_type" {
  description = "Type of geo restriction (whitelist, blacklist, or none)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "ssl_support_method" {
  description = "SSL support method for the distribution"
  type        = string
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "Minimum SSL/TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "create_root_record" {
  description = "Whether to create Route53 record for root domain"
  type        = bool
  default     = true
}

variable "create_www_record" {
  description = "Whether to create Route53 record for www subdomain"
  type        = bool
  default     = true
}

variable "evaluate_target_health" {
  description = "Whether to evaluate target health for Route53 alias records"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
