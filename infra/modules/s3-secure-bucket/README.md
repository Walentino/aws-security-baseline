# s3-secure-bucket

This module provisions a secure Amazon\u00a0S3 bucket with a basic security baseline.  
It is intended for use in AWS multi\u2011account security baselines where consistent, controlled bucket configurations are needed.

## Overview

The module builds an S3 bucket with several security controls enabled by default:

- **Server\u2011Side Encryption (SSE)** \u2014 objects stored in the bucket are encrypted at rest using AES\u2011256 (also known as SSE\u2011S3).  
  In future iterations, this module can be extended to accept a KMS Customer\u2011Managed Key (CMK) ARN so that uploads are encrypted using a specific key.
- **Versioning enabled** \u2014 keeping old versions of objects provides protection against accidental overwrites or deletions.
- **Public access blocked** \u2014 the module applies an S3 Public Access Block configuration to ensure that public ACLs and public bucket policies are disabled.
- **Bucket policy guardrails** \u2014 the module installs a bucket policy that denies `PutObject` requests unless server\u2011side encryption using AES\u2011256 is specified.  
  This helps ensure that uploads are encrypted at rest.

## Inputs

| Name          | Type         | Default | Description |
|---------------|-------------|---------|-------------|
| `bucket_name` | `string`     | N/A     | Globally unique name for the S3 bucket.  This is required and should be provided via root variables or a `.tfvars` file. |
| `tags`        | `map(string)`| `{}`    | Optional map of tags to apply to the bucket and its related resources. |

## Outputs

This module currently does not export outputs.  In future versions, outputs such as the bucket ARN or ID can be exposed for downstream modules to consume.

## Example usage

```
hcl
module "secure_bucket" {
  source      = "./infra/modules/s3-secure-bucket"
  bucket_name = var.bucket_name  # Provide a unique bucket name via root variables or tfvars
  tags        = {
    Project     = "aws-security-baseline"
    Environment = "dev"
  }
}
```

## Future improvements

- **KMS support** \u2014 add a `kms_key_arn` variable and update the encryption configuration and bucket policy to enforce a specific Customer\u2011Managed Key.  
- **Outputs** \u2014 expose outputs such as `bucket_id`, `bucket_arn` and `bucket_name` to make integration with other modules easier.  
- **Documentation** \u2014 expand module documentation to include architecture diagrams and links to AWS best\u2011practice guidance.
