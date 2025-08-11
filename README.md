# AWS Security Baseline

This repository provides a reproducible infrastructure baseline for Amazon Web Services (AWS) environments.  
Its goal is to help new cloud engineers and security practitioners stand up foundational services with a **security‑first** mindset.  
Infrastructure is defined as code using [Terraform](https://www.terraform.io/), enabling consistent deployments across accounts and regions.

## Project structure

The repository is organised as follows:

| Path              | Purpose |
|------------------|---------|
| `infra/`          | Contains reusable Terraform modules and environment configurations.  The `modules/` subfolder holds standalone modules such as `s3-secure-bucket`. |
| `docs/`           | Holds design notes, diagrams and planning documents (to be populated). |
| `main.tf`         | Example root configuration that wires together modules.  Adjust or replace this file per environment. |
| `providers.tf`    | Declares Terraform providers (currently AWS) and their versions. |
| `variables.tf`    | Defines input variables for the root configuration. |
| `README.md`       | (this file) high‑level documentation for the project. |

## Modules

### `s3-secure-bucket`

The first module in this baseline provisions a secure S3 bucket with these controls:

- **Server‑side encryption (SSE)** — objects are encrypted at rest using AES‑256 (SSE‑S3).  
- **Versioning** — previous versions of objects are retained to protect against accidental deletions and overwrites.  
- **Public access blocked** — the module enables all four S3 Public Access Block settings.  
- **Policy enforcement** — a bucket policy denies `PutObject` requests that do not specify AES‑256 encryption.

This module lives at `infra/modules/s3-secure-bucket/`.  See its README for details, inputs and usage.

## Overview

This repository implements an **AWS Security Baseline** using Terraform, starting with foundational controls for S3 and IAM.  
The project is structured for **multi-account AWS organizations** and follows Infrastructure as Code (IaC) best practices with modules and reusable configurations.  
The goal is to provide a starting point for AWS Cloud Security Engineers or solopreneurs to deploy secure-by-default resources.

## Repository Structure

| Path           | Purpose |
|----------------|---------|
| `infra/`       | Contains reusable Terraform modules and environment configurations. The `modules/` subfolder holds standalone modules such as `s3-secure-bucket` and `iam-baseline`. |
| `docs/`        | Holds design notes, diagrams, and planning documents. |
| `main.tf`      | Example root configuration that wires together modules. Adjust or replace per environment. |
| `providers.tf` | Declares Terraform providers (currently AWS) and their versions. |
| `variables.tf` | Defines input variables for the root configuration. |
| `README.md`    | This file — high-level documentation for the project. |

---



## Getting started

1. **Install Terraform** (≥ v1.5).  
2. Clone this repository and navigate into the root directory.  
3. Create a `terraform.tfvars` file (or pass variables on the CLI) with at least a unique `bucket_name`, for example:

   ```hcl
   bucket_name = "my-secure-bucket-20250810"
   aws_region  = "us-east-1"
   ```

4. Initialise and apply the infrastructure:

   ```sh
   terraform init
   terraform plan  -var-file=terraform.tfvars
   terraform apply -var-file=terraform.tfvars
   ```

This will create the secure S3 bucket using the baseline module.  After the apply completes, verify the bucket in the AWS console.

## Development guidance

- **Incremental design** — each week introduces new modules or features (e.g. KMS integration, IAM roles, VPC baselines).  See commit history for progress.
- **Pre‑commit checks** — set up [pre‑commit](https://pre-commit.com/) with the `pre-commit-terraform` hooks to enforce `terraform fmt` and `terraform validate` on each commit.
- **Extensibility** — modules are designed to be self‑contained.  You can add new modules (for example, a `kms-cmk` module) under `infra/modules/` and wire them into `main.tf`.

## Contributing

Contributions are welcome.  Please fork the repository and open a pull request with descriptive commits.  When adding new modules, include a dedicated README and at least one example usage block.  Use `terraform fmt` and `terraform validate` before committing.

---

**Note:** This README summarises the state of the repository after Week 1 Day 2.  Subsequent days will introduce additional modules (e.g. customer‑managed keys) and documentation.

