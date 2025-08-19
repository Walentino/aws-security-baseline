# AWS Security Baseline – One-Page Handoff / Runbook

**Scope:** Terraform baseline for S3 + IAM-centric guardrails (Access Analyzer, logs, detections).  
**Paths:** modules under `infra/modules/*`, example at `examples/dev-s3`.

## 1) Prereqs
- AWS CLI configured: `aws configure --profile <name>`
- Terraform ≥ 1.6

## 2) Provision (per environment)
```bash
terraform -chdir=examples/dev-s3 init -upgrade
terraform -chdir=examples/dev-s3 plan -out tfplan
terraform -chdir=examples/dev-s3 apply tfplan

### Rollback rehearsal – dev-s3 (2025-08-19)
Result: **No changes. No objects need to be destroyed.**  
State currently manages **0 resources** for dev-s3.
